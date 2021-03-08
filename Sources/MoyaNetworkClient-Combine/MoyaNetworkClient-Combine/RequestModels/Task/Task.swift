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
    case requestPlain(urlParameters: [String: Any]? = nil)
    case requestData(data: Data, urlParameters: [String: Any]? = nil)
    case requestParameters(requestBody: RequestBody?, urlParameters: [String: Any]? = nil)
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
            guard
                let requestBody = requestBody,
                let json = try? JSONSerialization.data(withJSONObject: requestBody.parameters, options: .withoutEscapingSlashes)
                else {
                    return nil
            }
            
            switch requestBody.encodingType {
            case .json:
                return json
            case .urlEncode:
                return String(data: json, encoding: .utf8)?.addingPercentEncoding(withAllowedCharacters: .httpBodyAllowed)?.data(using: .utf8)
            }
        }
    }
}


extension CharacterSet {
    public static var httpBodyAllowed: CharacterSet {
        return CharacterSet(charactersIn: " ^!*'();:@&=+$,/?%#[]")
    }
}
