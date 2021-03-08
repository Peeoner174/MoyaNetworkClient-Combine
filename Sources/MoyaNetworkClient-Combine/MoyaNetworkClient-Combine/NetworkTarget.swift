//
//  NetworkTarget.swift
//  MoyaNetworkClient-Combine
//
//  Created by MSI on 26.05.2020.
//  Copyright © 2020 MSI. All rights reserved.
//

import Foundation

public protocol NetworkTarget {
    
    /// The target's base `URL`.
    var baseURL: URL { get }
    
    /// Contains HTTP method and URL path information.
    var route: Route { get }
    
    /// The type of HTTP task to be performed.
    var task: Task { get }
    
    /// The headers to be used in the request.
    var headers: [String: String]? { get }
    
    /// Used to parse Codable on this key.
    var keyPath: String? { get }
}

public extension NetworkTarget {
    var keyPath: String? { nil }
}
