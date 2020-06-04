//
//  User.swift
//  GithubSearcher
//
//  Created by Christian Hipolito on 03/06/20.
//  Copyright © 2020 Christian Hipolito. All rights reserved.
//

import Foundation

struct User: Codable {
    static let decoder: JSONDecoder = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .formatted(df)

        return dec
    }()

    
    var login: String
    var avatar_url: String
    var public_repos: Int?
    var followers: Int
    var following: Int
    var email: String?
    var location: String?
    var created_at: Date
}


struct SearchUsersResponse: Decodable {
    struct PartialUser: Decodable {
        var login: String
        var avatar_url: String
    }

    var items: [PartialUser]?
}
