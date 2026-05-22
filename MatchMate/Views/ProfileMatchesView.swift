import SwiftUI

struct ProfileMatchesView: View {
    @StateObject private var viewModel = ProfileMatchesViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                Text("Profile Matches")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                content
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.matchMateBackground)
        .task {
            await viewModel.loadProfiles()
        }
        .refreshable {
            await viewModel.loadProfiles()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.profiles.isEmpty {
            ProgressView("Loading profiles…")
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
        } else if let error = viewModel.apiError, viewModel.profiles.isEmpty {
            errorView(error)
        } else {
            ForEach(viewModel.profiles) { profile in
                ProfileCardView(
                    profile: profile,
                    onReject: { reject(profile) },
                    onAccept: { accept(profile) }
                )
            }
        }
    }

    private func errorView(_ error: APIError) -> some View {
        ContentUnavailableView {
            Label(error.title, systemImage: error.systemImageName)
        } description: {
            Text(error.errorDescription ?? "Something went wrong. Please try again.")
        } actions: {
            Button("Try Again") {
                Task { await viewModel.loadProfiles() }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private func reject(_ profile: Profile) {
        updateStatus(for: profile, to: .declined)
    }

    private func accept(_ profile: Profile) {
        updateStatus(for: profile, to: .accepted)
    }

    private func updateStatus(for profile: Profile, to status: ProfileMatchStatus) {
        guard let index = viewModel.profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        var updated = viewModel.profiles[index]
        updated.status = status
        viewModel.profiles[index] = updated
    }
}

#Preview {
    ProfileMatchesView()
}
