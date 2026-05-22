import CoreData
import Foundation

@objc(CDMatchUser)
final class CDMatchUser: NSManagedObject {
    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var age: Int16
    @NSManaged var city: String?
    @NSManaged var state: String?
    @NSManaged var imageURL: String?
    @NSManaged var status: String?
}

extension CDMatchUser {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDMatchUser> {
        NSFetchRequest<CDMatchUser>(entityName: "CDMatchUser")
    }
}
