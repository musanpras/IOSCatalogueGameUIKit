import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    private init() { }
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FavoritesModel")
        container.loadPersistentStores { description, error in
                if let error = error {
                    fatalError("Unable to load persistent stores: \(error)")
                }
            }
            return container
    }()
    var context: NSManagedObjectContext { container.viewContext }
    func save() {
        let ctx = container.viewContext
        if ctx.hasChanges { try? ctx.save() }
    }
}
