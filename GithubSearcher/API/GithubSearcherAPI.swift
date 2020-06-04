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

class GithubSearcherAPI {
    static let shared = GithubSearcherAPI()
    let baseURLTxt = "https://api.github.com"
    
    func searchUsersBy(term: String) -> Future<[SearchUsersResponse.PartialUser], AFError> {
        let encodedTerm =
            term.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let url = baseURLTxt + "/search/users?q=\(encodedTerm)"
        
        return Future<[SearchUsersResponse.PartialUser], AFError> { promise in
            AF.request(url).responseDecodable(of: SearchUsersResponse.self) { dataResponse in
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
    
    private func fetchUserDetailsBy(loginID: String) {
        
    }
}
