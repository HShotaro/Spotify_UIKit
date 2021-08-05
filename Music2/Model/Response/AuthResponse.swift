//
//  AuthResponse.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import Foundation

struct AuthResponse: Codable {
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String
    let token_type: String
}
