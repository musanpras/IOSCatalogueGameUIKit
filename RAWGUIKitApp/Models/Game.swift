import Foundation

struct Game: Codable, Hashable {
    let id: Int
    let name: String
    let backgroundImage: URL?
    let rating: Double?
    let released: String?
    let genres: [Genre]?
    enum CodingKeys: String, CodingKey {
        case id, name, rating, released, genres
        case backgroundImage = "background_image"
    }
}

struct Genre: Codable, Hashable {
    let id: Int
    let name: String
}
