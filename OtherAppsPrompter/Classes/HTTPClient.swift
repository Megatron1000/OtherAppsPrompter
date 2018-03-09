//
//  HTTPClient.swift
//  JohnLewisTest
//
//  Created by Mark Bridges on 24/11/2016.
//  Copyright © 2016 BridgeTech. All rights reserved.
//

import Foundation

class HTTPClient {
    
    // MARK: Error Enums
    
    enum HTTPClientError: Error {
        case emptyResponse
        case unexpectedResponse
        case badStatusCode
        case unauthorised
    }
    
    // MARK: Properties
    
    let session: NetworkSession
    
    // MARK: Initialisation
    
    required init(session: NetworkSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.session = session
    }
    
    // MARK: Network call
    
    func makeNetworkRequest(with request: URLRequest, completion: @escaping ((Result<Data>) -> Void)) {
        
        session.startDataTask(with: request, completionHandler: { (data, response, error) -> Void in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard
                let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(HTTPClientError.unexpectedResponse))
                    return
            }
            
            guard
                httpResponse.statusCodeValue?.isSuccess == true else {
                    if httpResponse.statusCodeValue == .unauthorized {
                        completion(.failure(HTTPClientError.unauthorised))
                    } else {
                        completion(.failure(HTTPClientError.badStatusCode))
                    }
                    
                    return
            }
            
            guard let data = data else {
                completion(.failure(HTTPClientError.emptyResponse))
                return
            }
            
            completion(.success(data))
        })
    }
}

// MARK: NetworkSession protocol - (To aid in testing we don't use a URLSession directly, but instead a NetworkSession protocol)

protocol NetworkSession {
    
    @discardableResult
    func startDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask
    
}

// MARK: URLSession NetworkSession Conformance

extension URLSession: NetworkSession {
    
    @discardableResult
    func startDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask{
        let dataTask = self.dataTask(with: request, completionHandler: completionHandler)
        dataTask.resume()
        return dataTask
    }
}
