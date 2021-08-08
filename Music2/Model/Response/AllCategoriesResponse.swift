//
//  AllCategoriesResponse.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/08.
//

import Foundation

struct AllCategoriesResponse: Codable {
    let categories: Categories
}

struct Categories: Codable {
    let items: [Category]
}

struct Category: Codable {
    let id: String
    let name: String
    let icons: [APIImage]
}
