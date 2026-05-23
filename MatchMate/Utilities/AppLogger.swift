import Foundation
import OSLog

final class AppLogger {

    static let shared = AppLogger()

    private let subsystem: String

    private init() {
        self.subsystem = Bundle.main.bundleIdentifier ?? "com.MatchMate.development"
    }

    enum Category: String {
        case network = "Network"
        case auth = "Auth"
        case ui = "UI"
        case profile = "Profile"
        case general = "General"
    }

    private func logger(for category: Category) -> Logger {
        Logger(subsystem: subsystem, category: category.rawValue)
    }

    func info(_ message: String, category: Category = .general) {
        logger(for: category).info("\(message, privacy: .public)")
    }

    func debug(_ message: String, category: Category = .general) {
        #if DEBUG
        logger(for: category).debug("\(message, privacy: .public)")
        #endif
    }

    func warning(_ message: String, category: Category = .general) {
        logger(for: category).warning("\(message, privacy: .public)")
    }

    func error(_ message: String, category: Category = .general) {
        logger(for: category).error("\(message, privacy: .public)")
    }

    func fault(_ message: String, category: Category = .general) {
        logger(for: category).fault("\(message, privacy: .public)")
    }
}
