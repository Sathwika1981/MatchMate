import Combine
import Foundation

final class ProfileMatchesViewModel: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var isLoading = false
    @Published private(set) var apiError: APIError?

    private let repository: ProfileRepositoryProtocol
    private var loadTask: Task<Void, Never>?

    init(repository: ProfileRepositoryProtocol = ProfileRepository()) {
        self.repository = repository
        repository.onProfilesUpdated = { [weak self] profiles in
            self?.profiles = profiles
            self?.apiError = nil
        }
    }

    func loadProfiles() {
        // Explicitly cancelling any existing task before starting a new fetch request
        // to prevent overlapping API calls and ensure a consistent refresh experience.
        loadTask?.cancel()
        
        loadTask = Task {
            isLoading = true
            apiError = nil
            
            defer { isLoading = false }
            
            do {
                let profiles = try await repository.fetchProfiles()
                if !Task.isCancelled {
                    self.profiles = profiles
                    print("profiles:", profiles.count)
                }
            } catch is CancellationError {
                print("⚠️ Previous request cancelled")
            } catch let error as APIError {
                apiError = error
            } catch {
                apiError = .unknown(error)
            }
        }
    }

    func accept(_ profile: Profile) {
        updateStatus(for: profile, to: .accepted)
    }

    func reject(_ profile: Profile) {
        updateStatus(for: profile, to: .declined)
    }

    private func updateStatus(for profile: Profile, to status: ProfileMatchStatus) {
        do {
            try repository.updateStatus(profile: profile, status: status)
            guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
            var updated = profiles[index]
            updated.status = status
            profiles[index] = updated
        } catch {
            apiError = .unknown(error)
        }
    }
}
