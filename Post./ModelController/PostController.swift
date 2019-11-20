//
//  PostController.swift
//  Post.
//
//  Created by Anthony Torres on 11/19/19.
//  Copyright © 2019 Anthony Torres. All rights reserved.
//

import Foundation

class PostController {
    
    var posts: [Post] = []
    
    let baseURL = URL(string: "https://devmtn-posts.firebaseio.com/posts")

    
    func fetchPosts(reset: Bool = true, completion: @escaping () -> Void) {
        
        guard let baseURL = baseURL else {
            print("baseURL is not a valid URL")
            return
        }
        
        let getterEndpoint = baseURL.appendingPathExtension("json")
        
        var urlComponents = URLComponents(url: getterEndpoint, resolvingAgainstBaseURL: true)
        
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        let urlParameters = ["orderBy": "\"timestamp\"", "endAt": "\(queryEndInterval)", "limitToLast": "15"]
        let queryItems = urlParameters.compactMap { URLQueryItem(name: $0, value: $1) }
        urlComponents?.queryItems = queryItems
        
        guard let finalURL = urlComponents?.url else {
            print("Could not build final URL.")
            return
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
                completion()
                return
            }
            
            guard let data = data else {
                print("No data in response.")
                completion()
                return
            }
            
            
            let jd = JSONDecoder()
            guard let postsDictionary = try? jd.decode([String: Post].self, from: data) else {
                print("Could not decode JSON data")
                completion()
                return
            }
            
            let posts = postsDictionary.compactMap { $1 }
            // return true if first arg should be shown before second
            let sortedPosts = posts.sorted { $0.timestamp > $1.timestamp }
            
            if reset == true {
                self.posts = sortedPosts
            } else {
                self.posts.append(contentsOf: sortedPosts)
            }
            completion()
        }
        task.resume()
    }
    
    func addNewPostWith(username: String, text: String, completion: @escaping () -> Void) {
        let postToEncode = Post(username: username, text: text)
        
        var postData: Data
        let je = JSONEncoder()
        do {
            postData = try je.encode(postToEncode)
        } catch {
            print("Error encoding new post: \(error.localizedDescription) \n---\n \(error)")
            return
        }
        
        guard let baseURL = baseURL else {
            print("baseURL is not a valid URL")
            return
        }
        
        let postEndpoint = baseURL.appendingPathExtension("json")
        
        var request = URLRequest(url: postEndpoint)
        request.httpMethod = "POST"
        request.httpBody = postData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
                completion()
                return
            }
            
            guard let data = data else {
                print("No data in response.")
                completion()
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Unrecognized response.")
                completion()
                return
            }
            
            if httpResponse.statusCode == 200, let result = String(data: data, encoding: .utf8) {
                print(result)
                self.fetchPosts {
                    completion()
                }
            } else {
                print("Post failed. Status code: \(httpResponse.statusCode)")
                completion()
            }
            
        }.resume()
    }
}
