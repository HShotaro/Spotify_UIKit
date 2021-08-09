//
//  LibraryAlbumResponse.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/09.
//

import Foundation

struct LibraryAlbumResponse: Codable {
    let items: [SavedAlbum]
}

struct SavedAlbum: Codable {
    let album: Album
    let added_at: String?
}
