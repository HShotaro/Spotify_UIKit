//
//  UIImageView+load.swift
//  Music2
//
//  Created by Shotaro Hirano on 2021/12/06.
//

import UIKit

func load(url: URL, size: CGSize? = nil) async -> UIImage? {
    return await withCheckedContinuation { continuation in
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                let data = data,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let image = UIImage(data: data)
            else {
                continuation.resume(returning: nil)
                return
            }
            if #available(iOS 15.0, *), let size = size {
                let newImage = image.preparingThumbnail(of: size)
                continuation.resume(returning: newImage)
            } else {
                continuation.resume(returning: image)
            }
            
        }
        task.resume()
    }
}
