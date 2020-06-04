//
//  UserDetailsViewModel.swift
//  GithubSearcher
//
//  Created by Christian Hipolito on 04/06/20.
//  Copyright © 2020 Christian Hipolito. All rights reserved.
//

import Foundation
import Alamofire
import Combine

class UserDetailsViewModel {
    var avatar_url: String {
        user.avatar_url
    }
    
    var name: String {
        user.login
    }
    
    var email: String? {
        user.email
    }
    
    var location: String? {
        user.location ?? ""
    }
    
    var followers: String {
        "\(user.followers) followers"
    }
    
    var following: String {
        "Following \(user.following)"
    }
    
    var joinDate: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        
        return "Joined \(df.string(from: user.created_at))"
    }
    
    var hasUpdated = CurrentValueSubject<Bool, Never>(false)
    var numberOfRows: Int {
        filteredRepositories.count
    }

    var searchTermText: String? {
        didSet {
            defer {
                self.hasUpdated.value = true
            }
            
            guard let term = searchTermText, !term.isEmpty else {
                filteredRepositories = repositories
                return
            }
            
            filteredRepositories = repositories.filter {
                return $0.name.lowercased().contains(term.lowercased())
            }
        }
    }

    private let user: User
    private var subscription: Cancellable?
    private var repositories = [Repository]()
    private var filteredRepositories = [Repository]()

    init(user: User) {
        self.user = user
    }
    
    func fetchRepos() {
        hasUpdated.value = false

        subscription = GithubSearcherAPI.shared.fetchRepos(loginID: user.login)
            .sink(receiveCompletion: {
                if case .failure = $0 {
                    print($0)
                }
            }, receiveValue: {[weak self] repositories in
                self?.repositories = repositories
                self?.filteredRepositories = repositories

                self?.hasUpdated.value = true
            })
        
    }
    
    func getRepository(at index: Int) -> Repository? {
        if 0...filteredRepositories.count ~= index {
            return filteredRepositories[index]
        }
        
        return nil
    }
}
