//
//  CacheCleanupConfiguration.swift
//  MZCache
//
//  Created by Mohammad Zulqarnain on 25/12/2019.
//  Copyright © 2019 Binary Leaf Ltd. All rights reserved.
//

import Foundation

/// Needed for initiating cache Item removal policy
///
/// - all: Remove all items from the Cache
/// - allCacheElementUsedLess: Clean all the elements which are comparatively used less
/// - allCacheElementLastUsed: Remove all items before defined time interval
/// - leastRecentlyElement: Should remove least recently used item

public enum CacheCleanupType: Equatable {
    case all
    case allCacheElementUsedLess (thanCount: Int)
    case allCacheElementLastUsed (before: TimeInterval)
    case leastRecentlyElement
    
    /// Used to equat 2 CacheCleanupType Values.
    ///
    /// - Parameters:
    ///   - lhs: Comparision Value 1 - LeftHand Side value
    ///   - rhs: Comparision Value 2 - RightHand Side value
    /// - Returns: Should return true if both are same.
    public static func == (lhs: CacheCleanupType, rhs: CacheCleanupType) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all):
            return true
        case (.leastRecentlyElement, .leastRecentlyElement):
            return true
        case (.allCacheElementUsedLess(let lhsCount), .allCacheElementUsedLess(let rhsCount)):
            return lhsCount == rhsCount
        case (.allCacheElementLastUsed(let lhsTimeInterval), .allCacheElementLastUsed(let rhsTimeInterval)):
            return lhsTimeInterval == rhsTimeInterval
        default:
            return false
        }
    }
}

public protocol CacheCleanupConfiguration {
    var cleanupType: CacheCleanupType {get set}
    var cleanUpPeriod: TimeInterval {get set}
}

public extension CacheCleanupConfiguration {
    /// It provides default implementation for cache Cleanup Configuration.
    ///
    /// - Returns: Object of CacheCleanup Configuration with default values.
    static func `default`() -> CacheCleanupConfiguration {
        return CacheCleanupConfigurationImpl()
    }
}

public struct CacheCleanupConfigurationImpl: CacheCleanupConfiguration {
    /// Used to define default type for cacheCleanup
    /// Default value is leastRecentlyUsed
    public var cleanupType: CacheCleanupType = .leastRecentlyElement
    /// Used to define value if cache need to be cleared automatically, else set to 0.
    /// Default value is 0
    public var cleanUpPeriod: TimeInterval = CacheConfigConstants.defaultUpdatePeriod
}

