//
//  CacheElement.swift
//  MZCache
//
//  Created by Mohammad Zulqarnain on 25/12/2019.
//  Copyright © 2019 Binary Leaf Ltd. All rights reserved.
//

import Foundation

/// CacheItem is a data structure that contains cached data.
protocol CacheItem {
    
    var requestCount: Int {get}
    var lastAccessTimeStamp: Date {get}
    mutating func getItem() -> Data
}

struct CacheItemImpl: CacheItem {
    
    /// Key for data storage
    private let key: String
    /// Cached Item
    private let item: Data
    /// Storage or update date
    private let createdTimeStamp: Date
    /// Last access date
    private(set) var lastAccessTimeStamp: Date
    /// Number of total requests made
    private(set) var requestCount: Int = 0
    
    init(key: String, item: Data) {
        self.key = key
        self.item = item
        self.lastAccessTimeStamp = Date()
        self.createdTimeStamp = Date()
    }
    
    /// It fetches the cached item and updates the last access time stamp and total requests count
    ///
    /// - Returns: Data cached.
    mutating func getItem() -> Data {
        requestCount += 1
        self.lastAccessTimeStamp = Date()
        return item
    }
    
}
