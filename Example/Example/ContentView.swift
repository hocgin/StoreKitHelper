//
//  ContentView.swift
//  Example
//
//  Created by hocgin on 2025/4/27.
//

import StoreKitHelper
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: StoreContext
    @State var showStoreKitHelperView = false
    @State var showStoreHitHelperView = false

    var body: some View {
        VStack {
            Button(action: {
                showStoreKitHelperView.toggle()
            }, label: { Text("StoreKitHelperView") })
            Divider()
            Button(action: {
                showStoreHitHelperView.toggle()
            }, label: { Text("StoreHitHelperView") })
        }
        .sheet(isPresented: $showStoreKitHelperView) {
            StoreKitHelperView()
                .padding(.horizontal)
                // Triggered when the popup is dismissed (e.g., user clicks the close button)
                .onPopupDismiss {
                    store.isShowingPurchasePopup = false
                }
                // Sets the content area displayed in the purchase interface
                // (can include feature descriptions, version comparisons, etc.)
                .pricingContent {
                    AnyView(PricingContent())
                }
                .termsOfService {
                    // Action triggered when the [Terms of Service] button is clicked
                }
                .privacyPolicy {
                    // Action triggered when the [Privacy Policy] button is clicked
                }
        }
        .sheet(isPresented: $showStoreHitHelperView) {
            StoreHitHelperView()
                .termsOfService {
                    // Action triggered when the [Terms of Service] button is clicked
                }
                .privacyPolicy {
                    // Action triggered when the [Privacy Policy] button is clicked
                }
        }
    }

    struct PricingContent: View {
        var body: some View {
            Text("Pricing")
        }
    }
}
