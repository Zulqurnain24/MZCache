//
//  CacheConfiguration.swift
//  MZCache
//
//  Created by Mohammad Zulqarnain on 25/12/2019.
//  Copyright © 2019 Binary Leaf Ltd. All rights reserved.
//

import Foundation

/// Used for defining cache settings which will be required by cache manager
public protocol CacheConfig {
    var maxStoreSize: Int { get set }
    var cleanupConfig: CacheCleanupConfiguration {get set}
}

public extension CacheConfig {
    /// Initial implementation for cache Setting.
    ///
    /// - Returns: Instance of Cache Setting with default values.
    static func `default`() -> CacheConfig {
        return CacheConfigImpl()
    }
}

public struct CacheConfigImpl: CacheConfig {
    /// Contains Cache cleanup Policies.
    public var cleanupConfig: CacheCleanupConfiguration = CacheCleanupConfigurationImpl.default()

    /// Contains Cache Store Capacity.
    public var maxStoreSize: Int = CacheConfigConstants.defaultStoreSize
}
