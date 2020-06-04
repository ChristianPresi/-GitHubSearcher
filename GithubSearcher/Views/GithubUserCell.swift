//
//  GithubUserCell.swift
//  GithubSearcher
//
//  Created by Christian Hipolito on 03/06/20.
//  Copyright © 2020 Christian Hipolito. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Combine

class GithubUserCell: UITableViewCell {
    @IBOutlet private var avatar: UIImageView!
    @IBOutlet private var username: UILabel!
    @IBOutlet private var reposCount: UILabel!
    
    private var subscription: Cancellable?
    private var imageRequest: DataRequest?
        
    override func awakeFromNib() {
        username.text = ""
        reposCount.text = ""

    }
    override func prepareForReuse() {
        subscription?.cancel()
        imageRequest?.cancel()
        
        avatar.image = Image(systemName: "person.crop.square")
        username.text = ""
        reposCount.text = ""
    }
    
    func setup(with promise: Future<User, Error>) {
        subscription = promise
            .sink(receiveCompletion: {
                if case .failure = $0 {
                    self.username.text = "<Error getting user>"
                    self.avatar.image = Image(systemName: "exclamationmark.triangle")
                    self.accessoryType = .none

                    print($0)
                }
            }, receiveValue:  {[weak self] user in
                guard let self = self else {
                    return
                }
                
                self.username.text = user.login
                    
                let numberOfRepos = user.public_repos ?? 0
                self.reposCount.text = "\(numberOfRepos)" + (numberOfRepos > 1 ? "repos": "repo")
                
                self.accessoryType = .disclosureIndicator

                let imageRequest = AF.request(user.avatar_url)
                self.imageRequest = imageRequest
                
                imageRequest.responseImage {[weak self] response in
                    self?.avatar.image = response.value
                }
            })
    }
}
