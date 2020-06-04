//
//  User.swift
//  GithubSearcher
//
//  Created by Christian Hipolito on 03/06/20.
//  Copyright © 2020 Christian Hipolito. All rights reserved.
//

import Foundation

struct User {
    var login: String
    var avatarTxt: String
    var reposCount: Int
    var followersCount: Int
}


struct SearchUsersResponse: Decodable {
    struct PartialUser: Decodable {
        var login: String
        var avatar_url: String
    }

    var items: [PartialUser]?
}
