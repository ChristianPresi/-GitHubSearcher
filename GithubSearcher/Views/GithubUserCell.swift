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

class GithubUserCell: UITableViewCell {
    @IBOutlet private var avatar: UIImageView!
    @IBOutlet private var username: UILabel!
    @IBOutlet private var reposCount: UILabel!
    
    private var imageRequest: DataRequest?
        
    override func prepareForReuse() {
        imageRequest?.cancel()
        avatar.image = Image(systemName: "person.crop.square")
    }
    
    
    func setup(with user: SearchUsersResponse.PartialUser) {
        username.text = user.login
        reposCount.text = ""

        let imageRequest = AF.request(user.avatar_url)
        self.imageRequest = imageRequest

        imageRequest.responseImage {[weak self] response in
            self?.avatar.image = response.value
        }
    }
}
