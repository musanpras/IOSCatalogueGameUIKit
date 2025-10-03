import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {
        // Initialize the container immediately
        _ = persistentContainer
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FavoritesModel")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // In production, handle this error appropriately
                print("Core Data error: \(error), \(error.userInfo)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            print("Core Data store loaded: \(storeDescription)")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Core Data saved successfully")
            } catch {
                let nserror = error as NSError
                print("Core Data save error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
