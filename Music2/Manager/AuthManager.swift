//
//  AuthManager.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
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
}
