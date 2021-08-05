//
//  SettingsModels.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
