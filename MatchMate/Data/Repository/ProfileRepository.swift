import Foundation

final class ProfileRepository: ProfileRepositoryProtocol {

    private let apiService: ProfileServiceProtocol
    private let coreDataManager: CoreDataManagerProtocol
    private let networkMonitor: NetworkMonitor
    
    private let logger : AppLogger

    private var wasConnected = true
    private var connectivityObserver: NSObjectProtocol?

    var onProfilesUpdated: (@MainActor ([Profile]) -> Void)?

    init(
        apiService: ProfileServiceProtocol = ProfileService(),
        coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared,
        networkMonitor: NetworkMonitor = .shared,
        logger: AppLogger = .shared
    ) {
        self.apiService = apiService
        self.coreDataManager = coreDataManager
        self.networkMonitor = networkMonitor
        self.wasConnected = networkMonitor.isConnected
        self.logger = logger

        observeConnectivity()
    }

    deinit {
        if let connectivityObserver {
            NotificationCenter.default.removeObserver(connectivityObserver)
        }
    }

    func fetchProfiles() async throws -> [Profile] {

        let savedProfiles = try coreDataManager.fetchProfiles()
        logger.debug("Local cache loaded: \(savedProfiles.count)", category: .network)

        guard networkMonitor.isConnected else {
            logger.warning("No internet connection detected", category: .network)
            
            if savedProfiles.isEmpty {
                throw APIError.noInternet
            }
            
            logger.info("Returning cached profiles only", category: .network)
            return savedProfiles
        }

        do {
            let userResponse = try await apiService.fetchProfiles()
            let remoteProfiles = ProfileMapper.toDomain(userResponse)
            
            logger.info("Remote fetch success: \(remoteProfiles.count)", category: .network)

            let savedIDs = Set(savedProfiles.map(\.id))

            // Filtering out profiles that are already stored locally to avoid
            // duplicates when new data is fetched from the API.
            let uniqueRemoteProfiles = remoteProfiles.filter {
                !savedIDs.contains($0.id)
            }

            let mergedRemoteProfiles = mergeSavedStatuses(into: uniqueRemoteProfiles)
            let finalProfiles = savedProfiles + mergedRemoteProfiles
            
            print("Profiles from server:", finalProfiles.count)
            
            return savedProfiles + mergedRemoteProfiles

        } catch {
            if !savedProfiles.isEmpty {
                logger.warning("Falling back to cached profiles", category: .network)
                return savedProfiles
            }
            throw error
        }
    }

    func updateStatus(profile: Profile, status: ProfileMatchStatus) throws {
        try coreDataManager.updateProfile(profile: profile, status: status)
        logger.debug("CoreData updated successfully", category: .network)
    }

    // Observing network connectivity changes using NotificationCenter to automatically
    // sync and refresh profiles when internet connection is restored after offline usage.
    private func observeConnectivity() {
        connectivityObserver = NotificationCenter.default.addObserver(
            forName: .networkStatusChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            
            guard let self,
                  let isConnected = notification.userInfo?["isConnected"] as? Bool else {
                return
            }
            
            self.logger.info("Network status changed: \(isConnected)", category: .network)

            if isConnected, !self.wasConnected {
                self.logger.info("Network restored, triggering sync", category: .network)
                Task {
                    await self.syncWhenBackOnline()
                }
            }

            self.wasConnected = isConnected
        }
    }

    private func syncWhenBackOnline() async {
        do {
            let profiles = try await fetchProfiles()

            // Executed on MainActor because updating profiles triggers UI state changes
            // and all UI-related updates must happen on the main thread.
            await MainActor.run {
                onProfilesUpdated?(profiles)
            }

        } catch {
            logger.error("Sync failed: \(error.localizedDescription)", category: .network)
        }
    }

    private func mergeSavedStatuses(into profiles: [Profile]) -> [Profile] {
        let savedStatuses = (try? coreDataManager.fetchProfiles())?
            .reduce(into: [String: ProfileMatchStatus]()) { result, profile in
                result[profile.id] = profile.status
            } ?? [:]

        let mergedProfiles = profiles.map { profile in

            var copy = profile

            if let saved = savedStatuses[profile.id],
               saved != .pending {
                copy.status = saved
            }

            return copy
        }
        return mergedProfiles
    }
}
