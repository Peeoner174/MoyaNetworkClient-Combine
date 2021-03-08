//
//  ContentType.swift
//  MoyaNetworkClient-Combine
//
//  Created by MSI on 26.05.2020.
//  Copyright © 2020 MSI. All rights reserved.
//

import Foundation

public enum ContentType: RequestHeader {
    case applicationJson
    case urlFormEncoded
    case multipartFormData
    
    public var name: String {
        return "Content-Type"
    }
    
    public var content: String {
        switch self {
        case .applicationJson:
            return "application/json"
        case .urlFormEncoded:
            return "application/x-www-form-urlencoded"
        case .multipartFormData:
            return "multipart/form-data"
        }
    }
}
