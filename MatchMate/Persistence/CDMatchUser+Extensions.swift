import Foundation

extension CDMatchUser {
    func toDomain() -> Profile {
        Profile(
            id: id ?? "",
            name: name ?? "",
            age: Int(age),
            city: city ?? "",
            state: state ?? "",
            imageURL: imageURL.flatMap(URL.init(string:)),
            status: ProfileMatchStatus(rawValue: status ?? "") ?? .pending
        )
    }
}
