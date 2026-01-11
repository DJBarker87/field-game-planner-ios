# Field Game Planner - iOS App Design Document

## 1. Executive Summary

**App Name:** Field Game Planner
**Platform:** iOS 16.0+
**Devices:** iPhone and iPad (Universal)
**Orientation:** Portrait and Landscape
**Distribution:** Unlisted on App Store
**Architecture:** SwiftUI + MVVM + Combine
**Backend:** Supabase (existing, no changes required)
**Repository:** Separate repo (`field-game-planner-ios`) - not in web app repo

---

## 2. User Roles & Authentication

### 2.1 User Types

| Role | Capabilities |
|------|--------------|
| **Anonymous** | View fixtures, results, standings, pitch maps. Set "My House" preference. Export to calendar. |
| **Captain** | All anonymous features + Enter scores for matches where their house is playing |
| **Admin** | All captain features + Create captain accounts, manually add/edit fixtures, view import logs |

### 2.2 Authentication Flow

- **Method:** Email + Password (Supabase Auth)
- **Account Creation:** Pre-created by admins only (no self-registration)
- **First Admin:** Created directly in Supabase dashboard
- **Session Duration:** Indefinite (until manual logout)
- **Biometric:** Face ID / Touch ID for quick re-authentication after initial login
- **Forgot Password:** Yes - sends reset email via Supabase

### 2.3 Login UI

- Login accessible via gear icon in navigation
- Score entry UI only visible to logged-in captains/admins
- Anonymous users see no indication that score entry exists

---

## 3. Features Specification

### 3.1 Fixtures (Main Tab)

**Views:**
- List View (default)
- Calendar View (month and week options)

**Filters:**
- Time Period: Today / Tomorrow / This Week / All (segmented control)
- House: Dropdown with all houses
- School Team: Dropdown (Field, 2nd Field, etc.)
- Umpire: Dropdown populated from match data

**Match Card Display:**
- Time (12-hour format, e.g., "2:25pm")
- Home team with kit color dots
- Away team with kit color dots (if vs match)
- Bib color indicators for house vs house matches
- Competition type badge with color coding
- Pitch name (tappable → opens pitch map)
- Umpires (if assigned)
- **For Captains:** Inline score entry for their house's matches

**Calendar View:**
- Month navigation with month tabs
- Week view option
- Today highlight
- Match indicators on dates
- Tap date → shows matches for that day
- Tap match → shows detail modal

### 3.2 Results Tab

**Display:**
- Completed matches from current calendar year
- Same card format as fixtures but with scores displayed
- Filter by house/school team
- Grouped by date (most recent first)

### 3.3 Standings Tab

**Display:**
- League table format: Position, Team, P, W, D, L, GD, Pts
- Team kit colors shown
- **Competition Tabs/Filters:** Senior League, Junior League, etc.
- Tap team → filter fixtures/results to that team

### 3.4 Pitch Maps

**Two Maps:**
1. **North Fields:** Agar's 1-7, Dutchman's 1-15, Austin's, O.E. Soccer, College Field
2. **South Fields:** South Meadow 1-5, Warre's, Carter's, Square Close

**Behavior:**
- Opens as bottom sheet
- If specific pitch selected, shows only relevant map with highlight
- If no pitch selected, shows both maps
- Tap pitch → shows pitch name tooltip

### 3.5 Settings (Gear Icon)

**Anonymous Users:**
- My House selection (persists via @AppStorage)
- About / Version info

**Logged-in Users:**
- All above + Logout option
- Account info display

**Admin-only Section:**
- Create Captain Account
- Add/Edit Fixture
- View Import Logs

### 3.6 Score Entry (Captains)

**Eligibility:** Only matches where captain's house is playing

**UI:** Inline on match card (not separate modal)

**Flow:**
1. Captain sees "Enter Score" on eligible upcoming/today matches
2. Tap → reveals score input fields
3. Enter home and away scores (any number allowed)
4. Confirmation prompt before submit
5. On submit → match status becomes "completed"
6. Navigate back to fixtures list

**Edit Window:**
- 5-minute edit window after submission
- After window closes, edit option hidden (not shown as disabled)

### 3.7 Admin Features

**Create Captain Account:**
1. Enter email address
2. Enter captain's house assignment
3. Enter temporary password
4. Submit → creates account
5. Captain must change password on first login

**Add/Edit Fixture:**
- All fields: Date, Time, Competition, Pitch, Home Team, Away Team, Umpires
- No duplicate/conflict validation required
- Edit existing fixtures (search by date/team)

**View Import Logs:**
- View-only list of email imports
- Shows: timestamp, email subject, matches imported count

### 3.8 Calendar Export

