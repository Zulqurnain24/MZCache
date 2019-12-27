//
//  CacheItem.swift
//  MZCacheTests
//
//  Created by Mohammad Zulqarnain on 25/12/2019.
//  Copyright © 2019 Binary Leaf Ltd. All rights reserved.
//

import Foundation
@testable import MZCache

extension CacheManager {
    
    func set(totalRequestCount: Int,for key: String) {
        for _ in 0 ..< totalRequestCount {
            _ = CacheManager.shared.getItem(url: key)
        }
    }
}
