//
//  Artist.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import Foundation

struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let external_urls: [String: String]
}
