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
        if isFavorite(id: game.id) {
            print("Game already in favorites: \(game.name)")
            return
        }
        
        let ctx = stack.context
        
        // Create entity using NSEntityDescription
        guard let entity = NSEntityDescription.entity(forEntityName: "FavoriteGameEntity", in: ctx) else {
            print("ERROR: Could not find entity description for FavoriteGameEntity")
            return
        }
        
        let favoriteEntity = FavoriteGameEntity(entity: entity, insertInto: ctx)
        favoriteEntity.id = Int64(game.id)
        favoriteEntity.name = game.name
        favoriteEntity.backgroundImageURL = game.backgroundImage?.absoluteString
        favoriteEntity.released = game.released
        favoriteEntity.rating = game.rating ?? 0
        
        print("Adding game to favorites: \(game.name)")
        stack.save()
        print("Game added successfully")
    }
    
    func remove(id: Int) {
        let ctx = stack.context
        let request: NSFetchRequest<FavoriteGameEntity> = FavoriteGameEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try ctx.fetch(request)
            if let obj = results.first {
                ctx.delete(obj)
                stack.save()
                print("Game removed from favorites: \(id)")
            }
        } catch {
            print("Error removing favorite: \(error)")
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
        let request: NSFetchRequest<FavoriteGameEntity> = FavoriteGameEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let count = try ctx.count(for: request)
            return count > 0
        } catch {
            print("Error checking favorite: \(error)")
            return false
        }
    }
    
    func all() -> [Game] {
        let ctx = stack.context
        let request: NSFetchRequest<FavoriteGameEntity> = FavoriteGameEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let results = try ctx.fetch(request)
            return results.map { entity in
                Game(
                    id: Int(entity.id),
                    name: entity.name,
                    backgroundImage: entity.backgroundImageURL.flatMap { URL(string: $0) },
                    rating: entity.rating,
                    released: entity.released,
                    genres: nil
                )
            }
        } catch {
            print("Error fetching favorites: \(error)")
            return []
        }
    }
}
