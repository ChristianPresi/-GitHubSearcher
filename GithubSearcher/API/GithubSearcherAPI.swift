//
//  GithubSearcherAPI.swift
//  GithubSearcher
//
//  Created by Christian Hipolito on 03/06/20.
//  Copyright © 2020 Christian Hipolito. All rights reserved.
//

import Foundation
import Alamofire
import Combine
enum GithubSearcherAPIError: Error {
    case limitExceeded(String)
    case unknown(String)
}

class GithubSearcherAPI {
    static let shared = GithubSearcherAPI()
    let baseURLText = "https://api.github.com"
    
    func searchUsersBy(term: String) -> Future<[SearchUsersResponse.PartialUser], AFError> {
        let encodedTerm =
            term.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let urlText = baseURLText + "/search/users?q=\(encodedTerm)"
        
        return Future<[SearchUsersResponse.PartialUser], AFError> { promise in
            AF.request(urlText).responseDecodable(of: SearchUsersResponse.self) { dataResponse in
                guard dataResponse.error == nil else {
                    promise(.failure(dataResponse.error!))
                    return
                }
                
                let userSearchResponse = dataResponse.value
                let partialUsers = userSearchResponse?.items ?? []
                
                promise(.success(partialUsers))
            }
        }
    }
    
    func fetchUserDetailsBy(loginID: String) -> Future<User, Error> {
        let urlText = baseURLText + "/users/\(loginID)"
        let headers = HTTPHeaders(arrayLiteral: HTTPHeader(name: "Authorization", value: "4d1a881fa96891be2803c4cfc64669d23ecf3bc4"))
        
        return Future<User, Error> { promise in
            AF.request(urlText, headers: headers).responseData { (dataResponse) in
                guard dataResponse.error == nil else {
                    promise(.failure(dataResponse.error!))
                    return
                }

                let data = dataResponse.value!
                
                let jsonObj = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
                
                if let message = jsonObj?["message"] as? String {
                    if message.contains("API rate limit exceeded for") {
                        promise(.failure(GithubSearcherAPIError.limitExceeded(message)))
                    }
                    else {
                        promise(.failure(GithubSearcherAPIError.unknown(message)))
                    }
                    
                    return
                }
                
                do {
                    let user = try User.decoder.decode(User.self, from: data)
                    promise(.success(user))
                }
                catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
