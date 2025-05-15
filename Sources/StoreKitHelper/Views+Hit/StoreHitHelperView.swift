//
//  SwiftUIView.swift
//  StoreKitHelper
//
//  Created by hocgin on 2025/4/27.
//

import RiveRuntime
import SwiftUI

public struct StoreHitHelperView: View {
    @Environment(\.pricingContent) var pricingContent
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: StoreContext
    @ObservedObject var viewModel = ProductsListViewModel()
    /// 正在`购买`中
    @State var buyingProductID: String? = nil
    /// `产品`正在加载中...
    @State var loadingProducts: ProductsLoadingStatus = .preparing
    /// 恢复购买中....
    @State var restoringPurchase: Bool = false

    /// ==========
    @StateObject var vipViewRive = RiveViewModel(
        fileName: "riv_crown",
        in: .module,
        animationName: "Timeline 1",
        fit: .contain,
        autoPlay: true,
        preferredFramesPerSecond: 60
    )
    @StateObject var confettiViewRive = RiveViewModel(
        fileName: "confetti",
        in: .module,
        animationName: "Confetti 1",
        fit: .contain,
        autoPlay: false
    )
    private let primaryColor: Color = .indigo

    let closeBtn: Bool
    public init(closeBtn: Bool = true) {
        self.closeBtn = closeBtn
    }

    public var body: some View {
        ProductsContentWrapper {
            ZStack {
                ImageContainerView("PayWall")
                    .edgesIgnoringSafeArea(.all)

                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        self.vipViewRive.view().padding(50)
                        self.confettiViewRive.view()
                    }
                    if self.store.hasNotPurchased {
                        VStack(spacing: .zero) {
                            VStack(spacing: .zero) {
                                TermsOfServiceView()
//                                Spacer(minLength: .zero)
                                ProductsLoadList(loading: self.$loadingProducts) {
                                    ProductsListView(
                                        buyingProductID: self.$buyingProductID,
                                        loading: self.$loadingProducts
                                    )
                                    .filteredProducts { productID, product in
                                        if let filteredProducts = viewModel.filteredProducts {
                                            return filteredProducts(productID, product)
                                        }
                                        return true
                                    }
                                    .disabled(self.restoringPurchase)
                                }
                                .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: .zero)
                            VStack {
                                VStack(alignment: .leading) {
                                    Text("·付款:用户确认购买并付款后记入iTunes账户;")
                                    Text("·续费:会员到期前24小时，苹果会自动为您从iTunes账户扣费，成功后有效期自动顺延一个周期;")
                                    Text("·取消续费:若需取消自动续费，请在到期前至少24小时手动在iTunes/AppleID设置管理中关闭，关闭后不再扣费;")
                                }
                                .font(.caption2)
                                .foregroundStyle(.gray.opacity(0.75))
                                Spacer(minLength: 4)

                                RestorePurchasesButtonView(restoringPurchase: self.$restoringPurchase)
                                    .disabled(self.buyingProductID != nil)
                                    .foregroundColor(self.primaryColor)
                                    .padding(.vertical)
                            }
//                            .padding(.top, 4)
                            .padding(.horizontal, 4)
                        }
                        .frame(alignment: .bottom)
                        .background(
                            LinearGradient(colors: [
                                self.primaryColor.opacity(0),
                                .black
                            ], startPoint: .top, endPoint: .bottom)
                        )
                    } else {
//                        ExpiredDateView(expirationDate: expirationDate)
                    }
                }
            }
        }
        .if(self.closeBtn) {
            $0.overlay(alignment: .top) {
                HStack {
                    Spacer(minLength: .zero)
                    Button { self.dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white)
                            .imageScale(.large)
                    }
                }
                .padding()
            }
        }
        .onChange(of: self.store.hasNotPurchased) { hasNotPurchased in
            self.triggerConfetti(hasNotPurchased)
        }
        .onAppear {
            self.triggerConfetti(self.store.hasNotPurchased)
        }
    }

    func triggerConfetti(_ hasNotPurchased: Bool) {
        if hasNotPurchased {
            self.confettiViewRive.stop()
        } else {
            self.confettiViewRive.play()
        }
    }

    struct ImageContainerView: View {
        var image: String
        init(_ image: String) {
            self.image = image
        }

        var body: some View {
            Color.clear
                .overlay(Image(self.image, bundle: .module)
                    .resizable()
                    .aspectRatio(contentMode: .fill))
                .clipped()
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<T: View>(_ condition: @autoclosure () -> Bool, then content: (Self) -> T) -> some View {
        if condition() {
            content(self)
        } else {
            self
        }
    }
}

public extension StoreContext {
    func askPurchased(_ action: () -> Void = {}) {
        if self.hasNotPurchased { action() }
    }
}
