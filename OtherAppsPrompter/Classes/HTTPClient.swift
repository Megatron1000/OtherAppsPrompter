//    MIT License
//
//    Copyright (c) 2018 Mark Bridges
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

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
