//
//  RequestError.swift
//
//
//  Created by Jean-Louis Darmon on 31/08/2023.
//

import Foundation

public enum RequestError: LocalizedError {
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode(statusCode: String)
    case unknown
    case emptyRequest
    case invalidRegion

    public var errorDescription: String? {
        switch self {
        case .decode:
            return "Unable to decode data"
        case .unauthorized:
            return "Session expired"
        case .unexpectedStatusCode(let statusCode):
            return "Unexpected Status Code: \(statusCode)"
        default:
            return "Unknown Error"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .decode:
            return "Try again later"
        default:
            return "Unknown Error"
        }
    }
}
