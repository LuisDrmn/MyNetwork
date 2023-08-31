//
//  HTTPClient.swift
//
//
//  Created by Jean-Louis Darmon on 31/08/2023.
//

import Foundation

public protocol HTTPClient {
    var isDebug: Bool { get }
    func sendRequest<T: Codable>(endpoint: Endpoint, responseModel: T.Type) async -> Result<T, RequestError>
}

public extension HTTPClient {
    var isDebug: Bool {
        return false
    }

    func makeNetworkRequest(with endpoint: Endpoint) -> Result<URLRequest, RequestError> {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme
        urlComponents.host = endpoint.host
        urlComponents.path = endpoint.path
        if let urlQueryItems = endpoint.urlQueryItems {
            urlComponents.queryItems = urlQueryItems
        }

        guard let url = urlComponents.url else {
            return .failure(.invalidURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.header
        if let body = endpoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        return .success(request)
    }

    func sendRequest<T: Codable>(endpoint: Endpoint, responseModel: T.Type) async -> Result<T, RequestError> {
        if isDebug {
            print("Request made on: \(endpoint.description)")
        }
        var request: URLRequest?

        let result = makeNetworkRequest(with: endpoint)

        switch result {
        case .success(let networkRequest):
            request = networkRequest
        case .failure(let error):
            return .failure(error)
        }
        guard let request = request else {
            return .failure(.emptyRequest)
        }

        do {
            var data: Data?
            var response: URLResponse?

            let (urlSessionData, urlSessionResponse) = try await URLSession.shared.data(for: request)
            if isDebug {
                print("JSON String: \(String(data: urlSessionData, encoding: .utf8) ?? "nil")")
            }
            data = urlSessionData
            response = urlSessionResponse

            guard let response = response as? HTTPURLResponse else {
                return .failure(.noResponse)
            }
            if isDebug {
                print("Request Success with response status code: \(response.statusCode)")
            }
            switch response.statusCode {
            case 200...299:
                guard let data = data, let decodedResponse = try? JSONDecoder().decode(responseModel, from: data) else {
                    return .failure(.decode)
                }
                return .success(decodedResponse)
            case 401:
                return .failure(.unauthorized)
            default:
                return .failure(.unexpectedStatusCode(statusCode: String(response.statusCode)))
            }
        } catch let error {
            if isDebug {
                print("Request Error with: \(error.localizedDescription)")
            }
            return .failure(.unknown)
        }
    }
}
