//
//  Task.swift
//  MoyaNetworkClient-Combine
//
//  Created by MSI on 26.05.2020.
//  Copyright © 2020 MSI. All rights reserved.
//

import Foundation

public typealias RequestBody = (parameters: [String : Any], encodingType: ParameterEncoding)

public enum Task {
    case requestPlain(urlParameters: [String: Any]?)
    case requestData(data: Data, urlParameters: [String: Any]?)
    case requestParameters(requestBody: RequestBody?, urlParameters: [String: Any]?)
}

extension Task {
    var getUrlParameters: [String : Any]? {
        switch self {
        case .requestPlain(urlParameters: let urlParameters),
             .requestData(data: _, urlParameters: let urlParameters),
             .requestParameters(requestBody: _, urlParameters: let urlParameters):
            return urlParameters
        }
    }
    
    var getHttpBody: Data? {
        switch self {
        case .requestPlain:
            return nil
        case .requestData(data: let data, urlParameters: _):
            return data
        case .requestParameters(requestBody: let requestBody, urlParameters: _):
            guard let requestBody = requestBody else { return nil }
            switch requestBody.encodingType {
            case .json:
                return try? JSONSerialization.data(withJSONObject: requestBody.parameters, options: .prettyPrinted)
            case .urlEncode:
                var requestBodyComponents = URLComponents()
                requestBodyComponents.queryItems = requestBody.parameters.reduce(into: []) { (result, element) in
                    result.append(URLQueryItem(name: element.key, value: element.value as? String))
                }
                return requestBodyComponents.query?.data(using: .utf8)
            }
        }
    }
}
