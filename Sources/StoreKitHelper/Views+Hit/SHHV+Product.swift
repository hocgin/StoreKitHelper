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
                            discount: product.discountInfo,
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
                        discount: product.discountInfo,
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
        var discount: String?
        var hasPurchased: Bool
        var purchase: () -> Void
        var body: some View {
            Button { purchase() } label: {
                ZStack(alignment: .topTrailing) {
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
                    if let discount {
                        Text("\(discount)")
                            .font(.caption2)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 4)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(2)
                            .offset(x: 2, y: -2)
                    }
                }
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

extension Product {
    var discountInfo: String? {
        // 首先尝试获取初始优惠
        if let offer = subscription?.introductoryOffer {
            return formatDiscount(offer: offer, basePrice: price)
        }

        // 如果没有初始优惠，可以选取 discounts（如 AdHocOffer）
        if let offer = subscription?.promotionalOffers.first {
            return formatDiscount(offer: offer, basePrice: price)
        }

        return nil // 没有可用优惠
    }

    var displayOfferPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        if let offer = subscription?.introductoryOffer {
            return formatter.string(from: offer.price as NSNumber) ?? "\(offer.price)"
        }

        // 如果没有初始优惠，可以选取 discounts（如 AdHocOffer）
        if let offer = subscription?.promotionalOffers.first {
            return formatter.string(from: offer.price as NSNumber) ?? "\(offer.price)"
        }
        return nil // 没有可用优惠
    }

    func formatDiscount(offer: Product.SubscriptionOffer, basePrice: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current

        let formattedPrice = formatter.string(from: offer.price as NSNumber) ?? "\(offer.price)"
        let baseFormatted = formatter.string(from: basePrice as NSNumber) ?? "\(basePrice)"

        switch offer.paymentMode {
        case .payAsYouGo:
            if offer.period.value == 1 {
                return "首\(offer.period.unit.localDesc)仅需 \(formattedPrice)"
            }
            return "前\(offer.period.value)\(offer.period.unit.localDesc)仅需 \(formattedPrice)"
        case .payUpFront:
            if offer.period.value == 1 {
                return "首\(offer.period.unit.localDesc)仅需 \(formattedPrice)"
            }
            return "前\(offer.period.value)\(offer.period.unit.localDesc)仅需 \(formattedPrice)"
        case .freeTrial:
            return "\(offer.period.value)\(offer.period.unit.localDesc)免费试用"
        default:
            return "限时优惠：\(formattedPrice)"
        }
    }
}

// extension Product.SubscriptionPeriod {
//    var displayString: String {
//        switch unit {
//        case .day: return "\(value) 天"
//        case .week: return value == 1 ? "首周" : "\(value) 周"
//        case .month: return value == 1 ? "首月" : "\(value) 月"
//        case .year: return value == 1 ? "首年" : "\(value) 年"
//        @unknown default: return "\(value) 单位未知"
//        }
//    }
// }

extension Product.SubscriptionInfo {
    var displaySubscriptionPeriod: String? {
        let unit = subscriptionPeriod.unit
        let numberOfUnits = subscriptionPeriod.value
        return "\(numberOfUnits) \(unit.localDesc)"
    }
}

extension Product.SubscriptionPeriod.Unit {
    var localDesc: String {
        switch self {
        case .day:
            return "天"
        case .week:
            return "周"
        case .month:
            return "月"
        case .year:
            return "年"
        default:
            return ""
        }
    }
}

#Preview {
    VStack {
        let _ = debugPrint("\(Product.SubscriptionPeriod.Unit.day.localizedDescription)")
        StoreHitHelperView.ProductsListLabelView(isBuying: .constant(false), productId: "", displayPrice: "2.0", displayName: "测试", description: "备注", hasPurchased: false, purchase: {})
        Text("¥10.00")
            .font(.system(size: 6))
            .strikethrough(true, color: .gray)
            .foregroundStyle(.gray)
            +
            Text("¥1.00")

            +
            Text(" / Month").font(.system(size: 10))

        Button {} label: {
            VStack {
                VStack {
                    Text(verbatim: "专业版")
                        .font(.headline)
                    Text("¥1.00") + Text(" / Month").font(.system(size: 10))
                }
                .font(.footnote)
                Text("¥10.00")
                    .font(.system(size: 8))
                    .strikethrough(true, color: .gray)
                    .foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(StoreHitHelperView.ProductButtonStyle())
        .tint(.white.opacity(0.4))
        .foregroundStyle(.primary)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
    }
    .foregroundStyle(.white)
//    .background(.black)
}
