import Foundation

enum Endpoint {
    case fetchMatches

    var url: URL? {
        switch self {
        case .fetchMatches:
            URL(string: "https://randomuser.me/api/?results=10")
        }
    }
}
