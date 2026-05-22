import Foundation

protocol ProfileRepositoryProtocol: AnyObject {
    var onProfilesUpdated: (@MainActor ([Profile]) -> Void)? { get set }
    func fetchProfiles() async throws -> [Profile]
    func updateStatus(profile: Profile, status: ProfileMatchStatus) throws
}
