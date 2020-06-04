//
//  Repository.swift
//  GithubSearcher
//
//  Created by Christian Hipolito on 04/06/20.
//  Copyright © 2020 Christian Hipolito. All rights reserved.
//

import Foundation

struct Repository: Decodable {
    var name: String
    var forks_count: Int
    var stargazers_count: Int
    var html_url: String
}
