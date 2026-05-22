import Foundation

protocol ProfileRepositoryProtocol: AnyObject {
    var onProfilesUpdated: (@MainActor ([Profile]) -> Void)? { get set }
    func fetchProfiles() async throws -> [Profile]
    func updateStatus(profile: Profile, status: ProfileMatchStatus) throws
}

final class ProfileRepository: ProfileRepositoryProtocol {

    private let apiService: ProfileServiceProtocol
    private let coreDataManager: CoreDataManagerProtocol
    private let networkMonitor: NetworkMonitor

    private var wasConnected = true
    private var connectivityObserver: NSObjectProtocol?

    var onProfilesUpdated: (@MainActor ([Profile]) -> Void)?

    init(
        apiService: ProfileServiceProtocol = ProfileService(),
        coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared,
        networkMonitor: NetworkMonitor = .shared
    ) {
        self.apiService = apiService
        self.coreDataManager = coreDataManager
        self.networkMonitor = networkMonitor
        self.wasConnected = networkMonitor.isConnected

        observeConnectivity()
    }

    deinit {
        if let connectivityObserver {
            NotificationCenter.default.removeObserver(connectivityObserver)
        }
    }

    func fetchProfiles() async throws -> [Profile] {

        let savedProfiles = try coreDataManager.fetchProfiles()
        print("saved profiles: \(savedProfiles.count)")

        guard networkMonitor.isConnected else {
            if savedProfiles.isEmpty {
                throw APIError.noInternet
            }
            return savedProfiles
        }

        do {
            let remoteProfiles = try await apiService.fetchProfiles()
            let savedIDs = Set(savedProfiles.map(\.id))

            let uniqueRemoteProfiles = remoteProfiles.filter {
                !savedIDs.contains($0.id)
            }

            let mergedRemoteProfiles = mergeSavedStatuses(into: uniqueRemoteProfiles)
            let finalProfiles = savedProfiles + mergedRemoteProfiles
            
            print("Profiles from server:", finalProfiles.count)
            
            return savedProfiles + mergedRemoteProfiles

        } catch {
            if !savedProfiles.isEmpty {
                return savedProfiles
            }
            throw error
        }
    }

    func updateStatus(profile: Profile, status: ProfileMatchStatus) throws {
        try coreDataManager.updateProfile(profile: profile, status: status)
    }

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

            if isConnected, !self.wasConnected {
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

            await MainActor.run {
                onProfilesUpdated?(profiles)
            }

        } catch {}
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
