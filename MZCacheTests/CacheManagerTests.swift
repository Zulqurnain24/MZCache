//
//  CacheManagerTests.swift
//  MZCacheTests
//
//  Created by Mohammad Zulqarnain on 25/12/2019.
//  Copyright © 2019 Binary Leaf Ltd. All rights reserved.
//

import XCTest
@testable import MZCache

class CacheManagerTests: XCTestCase {

    var cacheManager: CacheManager!
    
    override func setUp() {
        cacheManager = CacheManager.shared
    }
    
    func testUpdateCacheConfiguration() {
        testUpdateCacheConfiguration(with: .all, maxStoreSize: 3, cleanupPeriod: 0)
        testUpdateCacheConfiguration(with: .allCacheElementLastUsed(before: 5), maxStoreSize: 4, cleanupPeriod: 0)
        testUpdateCacheConfiguration(with: .allCacheElementUsedLess(thanCount: 5), maxStoreSize: 2, cleanupPeriod: 0)
        testUpdateCacheConfiguration(with: .leastRecentlyElement, maxStoreSize: 3, cleanupPeriod: 0)
    }
    
    func testUpdateCacheConfiguration(with cleanupType: CacheCleanupType, maxStoreSize: Int, cleanupPeriod: TimeInterval) {
        let cleanUpConfiguration = CacheCleanupConfigurationImpl(cleanupType: cleanupType, cleanUpPeriod: cleanupPeriod)
        let configuration = CacheConfigImpl(cleanupConfig: cleanUpConfiguration, maxStoreSize: maxStoreSize)
        
        cacheManager.updateCacheManager(configuration)
        
        let testConfiguration = cacheManager.configuration
        XCTAssertEqual(testConfiguration.maxStoreSize, maxStoreSize)
        
        let testCleanupConfiguration = testConfiguration.cleanupConfig
        XCTAssertEqual(testCleanupConfiguration.cleanUpPeriod, cleanupPeriod)
        
        XCTAssertEqual(testCleanupConfiguration.cleanupType, cleanupType)
        
    }
    
    func testNegativeCacheCleanupType() {
        XCTAssertNotEqual(CacheCleanupType.all, CacheCleanupType.leastRecentlyElement)
        XCTAssertNotEqual(CacheCleanupType.allCacheElementLastUsed(before: 5), CacheCleanupType.allCacheElementLastUsed(before: 4))
        XCTAssertNotEqual(CacheCleanupType.allCacheElementUsedLess(thanCount: 3), CacheCleanupType.allCacheElementUsedLess(thanCount: 2))
    }
    
    func setCacheManagerConfiguration(with cleanupConfiguration: CacheCleanupConfiguration = CacheCleanupConfigurationImpl.default(),
                                      storeSize: Int = 3) {
        let configuration = CacheConfigImpl(cleanupConfig: cleanupConfiguration, maxStoreSize: storeSize)
        cacheManager.updateCacheManager(configuration)
    }
    
    func testSetCacheElement() {
        
        cacheDummyData()
        
        XCTAssertEqual(cacheManager.getItem(url: "element1"), Data(count: 10))
    }
    
    func cacheDummyData() {
        cacheManager.set(key: "element1", item: Data(count: 10))
        cacheManager.set(key: "element2", item: Data(count: 10))
        cacheManager.set(key: "element3", item: Data(count: 10))
        
        cacheManager.set(totalRequestCount: 10, for: "element1")
        cacheManager.set(totalRequestCount: 2, for: "element2")
        cacheManager.set(totalRequestCount: 1, for: "element3")
    }
    
    func testIsCacheFull() {
        
        setCacheManagerConfiguration()
        cacheDummyData()
        
        XCTAssertTrue(cacheManager.isCacheStoreFull)
        
        XCTAssertEqual(cacheManager.getItem(url: "element1"), Data(count: 10))
        
        cacheManager.removeCacheItems()
        XCTAssertFalse(cacheManager.isCacheStoreFull)
    }

    func testClearAllCache() {
        let cleanUpConfiguration = CacheCleanupConfigurationImpl(cleanupType: .all, cleanUpPeriod: 0)
        setCacheManagerConfiguration(with: cleanUpConfiguration)
        
        cacheDummyData()
        
        XCTAssertTrue(cacheManager.isCacheStoreFull)
        XCTAssertEqual(cacheManager.storageOccupiedSpace, 3)
        
        cacheManager.removeCacheItems()
        XCTAssertFalse(cacheManager.isCacheStoreFull)
        XCTAssertEqual(cacheManager.storageOccupiedSpace, 0)
    }

    func testClearCacheBasedOnUsedLessThanCount() {
        let cleanUpConfiguration = CacheCleanupConfigurationImpl(cleanupType: .allCacheElementUsedLess(thanCount: 10), cleanUpPeriod: 0)
        setCacheManagerConfiguration(with: cleanUpConfiguration)
        
        cacheDummyData()
        
        XCTAssertTrue(cacheManager.isCacheStoreFull)
        XCTAssertEqual(cacheManager.storageOccupiedSpace, 3)
        
        cacheManager.removeCacheItems()
        XCTAssertFalse(cacheManager.isCacheStoreFull)
        XCTAssertEqual(cacheManager.storageOccupiedSpace, 1)
        XCTAssertNil(cacheManager.getItem(url: "element3"))
        XCTAssertNil(cacheManager.getItem(url: "element2"))
        XCTAssertNotNil(cacheManager.getItem(url: "element1"))
    }
    
    func testClearCacheBasedOnUsedBeforeTimeInterval() {
        let cleanUpConfiguration = CacheCleanupConfigurationImpl(cleanupType: .allCacheElementLastUsed(before: 3), cleanUpPeriod: 0)
        setCacheManagerConfiguration(with: cleanUpConfiguration)
        
        cacheDummyData()
        
        XCTAssertTrue(cacheManager.isCacheStoreFull)
        XCTAssertEqual(cacheManager.storageOccupiedSpace, 3)
        
        sleep(4)
        _ = cacheManager.getItem(url: "element3")
        
        cacheManager.removeCacheItems()
        XCTAssertFalse(cacheManager.isCacheStoreFull)
        XCTAssertEqual(cacheManager.storageOccupiedSpace, 1)
        XCTAssertNotNil(cacheManager.getItem(url: "element3"))
        XCTAssertNil(cacheManager.getItem(url: "element2"))
        XCTAssertNil(cacheManager.getItem(url: "element1"))
    }
    
    func testClearCacheBasedOnUsedLeastNearly() {
        let cleanUpConfiguration = CacheCleanupConfigurationImpl(cleanupType: .leastRecentlyElement, cleanUpPeriod: 0)
        setCacheManagerConfiguration(with: cleanUpConfiguration)
        
        cacheDummyData()
        
        XCTAssertTrue(cacheManager.isCacheStoreFull)
        XCTAssertEqual(cacheManager.storageOccupiedSpace, 3)
        sleep(2)
        _ = cacheManager.getItem(url: "element1")
        sleep(2)
        _ = cacheManager.getItem(url: "element3")
        
        cacheManager.removeCacheItems()
        XCTAssertFalse(cacheManager.isCacheStoreFull)
        XCTAssertEqual(cacheManager.storageOccupiedSpace, 2)
        XCTAssertNotNil(cacheManager.getItem(url: "element3"))
        XCTAssertNil(cacheManager.getItem(url: "element2"))
        XCTAssertNotNil(cacheManager.getItem(url: "element1"))
    }
 
}

