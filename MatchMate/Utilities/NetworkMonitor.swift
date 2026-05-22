import Foundation
import Network

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}

final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private(set) var isConnected = true

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            let connected = path.status == .satisfied
            let didChange = self.isConnected != connected
            self.isConnected = connected

            // Network connectivity is a global app-level event
            // NotificationCenter is used here to broadcast network connectivity changes across the app.
            // This keeps the architecture loosely coupled, allowing ViewModels, repositories, and other
            // services to react to connectivity updates without directly depending on NetworkMonitor.
            if didChange {
                NotificationCenter.default.post(
                    name: .networkStatusChanged,
                    object: nil,
                    userInfo: ["isConnected": connected]
                )
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
