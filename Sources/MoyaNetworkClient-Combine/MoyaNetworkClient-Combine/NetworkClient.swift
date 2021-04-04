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

public enum StubBehavior: Equatable {
    case never
    case immediate
    case delayed(seconds: TimeInterval)
    case withMockServer
}

public typealias VoidResultCompletion = (Result<Response, ProviderError>) -> Void

public final class NetworkClient {
    
    private let jsonDecoder: JSONDecoder
    private let stubBehaviour: StubBehavior
    
    public init(jsonDecoder: JSONDecoder, urlSession: URLSession = URLSession.shared, stubBehaviour: StubBehavior = .never) {
        self.jsonDecoder = jsonDecoder
        self.stubBehaviour = stubBehaviour
    }
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
    public func request<D, S>(
        _ target: NetworkTarget,
        urlSession: URLSession = URLSession.shared,
        scheduler: S,
        class type: D.Type
    ) -> AnyPublisher<D, ProviderError> where D: Decodable, S: Scheduler {
        
        switch stubBehaviour {
        case .never, .withMockServer:
            return performNetworkRequest(target, urlSession: urlSession, scheduler: scheduler, class: type)
        case .delayed(seconds: let seconds):
            return performStubFileRequest(target, scheduler: scheduler, class: type)
                .delay(for: .seconds(seconds), scheduler: scheduler)
                .eraseToAnyPublisher()
        case .immediate:
            return performStubFileRequest(target, scheduler: scheduler, class: type)
        }
    }
    
    private func performNetworkRequest<D, S>(
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
                do {
                    return try self.getDataByKeyPath(data, keyPath).get()
                } catch {
                    throw error
                }
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
    
    private func performStubFileRequest<D, S>(
        _ target: NetworkTarget,
        scheduler: S,
        class type: D.Type
 ) -> AnyPublisher<D, ProviderError> where D: Decodable, S: Scheduler {
        guard let fileMockTarget = target as? FileStubbable else {
            return performNetworkRequest(target, scheduler: scheduler, class: type)
        }
        guard let data = fileMockTarget.stubbedResponse(fileMockTarget.stubbedFileName) else {
            return Result<D, ProviderError>
                .failure(.invalidStubFileURI(fileMockTarget.stubbedFileName))
                .publisher
                .eraseToAnyPublisher()
        }
        return Result<Data, ProviderError>
            .success(data)
            .publisher
            .tryMap { data  -> Data in
                if let keyPath = target.keyPath {
                    do {
                        return try getDataByKeyPath(data, keyPath).get()
                    } catch {
                        throw error
                    }
                } else {
                    return data
                }
            }
            .decode(type: type, decoder: jsonDecoder)
            .mapError { error in
                if let error = error as? ProviderError {
                    return error
                } else {
                    return ProviderError.decodingError(error)
                }
            }.eraseToAnyPublisher()
    }
    
    private func getDataByKeyPath(_ data: Data, _ keyPath: String) throws -> Result<Data, ProviderError> {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
            throw ProviderError.serializationError(toType: "JSON")
        }
        guard let jsonObject = json[dict: DictionaryKeyPath(keyPath)] else {
            throw ProviderError.bodyResponseNotContaint(keyPath: keyPath)
        }
        guard let dataAtKeyPath = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) else {
            throw ProviderError.serializationError(toType: "Data")
        }
        return .success(dataAtKeyPath)
    }
}

// MARK: - Public Extensions

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, macCatalyst 13.0, *)
public extension NetworkClient {
    func request<D, S, T>(
        _ target: NetworkTarget,
        class type: D.Type,
        urlSession: URLSession = URLSession.shared,
        jsonDecoder: JSONDecoder = .init(),
        scheduler: T,
        subscriber: S
    ) where S: Subscriber, T: Scheduler, D: Decodable, S.Input == D, S.Failure == ProviderError {
        self.request(target, urlSession: urlSession, scheduler: scheduler, class: type).subscribe(subscriber)
    }
    
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
            var url: URL
            if stubBehaviour == .withMockServer, let serverMockTarget = target as? ServerStubable {
                url = serverMockTarget.mockBaseUrl
            } else {
                url = target.baseURL
            }
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
