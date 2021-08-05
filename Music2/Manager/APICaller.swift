//
//  APICaller.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import Foundation


final class APICaller {
    static let shared = APICaller()
    
    private init () {}
    
    struct Constants {
        static let baseURL = "https://api.spotify.com/v1"
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/me"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    
    
    // MARK: - Private
    
    
    enum HTTPMethod: String {
        case GET
        case POST
    }
    
    
    private func createRequest(
        with url: URL?,
        type: HTTPMethod,
        completion: @escaping (URLRequest) -> Void
    )  {
        AuthManager.shared.withValidToken { [weak self] token in
            guard let apiURL = url else { return }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        } 
    }
}
