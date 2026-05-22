import Foundation

enum ProfileMatchStatus {
    case pending
    case accepted
    case declined
}

struct Profile: Identifiable, Equatable {
    let id: String
    let name: String
    let age: Int
    let city: String
    let state: String
    let imageURL: URL?
    var status: ProfileMatchStatus

    var locationLine: String {
        "\(age),\(city),\(state)"
    }
}

#if DEBUG
extension Profile {
    static let preview = Profile(
        id: "preview",
        name: "Florence Gagné",
        age: 43,
        city: "Keswick",
        state: "Yukon",
        imageURL: URL(string: "https://randomuser.me/api/portraits/women/44.jpg"),
        status: .pending
    )

    static let previewAccepted = Profile(
        id: "preview-accepted",
        name: "Adilson Pultrum",
        age: 56,
        city: "Oudega gem Smallingerlnd",
        state: "Drenthe",
        imageURL: URL(string: "https://randomuser.me/api/portraits/men/32.jpg"),
        status: .accepted
    )
}
#endif
