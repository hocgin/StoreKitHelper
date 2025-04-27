//
//  Bundle+.swift
//  AWeather
//
//  Created by hocgin on 2025/3/20.
//

import Foundation

private class BundleFinder {}

public extension Foundation.Bundle {
    /// Returns the resource bundle associated with the current Swift module.
    static let storekit: Bundle = .module
}
