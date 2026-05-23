import Combine
import Foundation

final class ProfileMatchesViewModel: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var isLoading = false
    @Published private(set) var apiError: APIError?

    private let repository: ProfileRepositoryProtocol
    private var loadTask: Task<Void, Never>?
    
    private let logger : AppLogger

    init(
        repository: ProfileRepositoryProtocol = ProfileRepository(),
        logger: AppLogger = .shared
    ) {
        self.repository = repository
        self.logger = logger
        
        repository.onProfilesUpdated = { [weak self] profiles in
            self?.profiles = profiles
            self?.apiError = nil
        }
    }

    func loadProfiles() {
        // Explicitly cancelling any existing task before starting a new fetch request
        // to prevent overlapping API calls and ensure a consistent refresh experience.
        logger.info("loadProfiles called", category: .profile)
        loadTask?.cancel()
        
        loadTask = Task {
            isLoading = true
            apiError = nil
            
            defer { isLoading = false }
            
            do {
                let profiles = try await repository.fetchProfiles()
                logger.info("Fetched \(profiles.count) profiles")
                
                if !Task.isCancelled {
                    self.profiles = profiles
                }
            } catch {
                apiError = .unknown(error)
                logger.error("Fetch failed: \(error.localizedDescription)")
            }
        }
    }

    func accept(_ profile: Profile) {
        logger.info("Accept tapped for profileId=\(profile.id)")
        updateStatus(for: profile, to: .accepted)
    }

    func reject(_ profile: Profile) {
        logger.info("Reject tapped for profileId=\(profile.id)")
        updateStatus(for: profile, to: .declined)
    }

    private func updateStatus(for profile: Profile, to status: ProfileMatchStatus) {
        do {
            try repository.updateStatus(profile: profile, status: status)
            guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else {
                logger.warning("Profile not found")
                return
            }
            var updated = profiles[index]
            updated.status = status
            profiles[index] = updated
            logger.info("Local state updated at index \(index)")
        } catch {
            apiError = .unknown(error)
            logger.error("Update status failed: \(error.localizedDescription)")
        }
    }
}
