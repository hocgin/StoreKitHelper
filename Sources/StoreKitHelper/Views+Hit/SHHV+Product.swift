//
//  StoreHitHelperView+Product.swift
//  StoreKitHelper
//
//  Created by hocgin on 2025/4/27.
//

import StoreKit
import SwiftUI

extension StoreHitHelperView {
    // MARK: 产品列表

    struct ProductsListView: View {
        @Environment(\.locale) var locale
        @Environment(\.popupDismissHandle) private var popupDismissHandle
        @EnvironmentObject var store: StoreContext
        @ObservedObject var viewModel = ProductsListViewModel()
        @Binding var buyingProductID: String?
        @Binding var loading: ProductsLoadingStatus
        @State var hovering: Bool = false
        var body: some View {
            ForEach(store.products) { product in
                let unit = product.subscription?.subscriptionPeriod.unit
                let isBuying = buyingProductID == product.id
                let hasPurchased = store.isProductPurchased(product)
                if let filteredProducts = viewModel.filteredProducts {
                    let shouldDisplay = filteredProducts(product.id, product)
                    if shouldDisplay == true {
                        ProductsListLabelView(
                            isBuying: .constant(isBuying),
                            productId: product.id,
                            unit: unit,
                            displayPrice: product.displayPrice,
                            displayName: product.displayName,
                            description: product.description,
                            hasPurchased: hasPurchased
                        ) {
                            purchase(product: product)
                        }
                        .id(product.id)
                        .disabled(buyingProductID != nil)
                    }
                } else {
                    ProductsListLabelView(
                        isBuying: .constant(isBuying),
                        productId: product.id,
                        unit: unit,
                        displayPrice: product.displayPrice,
                        displayName: product.displayName,
                        description: product.description,
                        hasPurchased: hasPurchased
                    ) {
                        purchase(product: product)
                    }
                    .id(product.id)
                    .disabled(buyingProductID != nil)
                }
            }
        }

        func purchase(product: Product) {
            Task {
                buyingProductID = product.id
                do {
                    let (_, transaction) = try await store.purchase(product)
                    if let transaction {
                        await transaction.finish()
                    }
                    buyingProductID = nil
                    if let transaction {
                        store.updatePurchaseTransactions(with: transaction)
                    } else {
                        try await store.updatePurchases()
                    }
                    if store.isProductPurchased(product) == true {
                        popupDismissHandle?()
                    }
                } catch {
                    buyingProductID = nil
                    Utils.alert(title: "purchase_failed".localized(locale: locale), message: error.localizedDescription)
                }
            }
        }

        public func filteredProducts(_ filtered: ((String, Product) -> Bool)?) -> ProductsListView {
            viewModel.filteredProducts = filtered
            return self
        }
    }

    // MARK: 产品项

    struct ProductsListLabelView: View {
        @EnvironmentObject var store: StoreContext
        @State var hovering: Bool = false
        @Binding var isBuying: Bool
        var productId: ProductID
        var unit: Product.SubscriptionPeriod.Unit?
        var displayPrice: String
        var displayName: String
        var description: String
        var hasPurchased: Bool
        var purchase: () -> Void
        var body: some View {
            Button { purchase() } label: {
                HStack {
                    if isBuying == true {
                        ProgressView().controlSize(.mini)
                    }
                    VStack {
                        Text(verbatim: displayName)
                            .font(.headline)
                        HStack(spacing: 2) {
                            if let localizedDescription = unit?.localizedDescription {
                                Text("\(displayPrice)") + Text(" / \(localizedDescription)").font(.system(size: 10))
                            } else {
                                Text("\(displayPrice)")
                            }
                        }
                        .font(.footnote)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(ProductButtonStyle())
            .tint(.white.opacity(0.4))
            .foregroundStyle(.primary)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .disabled(hasPurchased)
        }
    }
}

extension Product.SubscriptionInfo {
    var displaySubscriptionPeriod: String? {
        let unit = subscriptionPeriod.unit
        let numberOfUnits = subscriptionPeriod.value

        switch unit {
        case .day:
            return "\(numberOfUnits) 天"
        case .week:
            return "\(numberOfUnits) 周"
        case .month:
            return "\(numberOfUnits) 个月"
        case .year:
            return "\(numberOfUnits) 年"
        default:
            return "未知周期"
        }
    }
}
