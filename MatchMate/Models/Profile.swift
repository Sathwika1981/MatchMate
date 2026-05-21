import Foundation

enum ProfileMatchStatus {
    case pending
    case accepted
    case declined
}

struct Profile: Identifiable {
    let id: UUID
    let name: String
    let age: Int
    let city: String
    let state: String
    var status: ProfileMatchStatus

    var locationLine: String {
        "\(age),\(city),\(state)"
    }
}

extension Profile {
    static let samples: [Profile] = [
        Profile(
            id: UUID(),
            name: "Adilson Pultrum",
            age: 56,
            city: "Oudega gem Smallingerlnd",
            state: "Drenthe",
            status: .pending
        ),
        Profile(
            id: UUID(),
            name: "Florence Gagné",
            age: 43,
            city: "Keswick",
            state: "Yukon",
            status: .accepted
        ),
        Profile(
            id: UUID(),
            name: "Adilson Pultrum",
            age: 56,
            city: "Oudega gem Smallingerlnd",
            state: "Drenthe",
            status: .pending
        ),
    ]
}
