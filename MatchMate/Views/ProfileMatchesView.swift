import SwiftUI

struct ProfileMatchesView: View {
    @State private var profiles = Profile.samples

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                Text("Profile Matches")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                ForEach(profiles) { profile in
                    ProfileCardView(
                        profile: profile,
                        onReject: { reject(profile) },
                        onAccept: { accept(profile) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.matchMateBackground)
    }

    private func reject(_ profile: Profile) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        profiles[index].status = .declined
    }

    private func accept(_ profile: Profile) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        profiles[index].status = .accepted
    }
}

#Preview {
    ProfileMatchesView()
}
