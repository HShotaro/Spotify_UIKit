//
//  RecommendationResponse.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/06.
//

import Foundation

struct RecommendationResponse: Codable {
    let tracks: [AudioTrack]
}
