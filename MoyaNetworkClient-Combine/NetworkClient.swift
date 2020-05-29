//
//  NetworkClient.swift
//  MoyaNetworkClient-Combine
//
//  Created by MSI on 26.05.2020.
//  Copyright © 2020 MSI. All rights reserved.
//

import Foundation
#if canImport(Combine)
import Combine
#endif

public typealias VoidResultCompletion = (Result<Response, ProviderError>) -> Void

public final class NetworkClient {
    
    private let jsonDecoder: JSONDecoder
    
    public init(jsonDecoder: JSONDecoder, urlSession: URLSession = URLSession.shared) {
        self.jsonDecoder = jsonDecoder
    }
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
    public func request<D, S>(
        _ target: NetworkTarget,
        urlSession: URLSession = URLSession.shared,
        scheduler: S,
        class type: D.Type
    ) -> AnyPublisher<D, ProviderError> where D: Decodable, S: Scheduler {
        
        let urlRequest = createRequest(target)
        
        return urlSession.dataTaskPublisher(for: urlRequest).tryCatch { error -> URLSession.DataTaskPublisher in
            guard error.networkUnavailableReason == .constrained else {
                throw ProviderError.connectionError(error)
            }
            return urlSession.dataTaskPublisher(for: urlRequest)
        }
        .receive(on: scheduler)
        .tryMap { data, response -> Data in
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ProviderError.invalidServerResponse
            }
            if !httpResponse.isSuccessful {
                throw ProviderError.invalidServerResponseWithStatusCode(statusCode: httpResponse.statusCode)
            }
            
            if let keyPath = target.keyPath {
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
                    throw ProviderError.serializationError(toType: "JSON")
                }
                guard let _ = json[dict: DictionaryKeyPath(keyPath)] else {
                    throw ProviderError.bodyResponseNotContaint(keyPath: keyPath)
                }
                guard let dataAtKeyPath = try? JSONSerialization.data(withJSONObject: json[keyPath]!, options: []) else {
                    throw ProviderError.serializationError(toType: "Data")
                }
                return dataAtKeyPath
            } else {
                return data
            }
        }
        .decode(type: type.self, decoder: jsonDecoder).mapError { error in
            if let error = error as? ProviderError {
                return error
            } else {
                return ProviderError.decodingError(error)
            }
        }.eraseToAnyPublisher()
    }
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
    func request<D, S, T>(
        _ target: NetworkTarget,
        class type: D.Type,
        urlSession: URLSession = URLSession.shared,
        jsonDecoder: JSONDecoder = .init(),
        scheduler: T,
        subscriber: S
    ) where S: Subscriber, T: Scheduler, D: Decodable, S.Input == D, S.Failure == ProviderError {
        
        let urlRequest = createRequest(target)
        
        return urlSession.dataTaskPublisher(for: urlRequest).tryCatch { error -> URLSession.DataTaskPublisher in
            guard error.networkUnavailableReason == .constrained else {
                throw ProviderError.connectionError(error)
            }
            return urlSession.dataTaskPublisher(for: urlRequest)
        }
        .receive(on: scheduler)
        .tryMap { data, response -> Data in
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ProviderError.invalidServerResponse
            }
            if !httpResponse.isSuccessful {
                throw ProviderError.invalidServerResponseWithStatusCode(statusCode: httpResponse.statusCode)
            }
            
            if let keyPath = target.keyPath {
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
                    throw ProviderError.serializationError(toType: "JSON")
                }
                guard let _ = json[dict: DictionaryKeyPath(keyPath)] else {
                    throw ProviderError.bodyResponseNotContaint(keyPath: keyPath)
                }
                guard let dataAtKeyPath = try? JSONSerialization.data(withJSONObject: json[keyPath]!, options: []) else {
                    throw ProviderError.serializationError(toType: "Data")
                }
                return dataAtKeyPath
            } else {
                return data
            }
        }
        .decode(type: type.self, decoder: jsonDecoder).mapError { error in
            if let error = error as? ProviderError {
                return error
            } else {
                return ProviderError.decodingError(error)
            }
        }.eraseToAnyPublisher().subscribe(subscriber)
    }
}

// MARK: - Public Extensions

public extension NetworkClient {
    func request<D>(
        _ target: NetworkTarget,
        urlSession: URLSession = URLSession.shared,
        class type: D.Type
    ) -> AnyPublisher<D, ProviderError> where D: Decodable {
        return request(target, scheduler: DispatchQueue.global(), class: type)
    }
    
    func request<D, S>(
        _ target: NetworkTarget,
        class type: D.Type,
        urlSession: URLSession = URLSession.shared,
        jsonDecoder: JSONDecoder = .init(),
        subscriber: S
    ) where S: Subscriber, D: Decodable, S.Input == D, S.Failure == ProviderError {
        return request(target, class: type, urlSession: urlSession, jsonDecoder: jsonDecoder, scheduler: DispatchQueue.global(), subscriber: subscriber)
    }
}

// MARK: - Private Extensions

private extension NetworkClient {
    private func createRequest(_ target: NetworkTarget) -> URLRequest {
        let url: URL = {
            var url = target.baseURL
            url.appendPathComponent(target.route.path)
            guard let urlParameters = target.task.getUrlParameters else { return url }
            return url.generateUrlWithQuery(with: urlParameters)
        }()
        
        let request: URLRequest = {
            var request = URLRequest(url: url)
            request.httpMethod = target.route.method.rawValue
            if target.route.method == .post { request.httpBody = target.task.getHttpBody }
            target.headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key)}
            return request
        }()
        
        return request
    }
}

