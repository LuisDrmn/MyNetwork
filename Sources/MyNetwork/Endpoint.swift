//
//  Endpoint.swift
//
//
//  Created by Jean-Louis Darmon on 31/08/2023.
//

import Foundation

public protocol Endpoint {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var urlQueryItems: [URLQueryItem]? { get }
    var header: [String: String]? { get }
    var body: [String: String]? { get }
    var description: String { get }
}

public extension Endpoint {
    var scheme: String {
        "https"
    }

    var description: String {
        return "Scheme: \(scheme) Host: \(host) Path: \(path) Method: \(method.rawValue)"
    }
}
