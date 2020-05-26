//
//  ProviderError.swift
//  MoyaNetworkClient-Combine
//
//  Created by MSI on 26.05.2020.
//  Copyright © 2020 MSI. All rights reserved.
//

import Foundation

public enum ProviderError: Error {
    // response status
    case invalidServerResponseWithStatusCode(statusCode: Int)
    case invalidServerResponse
    case missingBodyData
    
    // decode
    case decodingError(Error)
    case serializationError(toType: String)
    case bodyResponseNotContaint(keyPath: String)
    case failedToDecodeImage
    
    // connection
    case connectionError(Error)
    case underlying(Error)
}

public extension ProviderError {
     var errorDescription: String {
        switch self {
        case .invalidServerResponse:
            return "Failed to parse the response to HTTPResponse"
        case .connectionError(let error):
            return "Network connection seems to be offline: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding problem: \(error.localizedDescription)"
        case .underlying(let error):
            return error.localizedDescription
        case .invalidServerResponseWithStatusCode(let statusCode):
            return "The server response didn't fall in the given range Status Code is: \(statusCode)"
        case .missingBodyData:
            return "No body data provided from the server"
        case .failedToDecodeImage:
            return "the body doesn't contain a valid data."
        case .serializationError(let type):
            return "Failed serialization type: \(type)"
        case .bodyResponseNotContaint(let keyPath):
            return "Response JSON not contain value by key path: \(keyPath)"
        }
    }
}
