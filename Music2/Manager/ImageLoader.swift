//
//  ImageLoader.swift
//  Music2
//
//  Created by Shotaro Hirano on 2021/12/06.
//

import UIKit

actor ImageLoader {
    static let shared = ImageLoader()
    private init() {}
    
    private var cache = [URL: UIImage]()
    func image(url: URL, size: CGSize? = nil) async -> UIImage? {
        if let cached = cache[url] {
            return cached
        }
        // 連続でこの関数が実行された場合、2回目以降は画像のロードをしたくないためキャッシュにデフォルト値を設定しておく。
        cache[url] = UIImage(named: "picture")
        cache[url] = await load(url: url, size: size)
        return cache[url]
    }
}
