//
//  UserProfile.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import Foundation

struct User: Codable {
    let display_name: String
    let external_urls: [String: String]
    let id: String
}


struct UserProfile: Codable {
    let country: String;
    let display_name: String
    let email: String
    let explicit_content: [String: Bool]
    let external_urls: [String: String]
    let id: String
    let product: String
    let images: [APIImage]
}
