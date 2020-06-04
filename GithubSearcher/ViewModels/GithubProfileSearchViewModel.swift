//
//  GithubProfileSearchViewModel.swift
//  GithubSearcher
//
//  Created by Christian Hipolito on 03/06/20.
//  Copyright © 2020 Christian Hipolito. All rights reserved.
//

import Foundation
import Combine
import Alamofire

final class GithubProfileSearchViewModel {
    var searchTermText: String = "" {
        didSet {
            searchTermChangesSubject.send(searchTermText)
        }
    }
        
    var numberOfRows: Int {
        partialUsers.count
    }

    var hasUpdated = CurrentValueSubject<Bool, Never>(false)
    
    private var partialUsers = [SearchUsersResponse.PartialUser]()
    
    private var searchTermChangesSubject = PassthroughSubject<String, Never>()
    private var serchTermChangesSubscription: Cancellable?
    private var oldAPISearchSubscription: Cancellable?
    
    init() {
        serchTermChangesSubscription = searchTermChangesSubject
            .map {  self.trimExtraTrailingWhiteSpaces(of: $0) }
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink(receiveValue: {[weak self] in
                guard let self = self else {
                    return
                }
                
                self.hasUpdated.value = false
                
                self.oldAPISearchSubscription?.cancel()
                
                self.oldAPISearchSubscription = GithubSearcherAPI.shared.searchUsersBy(term: $0)
                    .sink(receiveCompletion: {
                        if case .failure = $0 {
                            print("searching users...", $0)
                        }
                    },
                          receiveValue: {
                            self.partialUsers = $0
                            self.hasUpdated.value = true
                    })
            })
    }
    
    func getUser(at index: Int) -> Future<User, Error> {
        let loginID = partialUsers[index].login
        
        return GithubSearcherAPI.shared.fetchUserDetailsBy(loginID: loginID)
    }
    
    private func trimExtraTrailingWhiteSpaces(of string: String) -> String {
        string.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
    }
}
