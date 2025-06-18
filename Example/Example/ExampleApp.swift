//
//  ExampleApp.swift
//  Example
//
//  Created by hocgin on 2025/4/27.
//

import StoreKitHelper
import SwiftUI

//
enum AppProduct: String, InAppProduct {
    case monthly = "pro.of.month"
    case annual = "pro.of.year"
    case lifetime = "pro.of.permanent"
    var id: String { rawValue }
}

@main
struct ExampleApp: App {
    @StateObject var store = StoreContext(
        products: AppProduct.allCases
    ) { debugPrint("StoreContext.hasNotPurchased \($0)") }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onChange(of: store.hasNotPurchased) { hasNotPurchased in
                    debugPrint("更新购买状态 = \(!hasNotPurchased)")
                }
                .onAppear {
                    debugPrint("更新购买状态 = \(!store.hasNotPurchased)")
                }
        }
    }
}
