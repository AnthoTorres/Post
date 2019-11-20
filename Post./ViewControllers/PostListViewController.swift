//
//  PostListViewController.swift
//  Post.
//
//  Created by Anthony Torres on 11/19/19.
//  Copyright © 2019 Anthony Torres. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController {
    
    let postController = PostController()
    let refreshControl = UIRefreshControl()

    
    @IBOutlet weak var postTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTableView.estimatedRowHeight = 45
        postTableView.rowHeight = UITableView.automaticDimension

        // Set up table view
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        
        postController.fetchPosts {
            self.reloadTableView()
        }
    }
    
    @objc
    func refreshControlPulled() {
        postController.fetchPosts {
            self.reloadTableView()
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentNewPostAlert()
    }
    
    // MARK: - Helper Methods
    
    func presentNewPostAlert() {
        let alert = UIAlertController(title: "New Post", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "username"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Type your post..."
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let postAction = UIAlertAction(title: "Post", style: .default) { _ in
            guard let username = alert.textFields?[0].text, !username.isEmpty,
                let text = alert.textFields?[1].text, !text.isEmpty
            else {
                self.present(alert, animated: true)
                return
            }
            
            self.postController.addNewPostWith(username: username, text: text) {
                self.reloadTableView()
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(postAction)
        present(alert, animated: true)
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.postTableView.reloadData()
        }
    }
}


// MARK: - Table View Data Source

extension PostListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = postController.posts[indexPath.row]
        
        let df = DateFormatter()
        df.dateFormat = "MMM dd yyyy h:mm a"
        let dateString = df.string(from: Date(timeIntervalSince1970: post.timestamp))
        
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(dateString)\nBy \(post.username)"
        
        return cell
    }
}

// MARK: - Table View Delegate
extension PostListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row >= postController.posts.count - 1
            else { return }
        
        postController.fetchPosts(reset: false) {
            self.reloadTableView()
        }
    }
}
