//
//  Album.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/06.
//

import Foundation

struct AlbumsResponse: Codable {
    let items: [Album]
}

struct Album: Codable {
    let album_type: String?
    let available_markets: [String]?
    let id: String
    let images: [APIImage]?
    let name: String
    let release_date: String?
    let total_tracks: Int?
    let artists: [Artist]?
}
