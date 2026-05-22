import Foundation

enum Endpoint {
    case fetchMatches(Int)

    var url: URL? {
        switch self {
        case .fetchMatches(let count):
            URL(string: "https://randomuser.me/api/?results=\(count)")
        }
    }
}
