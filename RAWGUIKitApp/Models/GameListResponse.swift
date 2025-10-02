import Foundation

struct GameListResponse: Codable {
    let count: Int
    let next: URL?
    let previous: URL?
    let results: [Game]
}
