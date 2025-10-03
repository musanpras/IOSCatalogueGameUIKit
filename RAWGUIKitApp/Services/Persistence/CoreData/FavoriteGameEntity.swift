import Foundation
import CoreData

@objc(FavoriteGameEntity)
public class FavoriteGameEntity: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteGameEntity> {
        return NSFetchRequest<FavoriteGameEntity>(entityName: "FavoriteGameEntity")
    }
    
    @NSManaged public var id: Int64
    @NSManaged public var name: String
    @NSManaged public var backgroundImageURL: String?
    @NSManaged public var released: String?
    @NSManaged public var rating: Double
}