**Options:**
1. **Add to iOS Calendar:** Uses EventKit to create events
2. **Export as ICS:** Share sheet with .ics file

**Event Details:**
- Title: "Home v Away" or team name
- Location: Pitch name
- Time: Match time (default 14:25 if not set)
- Duration: 1 hour
- Notes: Competition type, umpires

---

## 4. Data Architecture

### 4.1 Backend (No Changes)

Existing Supabase PostgreSQL database with:
- `houses` table
- `matches` table
- `user_profiles` table (roles: viewer/captain/admin)
- `score_audit_log` table
- `import_log` table
- Views: `upcoming_matches`, `recent_results`, `league_standings`

### 4.2 iOS Data Models

```swift
struct House: Codable, Identifiable {
    let id: String
    let name: String
    let colours: String?

    var isSchoolTeam: Bool { /* regex check */ }
}

struct MatchWithHouses: Codable, Identifiable {
    let id: String
    let date: String
    let time: String?
    let competitionType: String
    let pitch: String
    let homeTeamId: String
    let awayTeamId: String?
    let umpires: String?
    let status: MatchStatus // scheduled/completed/cancelled
    let homeScore: Int?
    let awayScore: Int?
    let homeTeamName: String
    let homeTeamColours: String?
    let awayTeamName: String?
    let awayTeamColours: String?
}

struct LeagueStanding: Codable, Identifiable {
    let teamId: String
    let teamName: String
    let teamColours: String?
    let played, wins, draws, losses: Int
    let goalsFor, goalsAgainst, goalDifference, points: Int
}

struct UserProfile: Codable {
    let id: String
    let email: String
    let name: String?
    let role: UserRole // viewer/captain/admin
    let houseId: String?
}
```

### 4.3 Caching Strategy

- **Memory Cache:** NSCache with 5-minute TTL
- **Disk Cache:** JSON files for offline support
- **User Preferences:** @AppStorage (UserDefaults wrapper)

### 4.4 Offline Behavior

- Show cached data when offline
- Display "Last updated" timestamp
- Score entry blocked with "No connection" message
- Sync when back online

---

## 5. UI/UX Design

### 5.1 Design Language

