//
//  Realm + Extension.swift
//  TestTask
//
//  Created by MacBook on 11.10.2022.
//

import Foundation
import RealmSwift

extension RealmSwift.List: Decodable where Element: Decodable {
    public convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.singleValueContainer()
        let decodedElements = try container.decode([Element].self)
        self.append(objectsIn: decodedElements)
    }
}

extension RealmSwift.List: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.map { $0 })
    }
}
