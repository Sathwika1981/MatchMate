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
            viewModel.loadProfiles()
        }
        .refreshable {
            viewModel.loadProfiles()
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
                    onReject: { viewModel.reject(profile) },
                    onAccept: { viewModel.accept(profile) }
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
                Task { viewModel.loadProfiles() }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
}

#Preview {
    ProfileMatchesView()
}
