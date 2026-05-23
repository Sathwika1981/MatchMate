MatchMate

MatchMate is a simple matchmaking-style iOS app built using SwiftUI. It focuses on clean architecture, offline support, and a smooth user experience for accepting or declining profile matches.

The goal of this project is to demonstrate how a real-world app can be structured using MVVM + Repository pattern, while keeping data consistent across network and local storage.

What the app does
1. Shows a list of user profiles in a card-based UI
2. Lets users Accept or Decline matches
3. Saves decisions locally so they persist after app restart
4. Works even without internet using cached data
5. Syncs data automatically when network is available again

The app follows a simple but scalable MVVM + Repository setup:

UI (SwiftUI Views)
   ↓
ViewModel
   ↓
Repository
   ↓
Data Sources (API / Core Data)

Why this architecture

I kept the structure modular so that:

1. UI stays clean and dumb
2. Business logic is testable
3. Data layer can switch sources without affecting UI
4. Offline support is easy to manage

Core Data is used as a local cache so the app still works without internet.

Tech used:
1. Swift 5
2. SwiftUI
3. Combine / @Published
4. Core Data
5. URLSession
6. MVVM + Repository pattern

Data handling
The app stores:

1. Profiles fetched from API
2. User actions (Accepted / Declined status)
3. Cached responses for offline use

So even after killing the app, your last state is still there

Accept / Decline flow:

When you tap:
Accept

1. Profile status is updated to “Accepted”
2. Saved in Core Data
3. UI updates immediately

Decline

1. Status updated to “Declined”
2. Stored locally
3. Card updates or gets removed based on state

Offline behavior

If the device goes offline:

1. App falls back to Core Data
2. Previously loaded profiles still appear
3. No crashes or empty screens

When back online:

Repository syncs and refreshes data automatically

Running the project:

git clone https://github.com/yourusername/MatchMate.git
cd MatchMate
open MatchMate.xcodeproj

Then just run on the Xcode

What I’d improve next

If this were a production app, I’d add:

1. Search & filters for profiles
2. Chat after a match
3. Push notifications
4. Cloud sync (CloudKit/Firebase)
5. UI tests + better unit test coverage
