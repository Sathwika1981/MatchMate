import SwiftUI

struct ProfileCardView: View {
    let profile: Profile
    var onReject: (() -> Void)?
    var onAccept: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            profileImage

            Text(profile.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.matchMateAccent)
                .multilineTextAlignment(.center)

            Text(profile.locationLine)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            footer
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }

    private var profileImage: some View {
        Image(systemName: "person.crop.square.fill")
            .resizable()
            .scaledToFill()
            .foregroundStyle(.gray.opacity(0.35))
            .frame(width: 200, height: 200)
            .background(Color.gray.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    @ViewBuilder
    private var footer: some View {
        switch profile.status {
        case .pending:
            HStack(spacing: 80) {
                actionCircle(icon: "xmark", action: onReject)
                actionCircle(icon: "checkmark", action: onAccept)
            }
            .padding(.top, 8)

        case .accepted:
            Text("Accepted")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.matchMateAccent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.top, 8)
            
        case .declined:
            Text("Declined")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.matchMateAccent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.top, 8)
        }
        
    }

    private func actionCircle(icon: String, action: (() -> Void)?) -> some View {
        Button {
            action?()
        } label: {
            Image(systemName: icon)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(width: 56, height: 56)
                .overlay {
                    Circle()
                        .stroke(Color.matchMateAccent, lineWidth: 2)
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview("Pending") {
    ProfileCardView(profile: Profile.samples[0])
        .padding()
        .background(Color.matchMateBackground)
}

#Preview("Accepted") {
    ProfileCardView(profile: Profile.samples[1])
        .padding()
        .background(Color.matchMateBackground)
}
