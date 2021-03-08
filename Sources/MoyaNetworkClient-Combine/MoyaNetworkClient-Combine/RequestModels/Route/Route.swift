//
//  Route.swift
//  MoyaNetworkClient-Combine
//
//  Created by MSI on 26.05.2020.
//  Copyright © 2020 MSI. All rights reserved.
//

import Foundation

public enum Route {
    case get(String)
    case post(String)
    case put(String)
    case delete(String)
    case patch(String)

    public var path: String {
        switch self {
        case .get(let path): return path
        case .post(let path): return path
        case .put(let path): return path
        case .delete(let path): return path
        case .patch(let path): return path
        }
    }

    public var method: MethodType {
        switch self {
        case .get: return .get
        case .post: return .post
        case .put: return .put
        case .delete: return .delete
        case .patch: return .patch
        }
    }
}
