import CoreData

@objc(FavoriteGameEntity)
final class FavoriteGameEntity: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var name: String
    @NSManaged var backgroundImageURL: String?
    @NSManaged var released: String?
    @NSManaged var rating: Double
}

extension FavoriteGameEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<FavoriteGameEntity> {
        return NSFetchRequest<FavoriteGameEntity>(entityName: "FavoriteGameEntity")
    }
}

