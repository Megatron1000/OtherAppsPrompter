import Cocoa

class MailGunService {
    
    let httpClient: HTTPClient
    let apiKey: String
    let domain: String
    
    // MARK: Initialisation
    
    required init(httpClient: HTTPClient = HTTPClient(), apiKey: String, domain: String) {
        self.httpClient = httpClient
        self.apiKey = apiKey
        self.domain = domain
    }
    
    // MARK: Calls
    
    func getMember(forEmail email: String, withCompletion completion: @escaping (( Result<Member>) -> Void)) {
        
        let string = "https://api.mailgun.net/v3/lists/\(domain)/members/\(email)"
        
        let request = URLRequest(url: URL(string: string)!, userName: "api", password: apiKey)
        
        httpClient.makeNetworkRequest(with: request, completion: { result in
            
            switch result {
            case .success(let data):
                
                do {
                    let memberContainer = try JSONDecoder().decode(MemberContainer.self, from: data)
                    completion(.success(memberContainer.member))
                } catch {
                    completion(.failure(error))
                    return
                }
                
                
            case .failure(let error):
                completion(.failure(error))
            }
            
        })
    }
    
    func addMember(_ member: Member, withCompletion completion: @escaping (( Result<Void>) -> Void)) {
        
        let string = "https://api.mailgun.net/v3/lists/\(domain)/members"
        
        guard let urlComponents = NSURLComponents(string: string) else {
            fatalError("Unable to form URL for request")
        }
        
        let appsDictionary = ["appIdentifiers" : member.appIdentifiers]
        let encodedVarsData = try? JSONEncoder().encode(appsDictionary)
        let encodedVarsString = String(data: encodedVarsData!, encoding: .utf8)
        
        urlComponents.queryItems = []
        urlComponents.queryItems?.append(URLQueryItem(name: "address", value: member.address))
        urlComponents.queryItems?.append(URLQueryItem(name: "vars", value: encodedVarsString))
        
        var request = URLRequest(url: urlComponents.url!, userName: "api", password: apiKey)
        request.httpMethod = "POST"
        
        httpClient.makeNetworkRequest(with: request, completion: { result in
            
            switch result {
            case .success(_):
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
            
        })
    }
    
    func updateMember(_ member: Member, withCompletion completion: @escaping (( Result<Void>) -> Void)) {
        
        let string = "https://api.mailgun.net/v3/lists/\(domain)/members/\(member.address)"
        
        guard let urlComponents = NSURLComponents(string: string) else {
            fatalError("Unable to form URL for request")
        }
        
        let appsDictionary = ["appIdentifiers" : member.appIdentifiers]
        let encodedVarsData = try? JSONEncoder().encode(appsDictionary)
        let encodedVarsString = String(data: encodedVarsData!, encoding: .utf8)
        
        urlComponents.queryItems = []
        urlComponents.queryItems?.append(URLQueryItem(name: "address", value: member.address))
        urlComponents.queryItems?.append(URLQueryItem(name: "vars", value: encodedVarsString))
        
        var request = URLRequest(url: urlComponents.url!, userName: "api", password: apiKey)
        request.httpMethod = "PUT"
        
        httpClient.makeNetworkRequest(with: request, completion: { result in
            
            switch result {
            case .success(_):
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
            
        })
    }
    
}

private extension URLRequest {
    
    init(url: URL, userName: String, password: String) {
        
        let unencodedUserNameAndPassword = userName + ":" + password
        let encodedToken = Data(unencodedUserNameAndPassword.utf8).base64EncodedString()
        
        self.init(url: url)
        setValue("Basic \(encodedToken)", forHTTPHeaderField: "Authorization")
    }
    
}
