//
//  Array+string.swift
//  Music2
//
//  Created by Shotaro Hirano on 2021/12/07.
//

import Foundation

extension Array where Element == String {
    func toRandomSet(numberOfElements: Int) -> Set<String> {
        var set = Set<String>()
        while set.count < numberOfElements {
            if let random = self.randomElement() {
                set.insert(random)
            }
        }
        return set
    }
}
