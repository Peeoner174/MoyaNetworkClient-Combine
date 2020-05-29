//
//  RequestHeader.swift
//  MoyaNetworkClient-Combine
//
//  Created by MSI on 26.05.2020.
//  Copyright © 2020 MSI. All rights reserved.
//

import Foundation

public protocol RequestHeader {
    var name: String { get }
    var content: String { get }
    var rawValue: [String : String] { get }
}

extension RequestHeader {
    public var rawValue: [String : String] {
        return [self.name : self.content]
    }
}
