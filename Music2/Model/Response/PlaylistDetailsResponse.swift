//
//  PlaylistDetailsResponse.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/07.
//

import Foundation

struct PlaylistDetailsResponse: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let tracks: PlayListTracksResponse
}

struct PlayListTracksResponse: Codable {
    let items: [PlaylistItem]
}

struct PlaylistItem: Codable {
    let track: AudioTrack
}
