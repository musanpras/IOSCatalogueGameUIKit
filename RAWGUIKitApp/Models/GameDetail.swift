import Foundation

struct GameDetail: Codable {
    let id: Int
    let name: String
    let descriptionRaw: String?
    let backgroundImage: URL?
    let website: URL?
    let rating: Double?
    let released: String?
    let playtime: Int?
    let metacritic: Int?
    let genres: [Genre]?
    enum CodingKeys: String, CodingKey {
        case id, name, website, rating, released, playtime, metacritic, genres
        case descriptionRaw = "description_raw"
        case backgroundImage = "background_image"
    }
}
