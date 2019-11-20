//
//  Post.swift
//  Post.
//
//  Created by Anthony Torres on 11/19/19.
//  Copyright © 2019 Anthony Torres. All rights reserved.
//

import Foundation

struct Post: Codable {
    let username: String
    let text: String
    let timestamp: TimeInterval
    var queryTimestamp: TimeInterval {
        return timestamp - 0.00001
    }
    
    init(username: String, text: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
}