**Style:** Apple Human Interface Guidelines compliant
**Feel:** "As if Apple designed it"
**Primary Color:** Eton Green (#96c8a2)

### 5.2 Color System

**Brand Colors:**
- Primary: #96c8a2 (Eton Green)
- Primary Dark: #528c61
- Primary Light: #e6f2e9

**Competition Colors (25+ types):**
| Competition | Color |
|------------|-------|
| Senior Ties | Gold (#D4AF37) |
| Senior League | Navy Blue (#1E4D8C) |
| Junior Shield | Purple (#6B21A8) |
| Junior League | Teal (#0D9488) |
| School Field | Dark Green (#166534) |
| Non-Specialist | Orange (#EA580C) |
| Training | Grey (#6B7280) |
| Patagonian | Light Blue (#0EA5E9) |

**Kit Colors (30+ team colors):**
Parse from "red/white" format, display as dual color dots.

### 5.3 Navigation Structure

```
TabView
├── Fixtures (calendar icon)
│   ├── List View
│   └── Calendar View (month/week)
├── Results (list.clipboard icon)
└── Standings (trophy icon)

Navigation Bar:
├── Title
└── Gear Icon → Settings Sheet
    ├── My House
    ├── Login/Logout
    └── Admin Section (if admin)
```

### 5.4 Component Patterns

- **Lists:** LazyVStack with sticky date headers
- **Cards:** Rounded corners (16pt), subtle shadow, left color accent bar
- **Filters:** Bottom sheet selection with search
- **Modals:** .sheet() with presentationDetents
- **Buttons:** Rounded, Eton Green tint
- **Segmented Controls:** Native iOS style

### 5.5 App Icon

Field game goalpost silhouette in Eton Green on white background.

---

## 6. Technical Specifications

### 6.1 Dependencies

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
]
```

No other external dependencies - use native frameworks:
- EventKit (calendar export)
- Network (connectivity monitoring)
- LocalAuthentication (Face ID / Touch ID)

### 6.2 Project Structure

```
FieldGamePlanner/
├── App/
│   ├── FieldGamePlannerApp.swift
│   └── AppState.swift
├── Models/
│   ├── House.swift
│   ├── Match.swift
│   ├── LeagueStanding.swift
│   ├── UserProfile.swift
│   └── Enums.swift
├── ViewModels/
│   ├── FixturesViewModel.swift
│   ├── ResultsViewModel.swift
│   ├── StandingsViewModel.swift
│   ├── AuthViewModel.swift
│   └── AdminViewModel.swift
├── Views/
│   ├── Fixtures/
│   │   ├── FixturesView.swift
│   │   ├── MatchCardView.swift
│   │   ├── MatchListView.swift
│   │   ├── MonthCalendarView.swift
│   │   └── WeekCalendarView.swift
│   ├── Results/
│   │   └── ResultsView.swift
│   ├── Standings/
│   │   └── StandingsView.swift
│   ├── PitchMaps/
│   │   ├── PitchMapSheet.swift
│   │   ├── NorthFieldsMapView.swift
│   │   └── SouthFieldsMapView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── MyHouseSheet.swift
│   │   └── LoginView.swift
│   ├── Admin/
│   │   ├── AdminDashboardView.swift
│   │   ├── CreateCaptainView.swift
│   │   ├── ManageFixturesView.swift
│   │   └── ImportLogsView.swift
│   └── Components/
│       ├── FilterDropdown.swift
│       ├── TimeSegmentedControl.swift
│       ├── KitColorDots.swift
│       ├── CompetitionBadge.swift
│       └── ScoreEntryView.swift
├── Services/
│   ├── SupabaseService.swift
│   ├── AuthService.swift
│   ├── CacheService.swift
│   ├── CalendarExportService.swift
│   └── NetworkMonitor.swift
├── Utilities/
│   ├── ColorSystem.swift
│   ├── DateFormatters.swift
│   └── Constants.swift
└── Resources/
    └── Assets.xcassets
```

### 6.3 Supabase Queries

```swift
// Fixtures
supabase.from("upcoming_matches")
    .select()
    .gte("date", startDate)
    .lte("date", endDate)
    .or("home_team_id.eq.\(id),away_team_id.eq.\(id)")
    .order("date")
    .order("time")

// Results (current calendar year)
let yearStart = "\(Calendar.current.component(.year, from: Date()))-01-01"
supabase.from("recent_results")
    .select()
    .gte("date", yearStart)

// Standings by competition
supabase.from("league_standings")
    .select()
    .eq("competition_type", competitionType)

// Score update
supabase.from("matches")
    .update(["home_score": homeScore, "away_score": awayScore, "status": "completed"])
    .eq("id", matchId)

// Create user (admin)
supabase.auth.admin.createUser(email: email, password: tempPassword)
supabase.from("user_profiles").insert(profile)
```

### 6.4 Authentication Flow

```swift
// Login
let session = try await supabase.auth.signIn(email: email, password: password)

// Check if first login (must change password)
if userProfile.mustChangePassword {
    // Navigate to change password screen
}

// Biometric unlock (after initial login)
let context = LAContext()
if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
    // Store session token in Keychain
    // On app launch, authenticate with biometric before restoring session
}

// Forgot password
try await supabase.auth.resetPasswordForEmail(email)
```

---

## 7. App Store Requirements

- **Minimum iOS:** 16.0
- **Privacy:** Calendar access (Info.plist description)
- **Capabilities:** Background App Refresh
- **Distribution:** Unlisted (requires direct link)
- **Category:** Sports
- **Age Rating:** 4+

---

## 8. Testing Requirements

### 8.1 Unit Tests
- ViewModel logic (filtering, date ranges)
- Color parsing (kit colors, competition colors)
- Model decoding
- Score validation

### 8.2 UI Tests
- Tab navigation
- Filter selection flows
- Score entry flow (captain)
- Admin account creation flow

### 8.3 Manual Testing Checklist
- [ ] Anonymous user can view fixtures
- [ ] Anonymous user can set My House
- [ ] Anonymous user cannot see score entry
- [ ] Captain can log in
- [ ] Captain sees score entry for their matches only
- [ ] Captain can submit score
- [ ] Captain can edit within 5 minutes
- [ ] Captain cannot edit after 5 minutes
- [ ] Admin can create captain account
- [ ] Admin can add fixture
- [ ] Pitch maps display correctly
- [ ] Calendar export works
- [ ] Offline mode shows cached data
- [ ] Face ID unlock works

---

## 9. Reference Files (Web App)

| Purpose | File Path |
|---------|-----------|
| Data types | `/src/types/database.ts` |
| Competition/kit colors | `/src/components/MatchCard.tsx` |
| Filter logic | `/src/app/page.tsx` |
| North map coordinates | `/src/components/NorthFieldsMap.tsx` |
| South map coordinates | `/src/components/SouthFieldsMap.tsx` |
| Calendar component | `/src/components/MonthlyCalendar.tsx` |
| Results page | `/src/app/results/page.tsx` |
| Standings page | `/src/app/standings/page.tsx` |
| Database schema | `/supabase/migrations/001_initial_schema.sql` |
