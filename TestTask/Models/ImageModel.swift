import Foundation
import RealmSwift

@objcMembers class ImageModel: Object, Codable, NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ImageModel()
        copy.id = id
        copy.urls = urls?.copy() as? URLs
        copy.likes = likes
        copy.width = width
        copy.height = height
        return copy
    }

    dynamic var id: String = UUID().uuidString
    dynamic var width: Int = 100
    dynamic var height: Int = 100
    dynamic var likes: Int = 0

    dynamic var urls: URLs? = URLs()
}

@objcMembers class URLs: Object, Codable, NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = URLs()
        copy.raw = raw
        copy.full = full
        copy.regular = regular
        return copy
    }

    dynamic var raw: String = ""
    dynamic var full: String = ""
    dynamic var regular: String = ""
}
