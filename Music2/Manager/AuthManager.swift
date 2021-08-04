//
//  AuthManager.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import Foundation

final class AuthManager {
    static let redirectURL = "http://localhost:8888/callback"
    static let tokenAPIURL = "https://accounts.spotify.com/api/token"
    static let shared = AuthManager()
    
    private init() {}
    
    var signInURL: URL? {
        let scopes = "user-read-private"
//            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(SPOTIFY_CLIENT_ID)&scope=\(scopes)&redirect_uri=\(AuthManager.redirectURL)"
        return URL(string: string)
    }
    
    var isSignIn: Bool {
        return false
    }
    
    private var accsssToken: String? {
        return nil
    }
    
    private var tokenExpirationDate: Date? {
        return nil
    }
    
    private var shouldRefreshToken: Bool {
        return false
    }
    
    public func exchangeCodeForToken(code: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: AuthManager.tokenAPIURL) else { return }
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: AuthManager.redirectURL)
        ]
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded ", forHTTPHeaderField: "Content-Type")
        let basicToken = SPOTIFY_CLIENT_ID+":"+SPOTIFY_CLIENT_SECRET
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            completion(false)
            return
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        request.httpBody = components.query?.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                completion(true)
            } catch {
                print(error.localizedDescription)
                completion(false)
            }
        }
        
        task.resume()
    }
    
    public func refreshAccessToken() {
        
    }
    
    private func cacheToken() {
        
    }
}
