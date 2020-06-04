//
//  ViewController.swift
//  GithubSearcher
//
//  Created by Christian Hipolito on 03/06/20.
//  Copyright © 2020 Christian Hipolito. All rights reserved.
//

import UIKit
import Combine

final class GithubProfileSearchVC: UIViewController {
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var tableView: UITableView!
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(aiv)
        
        NSLayoutConstraint.activate([
            aiv.heightAnchor.constraint(equalToConstant: 100),
            aiv.widthAnchor.constraint(equalToConstant: 100),
            aiv.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 8),
            aiv.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        return aiv
    }()
    private let viewModel = GithubProfileSearchViewModel()
    private var partialUsersSubscription: Cancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Github users"
        self.navigationController?.navigationBar.prefersLargeTitles = true

        searchBar.searchTextField.delegate = self

        tableView.isHidden = true
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        
        partialUsersSubscription = viewModel.hasUpdated
            .dropFirst(1)
            .sink(receiveValue: {[weak self] updated in
                guard let self = self else {
                    return
                }

                guard updated else {
                    self.activityIndicator.startAnimating()
                    self.tableView.isHidden = true
                    return
                }

                self.tableView.isHidden = false
                self.tableView.reloadData()
                
                self.activityIndicator.stopAnimating()
            })
    }
}

//MARK: - UITextFieldDelegate
extension GithubProfileSearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else {
            return true
        }
        
        let futureText = NSString(string: text).replacingCharacters(in: range, with: string)
        
        viewModel.searchTermText = futureText
        
        return true
    }
}

//MARK: - UITableviewDataSource
extension GithubProfileSearchVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
}

//MARK: - UITableviewDelegate
extension GithubProfileSearchVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let futureUser = viewModel.getUser(at: indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GithubUserCellID", for: indexPath) as! GithubUserCell
        cell.setup(with: futureUser)
        
        return cell
    }
    

}
