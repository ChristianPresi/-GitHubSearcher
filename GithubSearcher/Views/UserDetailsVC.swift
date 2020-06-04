//
//  UserDetailsVC.swift
//  GithubSearcher
//
//  Created by Christian Hipolito on 04/06/20.
//  Copyright © 2020 Christian Hipolito. All rights reserved.
//

import UIKit
import Combine
import Alamofire
import AlamofireImage

class UserDetailsVC: UIViewController {
    @IBOutlet private var avatar: UIImageView!
    @IBOutlet private var username: UILabel!
    @IBOutlet private var email: UILabel!
    @IBOutlet private var location: UILabel!
    @IBOutlet private var joinDate: UILabel!
    @IBOutlet private var followers: UILabel!
    @IBOutlet private var following: UILabel!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet var labelsContainer: UIView!
    
    private var viewModel: UserDetailsViewModel?
    private var hasUpdatedSubscription: Cancellable?
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(aiv)
        
        NSLayoutConstraint.activate([
            aiv.heightAnchor.constraint(equalToConstant: 100),
            aiv.widthAnchor.constraint(equalToConstant: 100),
            aiv.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            aiv.topAnchor.constraint(equalTo: self.labelsContainer.bottomAnchor, constant: 40)
        ])
        
        return aiv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.isHidden = true
        searchBar.searchTextField.delegate = self

        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        
        self.viewModel?.fetchRepos()
        
        if let avatar_url = viewModel?.avatar_url {
            AF.request(avatar_url).responseImage {
                if $0.error == nil {
                    self.avatar.image = $0.value
                }
            }
        }
        
        self.username.text = viewModel?.name
        self.email.text = viewModel?.email
        self.location.text = viewModel?.location
        self.joinDate.text = viewModel?.joinDate
        self.followers.text = viewModel?.followers
        self.following.text = viewModel?.following
    }
    
    func setupWith(viewModel: UserDetailsViewModel) {
        self.viewModel = viewModel
        
        hasUpdatedSubscription = viewModel.hasUpdated
            .dropFirst()
            .sink(receiveCompletion: { [weak self] in
                if case .failure = $0 {
                    print($0)
                    
                    self?.searchBar.isHidden = true
                    self?.tableView.isHidden = true
                    self?.activityIndicator.stopAnimating()

                }
            }, receiveValue: {[weak self] updted in
                if updted {
                    self?.searchBar.isHidden = false
                    self?.tableView.isHidden = false
                    self?.activityIndicator.stopAnimating()
                    
                    self?.tableView.reloadData()
                }
                else {
                    self?.activityIndicator.startAnimating()
                    self?.searchBar.isHidden = true
                    self?.tableView.isHidden = true
                }
            })
    }
}

//MARK: - UITextFieldDelegate
extension UserDetailsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else {
            return true
        }

        viewModel?.searchTermText = NSString(string: text).replacingCharacters(in: range, with: string)
        
        return true
    }
}

//MARK: - UITableviewDataSource
extension UserDetailsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.numberOfRows ?? 0
    }
}


//MARK: - UITableviewDelegate
extension UserDetailsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let repository = viewModel?.getRepository(at: indexPath.row) else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepoCellID", for: indexPath) as! RepoCell
        cell.setupWith(repository: repository)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let repository = viewModel?.getRepository(at: indexPath.row) else {
            return
        }
        
        guard let url = URL(string: repository.html_url) else {
            print("url not valid", repository.html_url)
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
