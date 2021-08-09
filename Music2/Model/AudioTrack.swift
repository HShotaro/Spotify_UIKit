//
//  AudioTrack.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import Foundation

struct AudioTrack: Codable, Equatable {
    var album: Album?
    let artists: [Artist]?
    let available_markets: [String]?
    let disc_number: Int?
    let duration_ms: Int?
    let explicit: Bool?
    let external_urls: [String: String]?
    let id: String
    let name: String
    let popularity: Int?
    let preview_url: String?
    
    static func == (lhs: AudioTrack, rhs: AudioTrack) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Array where Element == AudioTrack {
    func isSameOf(_ tracks: [AudioTrack]) -> Bool {
        let lhsIDs = self.compactMap { $0.id}.sorted { $0 < $1}
        let rhsIDs = tracks.map { $0.id }.sorted { $0 < $1}
        return lhsIDs == rhsIDs
    }
}
