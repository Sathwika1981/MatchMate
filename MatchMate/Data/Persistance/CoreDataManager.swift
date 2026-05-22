import CoreData
import Foundation

protocol CoreDataManagerProtocol {
    func saveProfiles(_ profiles: [Profile]) throws
    func fetchProfiles() throws -> [Profile]
    func updateProfile(profile: Profile, status: ProfileMatchStatus) throws
}

final class CoreDataManager: CoreDataManagerProtocol {
    static let shared = CoreDataManager()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MatchMate")

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data Error: \(error)")
            }
        }

        return container
    }()

    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }

    // Persisting only profiles with accepted or declined status
    // so decisions remain available across app relaunches.
    func saveProfiles(_ profiles: [Profile]) throws {
        let filteredProfiles = profiles.filter {
            $0.status == .accepted || $0.status == .declined
        }

        for profile in filteredProfiles {

            let request = CDMatchUser.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", profile.id)

            let existing = try context.fetch(request).first
            let entity = existing ?? Self.makeMatchUser(in: context)

            entity.id = profile.id
            entity.name = profile.name
            entity.age = Int16(profile.age)
            entity.city = profile.city
            entity.state = profile.state
            entity.imageURL = profile.imageURL?.absoluteString
            entity.status = profile.status.rawValue
        }

        try saveContext()
    }

    func fetchProfiles() throws -> [Profile] {
        let request = CDMatchUser.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let entities = try context.fetch(request)
        return entities.map { $0.toDomain() }
    }

    func updateProfile(profile: Profile, status: ProfileMatchStatus) throws {

        let request = CDMatchUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", profile.id)

        let existing = try context.fetch(request).first
        let entity = existing ?? Self.makeMatchUser(in: context)

        entity.id = profile.id
        entity.name = profile.name
        entity.age = Int16(profile.age)
        entity.city = profile.city
        entity.state = profile.state
        entity.imageURL = profile.imageURL?.absoluteString
        entity.status = status.rawValue

        try saveContext()
    }

    private static func makeMatchUser(in context: NSManagedObjectContext) -> CDMatchUser {
        let entity = NSEntityDescription.entity(forEntityName: "CDMatchUser", in: context)!
        return CDMatchUser(entity: entity, insertInto: context)
    }
}
