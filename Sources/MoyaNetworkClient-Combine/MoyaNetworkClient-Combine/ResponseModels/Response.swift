//
//  Response.swift
//  MoyaNetworkClient-Combine
//
//  Created by MSI on 26.05.2020.
//  Copyright © 2020 MSI. All rights reserved.
//

import Foundation

public struct Response {
    let urlResponse: HTTPURLResponse
    let data: Data
    var statusCode: Int {
        return urlResponse.statusCode
    }
    var localizedStatusCodeDescription: String {
        return HTTPURLResponse.localizedString(forStatusCode: statusCode)
    }
}
