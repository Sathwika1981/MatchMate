import Combine
import Foundation

@MainActor
final class ProfileMatchesViewModel: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var isLoading = false
    @Published private(set) var apiError: APIError?

    private let service: ProfileServiceProtocol

    init(service: ProfileServiceProtocol) {
        self.service = service
    }

    convenience init() {
        self.init(service: ProfileService())
    }

    func loadProfiles() async {
        guard !isLoading else { return }

        isLoading = true
        apiError = nil

        defer { isLoading = false }

        do {
            profiles = try await service.fetchProfiles(count: 10)
        } catch let error as APIError {
            apiError = error
        } catch {
            apiError = .unknown(error)
        }
    }
}
