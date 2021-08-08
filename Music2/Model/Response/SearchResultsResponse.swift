//
//  SearchResultsResponse.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/08.
//

import Foundation

struct SearchResultsResponse: Codable {
    let albums: SearchAlbumResponse
    let artists: SearchArtistsResponse
    let playlists: SearchPlaylistsResponse
    let tracks: SearchTracksResponse
}

enum SearchResult: Equatable {
    case artist(model: Artist)
    case album(model: Album)
    case track(model: AudioTrack)
    case playlist(model: Playlist)
    
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        switch (lhs, rhs) {
        case (let .artist(l), let .artist(r)):
            return l.id == r.id
        case (let .album(l), let .album(r)):
            return l.id == r.id
        case (let .track(l), let .track(r)):
            return l.id == r.id
        case (let .playlist(l), let .playlist(r)):
            return l.id == r.id
        default:
            return false
        }
    }
}

struct SearchAlbumResponse: Codable {
    let items: [Album]
}

struct SearchArtistsResponse: Codable {
    let items: [Artist]
}

struct SearchPlaylistsResponse: Codable {
    let items: [Playlist]
}

struct SearchTracksResponse: Codable {
    let items: [AudioTrack]
}
