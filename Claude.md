# CLAUDE.md - Field Game Planner iOS App

## Project Overview

Field Game Planner is a native iOS app for viewing Eton College field game fixtures, results, and standings. It connects to an existing Supabase backend (shared with the web app).

## Tech Stack

- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Minimum iOS:** 16.0
- **Architecture:** MVVM with Combine
- **Backend:** Supabase (PostgreSQL)
- **Package Manager:** Swift Package Manager

## Dependencies

```swift
// Only one external dependency
.package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
```

Native frameworks used: EventKit, Network, LocalAuthentication

## Project Structure

```
FieldGamePlanner/
├── App/                    # App entry point, AppState
├── Models/                 # Codable data models
├── ViewModels/             # ObservableObject view models
├── Views/
│   ├── Fixtures/           # Main fixtures list and calendar
│   ├── Results/            # Results list
│   ├── Standings/          # League tables
│   ├── PitchMaps/          # SVG-style pitch maps
│   ├── Settings/           # My House, Login
│   ├── Admin/              # Admin-only screens
│   └── Components/         # Reusable UI components
├── Services/               # Supabase, Auth, Cache, Calendar
└── Utilities/              # Colors, formatters, constants
```

## Key Design Decisions

1. **SwiftUI over UIKit** - Declarative UI maps well to the React web app
2. **No external UI libraries** - Native iOS look ("as if Apple designed it")
3. **Supabase Swift SDK** - Direct database access, same as web app
4. **Canvas API for maps** - Convert SVG coordinates to native drawing
5. **@AppStorage for preferences** - Equivalent to web's localStorage

## User Roles

- **Anonymous:** View-only, can set My House preference
- **Captain:** Enter scores for their house's matches (inline on card)
- **Admin:** Create captains, manage fixtures, view import logs

## Color Scheme

Primary color is Eton Green (#96c8a2). Competition types have specific colors (see ColorSystem.swift). Kit colors parsed from "red/white" format.

## Common Commands

```bash
# Build
xcodebuild -scheme FieldGamePlanner -destination 'platform=iOS Simulator,name=iPhone 15'

# Test
xcodebuild test -scheme FieldGamePlanner -destination 'platform=iOS Simulator,name=iPhone 15'

# Clean
xcodebuild clean -scheme FieldGamePlanner
```

## Supabase Configuration

Environment variables (create `Config.swift` - gitignored):
```swift
enum Config {
    static let supabaseURL = "https://xxx.supabase.co"
    static let supabaseAnonKey = "eyJ..."
}
```

## Database Views Used

- `upcoming_matches` - Fixtures with team details
- `recent_results` - Completed matches
- `league_standings` - Calculated standings
- `houses` - Team reference data

## Important Patterns

### ViewModel Pattern
```swift
@MainActor
class FixturesViewModel: ObservableObject {
    @Published var matches: [MatchWithHouses] = []
    @Published var isLoading = false

    func fetchMatches() async { ... }
}
```

### Color System Usage
```swift
// Competition color
Color.competitionColor(for: "Senior League") // Returns navy blue

// Kit colors
KitColorMapper.parse("red/white") // Returns [Color.red, Color.white]
```

### Pitch Map Coordinates
North and South field pitch coordinates are in `NorthFieldsMapView.swift` and `SouthFieldsMapView.swift`. Use Canvas API with scaled transforms.

## Testing Approach

- Unit tests for ViewModels and utilities
- UI tests for navigation flows
- Manual testing checklist in design document

## Reference: Web App Files

When implementing features, reference these web app files:
- `/src/types/database.ts` - Data models
- `/src/components/MatchCard.tsx` - Card UI and colors
- `/src/components/NorthFieldsMap.tsx` - North map SVG
- `/src/components/SouthFieldsMap.tsx` - South map SVG
- `/src/app/page.tsx` - Fixtures page logic

## Do Not

- Add unnecessary dependencies
- Over-engineer (keep it simple)
- Deviate from Apple HIG
- Store sensitive data outside Keychain
- Make network calls on main thread
