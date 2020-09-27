//
//  API.swift
//  Covid-ID
//
//  Created by Teddy Santya on 1/5/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import Foundation

typealias ArrayModel = Identifiable & Decodable
typealias Model = Decodable

struct APIManager {
    
    static let sharedInstance = APIManager()
    
    static let dispatchGroup = DispatchGroup()
    
    func requestObjectWithPath<T: Model>(_ target: APIManager.Service, success: @escaping ((T) -> Void), failure: ((Error) -> Void)? = nil) {
        APIManager.dispatchGroup.enter()
        APIManager.sharedInstance.requestWithPath(target, success: { (data) in
            APIManager.dispatchGroup.leave()
            do {
                let responseObject = try JSONDecoder().decode(T.self, from: data)
                print("Success: \(responseObject)")
                success(responseObject)
            }
            catch {
                 print("Error info: \(error)")
            }
        }) { (error) in
            failure?(error)
        }
    }
    
    func requestArrayOfObjectWithPath<T: Model>(_ target: APIManager.Service, success: @escaping (([T]) -> Void), failure: ((Error) -> Void)? = nil) {
        APIManager.dispatchGroup.enter()
        APIManager.sharedInstance.requestWithPath(target, success: { (data) in
            APIManager.dispatchGroup.leave()
            do {
                let responseObject = try JSONDecoder().decode([T].self, from: data)
                print("Success: \(responseObject)")
                success(responseObject)
            }
            catch {
                 print("Error info: \(error)")
            }
        }) { (error) in
            failure?(error)
        }
    }
    
    fileprivate func requestWithPath(_ target: APIManager.Service, success: @escaping ((Data) -> Void), failure: ((Error) -> Void)? = nil) {
        let baseUrl = target.baseURL
        let path = target.path
        let url = URL(string: "\(baseUrl)\(path)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue
        
        print(request)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                failure?(error)
            }
            else {
                success(data!)
            }
        }.resume()
    }
}


public enum APIMethod: String {
    case get = "GET"
    case post = "POST"
}

public protocol TargetType {
    
    /// The target's base `URL`.
    var baseURL: String { get }

    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }

    /// The HTTP method used in the request.
    var method: APIMethod { get }

    /// The headers to be used in the request.
    var headers: [String: String]? { get }
    
}
