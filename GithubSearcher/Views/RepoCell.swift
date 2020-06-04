//
//  RepoCell.swift
//  GithubSearcher
//
//  Created by Christian Hipolito on 04/06/20.
//  Copyright © 2020 Christian Hipolito. All rights reserved.
//

import UIKit

class RepoCell: UITableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var forks: UILabel!
    @IBOutlet var stars: UILabel!

    func setupWith(repository: Repository) {
        name.text = repository.name

        let forks = repository.forks_count
        self.forks.text = "\(forks) " + (forks > 1 ? "forks" : "fork")
        
        let stars = repository.stargazers_count
        self.stars.text = "\(stars) " + (stars > 1 ? "stars" : "star")
    }
}
