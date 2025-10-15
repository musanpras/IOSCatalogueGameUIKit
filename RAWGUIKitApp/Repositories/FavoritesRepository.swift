import Foundation
import CoreData

protocol FavoritesRepositoryProtocol {
    func add(game: Game)
    func remove(id: Int)
    func toggle(game: Game)
    func isFavorite(id: Int) -> Bool
    func all() -> [Game]
}

final class FavoritesRepository: FavoritesRepositoryProtocol {
    static let shared = FavoritesRepository()
    private let stack = CoreDataStack.shared
    private init() { }
    func add(game: Game) {
        if isFavorite(id: game.id) { return }
        let ctx = stack.context
        let e = FavoriteGameEntity(context: ctx)
        e.id = Int64(game.id)
        e.name = game.name
        e.backgroundImageURL = game.backgroundImage?.absoluteString
        e.released = game.released
        e.rating = game.rating ?? 0
        stack.save()
    }
    func remove(id: Int) {
        let ctx = stack.context
        let r: NSFetchRequest<FavoriteGameEntity> = FavoriteGameEntity.fetchRequest()
        r.predicate = NSPredicate(format: "id == %d", id)
        if let obj = try? ctx.fetch(r).first {
            ctx.delete(obj)
            stack.save()
        }
    }
    func toggle(game: Game) {
        if isFavorite(id: game.id) {
            remove(id: game.id)
        } else {
            add(game: game)
        }
    }
    func isFavorite(id: Int) -> Bool {
        let ctx = stack.context
        let r: NSFetchRequest<FavoriteGameEntity> = FavoriteGameEntity.fetchRequest()
        r.predicate = NSPredicate(format: "id == %d", id)
        let c = (try? ctx.count(for: r)) ?? 0
        return c > 0
    }
    func all() -> [Game] {
        let ctx = stack.context
        let r: NSFetchRequest<FavoriteGameEntity> = FavoriteGameEntity.fetchRequest()
        guard let arr = try? ctx.fetch(r) else { return [] }
        return arr.map { e in
            Game(id: Int(e.id), name: e.name, backgroundImage: URL(string: e.backgroundImageURL ?? ""), rating: e.rating, released: e.released, genres: nil)
        }
    }
}
