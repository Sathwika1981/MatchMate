import SwiftUI

struct ProfileMatchesView: View {
    @StateObject private var viewModel: ProfileMatchesViewModel
    private let logger: AppLogger
    
    init(
        viewModel: ProfileMatchesViewModel = ProfileMatchesViewModel(),
        logger: AppLogger = .shared
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel
        )
        self.logger = logger
    }
    
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
            logger.info("ProfileMatchesView appeared - .task triggered", category: .ui)
            viewModel.loadProfiles()
        }
        .refreshable {
            logger.info("Pull-to-refresh triggered", category: .ui)
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
    let mockViewModel = ProfileMatchesViewModel()

        mockViewModel.profiles = [
            Profile.preview,
            Profile.previewAccepted
        ]

    return ProfileMatchesView(viewModel: mockViewModel)
}
