//
//  CacheElement.swift
//  MZCache
//
//  Created by Mohammad Zulqarnain on 25/12/2019.
//  Copyright © 2019 Binary Leaf Ltd. All rights reserved.
//

import Foundation

public class CacheManager {
    
    public static let shared = CacheManager(configuration: CacheConfigImpl.default())
    fileprivate let queue = DispatchQueue(label: "SynchronizedDictionary", attributes: .concurrent)
    
    public var configuration: CacheConfig
    private var cached: [String: CacheItem] = [:]
    private var timer: Timer?
    
    /// Returns bool value that relies on data stored in cache - false means not full,  true means full.
    public var isCacheStoreFull: Bool {
        var isFull: Bool = false
        queue.sync {
            isFull = cached.count >= configuration.maxStoreSize
        }
        return isFull
    }
    
    /// Return Int value which is current cache size
    public var storageOccupiedSpace: Int {
        var spaceOccupied: Int = 0
        queue.sync {
            spaceOccupied = cached.count
        }
        return spaceOccupied
    }
    
    /// Initializer for creating CacheManager
    ///
    /// - Parameter configuration: Contains setting required for initiating  Cache size and removal of items policy.
    private init(configuration: CacheConfig) {
        
        self.configuration = configuration
        setupTemporalCacheClear()
    }
    
    /// This is a private method responsible for clearing up cache based on timer, cache ca be configured to auto clear the data depening on timer
    private func setupTemporalCacheClear() {
        if configuration.cleanupConfig.cleanUpPeriod != 0 {
            timer = Timer.scheduledTimer(withTimeInterval: configuration.cleanupConfig.cleanUpPeriod, repeats: true) {[weak self] (_) in
                
                guard let self = self else { return }
                self.removeCacheItems()
            }
        }
    }
    
    /// After creating Cache Manager object `Cache Setting` from here.
    ///
    /// - Parameter configuration: Updated `Cache configuration`.
    public func updateCacheManager(_ configuration: CacheConfig) {
        self.configuration = configuration
        timer?.invalidate()
        setupTemporalCacheClear()
    }
    
    /// Set item in Cache.
    /// If Cache is alredady full before storing an item then apply deletion of item policy first - Based on Cache Cleanup setting provided.
    ///
    /// - Parameters:
    ///   - key: Key against which data will be stored
    ///   - item: The item needed to be cached.
    public func set(key: String, item: Data) {
        var cachedItem = cached[key]
        
        if cachedItem == nil, isCacheStoreFull {
            removeCacheItems()
        }
        
        queue.sync {
            cachedItem = CacheItemImpl(key: key, item: item)
            cached[key] = cachedItem
        }
    }
    
    /// Return value against consecutive key i.e. URL
    ///
    /// - Parameter url: Resource URL String
    /// - Returns: Gives Cached data if exist.
    public func getItem(url: String) -> Data? {
        
        var data: Data?
        queue.sync {
            data = cached[url]?.getItem()
        }
        return data
    }
    
    /// It clears item from cache If cache is full.
    /// Deletion of item is based on cache config policy
    public func removeCacheItems() {
        queue.sync {
            if isCacheStoreFull {
                switch configuration.cleanupConfig.cleanupType {
                case .all:
                    clearAllCacheElements()
                case .allCacheElementLastUsed(let before):
                    clearCacheElement(usedBefore: before)
                case .allCacheElementUsedLess(thanCount: let count):
                    clearCacheElement(usedLessThan: count)
                case .leastRecentlyElement:
                    removeLeastRecentlyElement()
                }
            }
        }
    }
    
    /// It removes all data which is cached when cache is full
    private func clearAllCacheElements() {
        
        cached.removeAll()
    }
    
    /// It deletes all cached value stored before TimeInterval
    ///
    /// - Parameter timeInterval: time before which all cached items must be removed
    private func clearCacheElement(usedBefore timeInterval: TimeInterval) {
        
        let seedDate = Date().addingTimeInterval(-1 * timeInterval)
        
        for itemKey in cached.keys {
            if let cacheditem = cached[itemKey] ,
                cacheditem.lastAccessTimeStamp < seedDate {
                
                cached.removeValue(forKey: itemKey)
            }
        }
    }
    
    /// It removes all the cache values beyond given count.
    ///
    /// - Parameter count: Deletes Cache used less than provided count.
    private func clearCacheElement(usedLessThan count: Int) {
        
        for itemKey in cached.keys {
            if let cacheditem = cached[itemKey],
                cacheditem.requestCount < count {
                
                cached.removeValue(forKey: itemKey)
            }
        }
    }
    
    /// Here most least used element from cache are removed
    private func removeLeastUsedElement() {
        
        var leastElementKey: String?
        var frequencyTime = Int.max
        for itemKey in cached.keys {
            if let cacheditem = cached[itemKey] ,
                cacheditem.requestCount < frequencyTime {
                
                leastElementKey = itemKey
                frequencyTime = cacheditem.requestCount
            }
        }
        if let leastElementKey = leastElementKey {
            cached.removeValue(forKey: leastElementKey)
        }
    }
    
    /// Here most least recently used element from cache are removed
    private func removeLeastRecentlyElement() {
        
        var leastRequestedKey: String?
        var smallestTime: Date?
        for itemKey in cached.keys {
            if let cacheditem = cached[itemKey] {
                
                if let leastRequestedTime = smallestTime {
                    if cacheditem.lastAccessTimeStamp < leastRequestedTime {
                        leastRequestedKey = itemKey
                        smallestTime = cacheditem.lastAccessTimeStamp
                    }
                } else {
                    smallestTime = cacheditem.lastAccessTimeStamp
                }
            }
        }
        
        if let leastRequestedKey = leastRequestedKey {
            cached.removeValue(forKey: leastRequestedKey)
        }
    }
}

