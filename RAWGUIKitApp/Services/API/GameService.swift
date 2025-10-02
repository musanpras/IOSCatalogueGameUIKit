import Foundation

protocol GameServiceProtocol {
    func fetchGames(url: URL?) async throws -> GameListResponse
    func searchGames(query: String) async throws -> GameListResponse
    func fetchDetail(id: Int) async throws -> GameDetail
    var firstPageURL: URL { get }
}

final class GameService: GameServiceProtocol {
    private let key = "321ca652b93540ea9dfd2cc5311b99f6"
    private let api: APIClientProtocol
    init(api: APIClientProtocol = APIClient()) {
        self.api = api
    }
    var firstPageURL: URL {
        URL(string: "https://api.rawg.io/api/games?key=\(key)")!
    }
    func fetchGames(url: URL?) async throws -> GameListResponse {
        try await api.get(url ?? firstPageURL)
    }
    func searchGames(query: String) async throws -> GameListResponse {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "https://api.rawg.io/api/games?search=\(encoded)&key=\(key)")!
        return try await api.get(url)
    }
    func fetchDetail(id: Int) async throws -> GameDetail {
        let url = URL(string: "https://api.rawg.io/api/games/\(id)?key=\(key)")!
        return try await api.get(url)
    }
}
