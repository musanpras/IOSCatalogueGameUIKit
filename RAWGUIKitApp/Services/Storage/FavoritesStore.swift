import Foundation

final class FavoritesStore {
    static let shared = FavoritesStore()
    private let key = "favorite.game.ids"
    private let defaults = UserDefaults.standard
    private init() { }
    func toggle(id: Int) {
        var s = ids()
        if s.contains(id) { s.remove(id) } else { s.insert(id) }
        defaults.set(Array(s), forKey: key)
    }
    func isFavorite(id: Int) -> Bool {
        ids().contains(id)
    }
    func ids() -> Set<Int> {
        let a = defaults.array(forKey: key) as? [Int] ?? []
        return Set(a)
    }
}
