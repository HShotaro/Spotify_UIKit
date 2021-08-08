//
//  Playlist.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import Foundation

struct PlaylistResponse: Codable {
    let items: [Playlist]
}

struct Playlist: Codable {
    let description: String?
    let external_urls: [String: String]?
    let id: String
    let images: [APIImage]?
    let name: String
    let owner: User?
}
