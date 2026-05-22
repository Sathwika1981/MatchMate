import Foundation

// Considered using ProfileMapper as an enum instead of a struct,
// since its sole responsibility is mapping Data Models to Domain Models,
// and it should not take on additional responsibilities.

enum ProfileMapper {
    static func toDomain(_ user: User) -> Profile {
        Profile(
            id: user.login.uuid,
            name: user.name.fullName,
            age: user.dob.age,
            city: user.location.city,
            state: user.location.state,
            imageURL: URL(string: user.picture.large),
            status: .pending
        )
    }

    static func toDomain(_ response: UserResponse) -> [Profile] {
        response.results.map { toDomain($0) }
    }
}
