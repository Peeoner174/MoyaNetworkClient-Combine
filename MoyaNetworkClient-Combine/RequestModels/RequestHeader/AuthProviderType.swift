//
//  AuthProviderType.swift
//  MoyaNetworkClient-Combine
//
//  Created by MSI on 26.05.2020.
//  Copyright © 2020 MSI. All rights reserved.
//

import Foundation

public enum AuthProviderType: RequestHeader {
    case bearer(token: String)
    case basic(username: String, password: String)
    
    var name: String {
        return "Authorization"
    }
    
    var content: String {
        switch self {
        case .basic(username: let username, password: let password):
            let loginString = String(format: "%@:%@", username, password)
            guard let data = loginString.data(using: .utf8) else {
                #if DEBUG
                fatalError("Failed set Authorization header content")
                #else
                return ""
                #endif
            }
            return "Basic \(data.base64EncodedString())"
        case .bearer(token: let token):
            return "Bearer \(token)"
        }
    }
}

