# Think Rush ⚡
### A Real-Time Multiplayer Competitive Brain Battle Game

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20(Portrait)-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![Tests](https://img.shields.io/badge/Tests-17%20Passing-brightgreen?style=for-the-badge&logo=checkmarx&logoColor=white)](test/)
[![License](https://img.shields.io/badge/License-Academic%20%2F%20MIT-blue?style=for-the-badge)](LICENSE)

---

## 📖 Project Overview

**Think Rush** is an Android-first, mobile competitive brain-battle game developed using **Flutter**, **Dart**, and **Firebase**. Built with an original dark neon competitive gaming aesthetic, Think Rush transforms cognitive exercises—arithmetic, sequence deduction, visual memory, logic reasoning, and lexical agility—into high-intensity, head-to-head 60-second battles.

Rather than isolating brain training into solitary drills, Think Rush emphasizes **real-time multiplayer competition**, **speed bonus mechanics**, **adaptive question difficulty**, and **instant response evaluation**. Players compete under strict time pressure where correct answers yield streaks and speed multipliers, while mistakes inflict severe time penalties.

The system is architected with a **Dual-Engine Model**:
1. **Cloud-Connected Engine**: Powered by Firebase Authentication and Cloud Firestore for live cross-device 1v1 battles, deterministic synchronized challenge generation, and persistent cloud stats.
2. **Offline Resilience Engine**: Seamlessly falls back to local persistent storage (`SharedPreferences`) and intelligent offline AI bots whenever internet connectivity or Firebase configuration is unavailable.

---

## 🎯 Project Objectives

- **Gamified Cognitive Performance**: Combine mathematical fluency, memory retention, pattern recognition, and logic puzzles into rapid 60-second competitive rounds.
- **Synchronized 2-Device Multiplayer**: Enable cross-network, head-to-head matches between two physical Android devices using deterministic pseudorandom seed synchronization and live Firestore score streaming.
- **Private Room Battles**: Allow friends to face off directly using private 4-digit room codes without bots or timeout interruptions.
- **Adaptive Player Progression**: Implement dynamic difficulty adjustment that reacts in real time to player streaks and error thresholds.
- **Production-Grade Mobile Architecture**: Adhere to clean architectural separation (Core, Models, Providers, Services, Widgets, Screens) ensuring testability, maintainability, and zero UI thread stalls.

---

## 🚀 Key Features

| Feature | Description | Status |
| :--- | :--- | :---: |
| **5 Cognitive Battle Modes** | Math Rush, Pattern Finder, Memory Flash, Logic Grid, and Word Rush. | ✅ Implemented |
| **Dual Multiplayer Modes** | Global Matchmaking (Radar Queue) + Private Custom Rooms (4-Digit PIN). | ✅ Implemented |
| **Zero-Bot Custom Matches** | Dedicated 2-phone room lobby that waits indefinitely for human opponent connection. | ✅ Implemented |
| **Deterministic Seed Sync** | Shared random seed enables identical question sequences on both phones without bandwidth lag. | ✅ Implemented |
| **Adaptive Difficulty Engine** | Levels 1 through 6 dynamically scale up on success and de-escalate after consecutive errors. | ✅ Implemented |
| **Time Penalty Mechanics** | Incorrect choices subtract 3 seconds from the round clock and reset active streaks to zero. | ✅ Implemented |
| **Multi-Tier AI Opponents** | Practice against Easy, Medium, and Hard AI with realistic thinking delays and error rates. | ✅ Implemented |
| **Comprehensive Metagame** | Global/Weekly/Friends Leaderboards with podium, 7-Day Login Rewards, 5 Achievements, and Player Profile with 6 unlockable avatars. | ✅ Implemented |
| **Dual-Engine Authentication** | Firebase Email/Password, Anonymous Instant Guest Play, and offline session fallback. | ✅ Implemented |
| **Portrait-Locked UX** | Strictly vertical portrait orientation enforced at native Android and Flutter levels. | ✅ Implemented |

---

## 🎮 Game Modes

All five game modes are fully implemented with custom procedural generation algorithms. Each mode supports **Single Player**, **VS AI**, and **Multiplayer**.

```
+-----------------------------------------------------------------------------------+
|                                 5 COGNITIVE MODES                                 |
+-------------------+--------------------+--------------------+--------------------+--------------------+
| 1. MATH RUSH      | 2. PATTERN FINDER  | 3. MEMORY FLASH    | 4. LOGIC GRID      | 5. WORD RUSH       |
| Arithmetic Duel   | Sequence Deduction | Visual Sequence    | Deductive Clues    | Lexical Speed      |
| (+, -, ×, ÷)      | (Math Series)      | (● ▲ ■ ★ ✦ ◆)      | (Relational Logic) | (Unscramble Words) |
+-------------------+--------------------+--------------------+--------------------+--------------------+
```

### 1. Math Rush (`GameModeType.mathRush`)
- **Objective**: Solve single-operation arithmetic problems under extreme speed pressure.
- **Allowed Operations**: Addition ($+$), Subtraction ($-$), Multiplication ($\times$), and Division ($\div$).
- **Integrity Rule**: Division problems **never produce fractions or decimals**; questions are guaranteed whole-number integers ($a \times b \to [a \cdot b] \div b = a$). Mixed-operation operator chaining is strictly disallowed.
- **Round Duration**: 60 seconds.
- **Difficulty Scaling**:
  - *Level 1*: Small addition and subtraction ($\le 20$).
  - *Level 2*: Multi-digit addition and subtraction ($\le 100$).
  - *Level 3*: Core multiplication tables ($2$ to $9$).
  - *Level 4*: Extended multiplication ($6$ to $15$).
  - *Level 5*: Whole-number integer division with clean divisors.
  - *Level 6*: High-magnitude single-operation arithmetic calculations.

### 2. Pattern Finder (`GameModeType.patternFinder`)
- **Objective**: Identify the missing value (`?`) in a mathematical or logical sequence.
- **Pattern Rules**:
  - Arithmetic progressions (constant difference $+d$ or $-d$).
  - Geometric progressions (constant multiplier $\times 2, \times 3, \times 5$).
  - Alternating operations ($+3, -1, +3, -1$).
  - Fibonacci-style additive series ($x_n = x_{n-1} + x_{n-2}$).
  - Exponential & square series ($1, 4, 9, 16, 25, \dots$).
- **Round Duration**: 60 seconds. 4 distinct answer options per question.

### 3. Memory Flash (`GameModeType.memoryFlash`)
- **Objective**: Memorize a flashed sequence of distinct geometric symbols, then accurately identify the correct sequence or targeted symbol position from memory.
- **Symbol Set**: `●`, `▲`, `■`, `★`, `✦`, `◆`.
- **Special Mechanics**: Two-phase question lifecycle:
  1. *Flash Phase*: Sequence is displayed with a countdown preview (1.2s to 2.5s depending on difficulty).
  2. *Recall Phase*: Symbols disappear; player selects the exact sequence from 4 candidate permutations.
- **Difficulty Scaling**:
  - *Level 1*: 3 symbols.
  - *Level 2*: 4 symbols.
  - *Level 3*: 5 symbols.
  - *Level 4*: 6 symbols.
  - *Level 5*: 7 symbols.
  - *Level 6*: 8 symbols.

### 4. Logic Grid (`GameModeType.logicGrid`)
- **Objective**: Analyze short premise statements and deduce the logically sound conclusion.
- **Challenge Types**:
  - Relative comparisons (*"A is faster than B, C is slower than B. Who is fastest?"*).
  - Spatial and rank ordering (*"X is above Y, Z is below Y. Which item is on bottom?"*).
  - Truth statements and property deductions (*"All squares are shapes. All shapes have borders. Are squares bordered?"*).
- **Round Duration**: 60 seconds. 4 logical options per deduction.

### 5. Word Rush (`GameModeType.wordRush`)
- **Objective**: Unscramble randomized anagrams, complete missing vocabulary letters, and identify semantic word relationships.
- **Challenge Types**:
  - Anagram unscrambling (*e.g., "P L P A E" $\to$ APPLE*).
  - Missing-letter fill-in (*e.g., "B R _ I N" $\to$ A*).
  - Rapid synonym/antonym identification.
- **Round Duration**: 60 seconds. 4 lexical candidate buttons.

---

## 🕹️ Play Modes

### 1. Single Player (Solo Practice)
- **Status**: ✅ **Fully Implemented**
- **Description**: Offline, distraction-free practice environment.
- **Mechanics**: Players select any of the 5 modes to hone their speed and accuracy against the 60-second clock. Results award XP, coins, and update personal best scores.

### 2. VS AI (Bot Battle)
- **Status**: ✅ **Fully Implemented**
- **Description**: Play against simulated AI opponents with non-deterministic humanized behavior.
- **Difficulty Levels**:
  - **Easy**: 55% accuracy, 2.5s – 4.5s reaction delay.
  - **Medium**: 75% accuracy, 1.5s – 3.0s reaction delay.
  - **Hard**: 92% accuracy, 0.8s – 1.8s reaction delay.
- **Mechanics**: The AI "thinks" asynchronously during each question, accumulates realistic streaks, occasionally errs, and streams its score alongside the player's live progress bar.

### 3. Multiplayer
- **Status**: ✅ **Fully Implemented**
- **Architecture**: Dual multiplayer sub-systems powered by Cloud Firestore.

#### A. Custom Room (Private 2-Device Clash)
- **Status**: ✅ **Fully Implemented**
- **Access**: Located directly on the Home Screen Hero Banner (**CUSTOM GAME**) and under Battle Modes.
- **Flow**:
  1. *Host Device*: Taps **CREATE ROOM**, selects game mode, and receives an autogenerated **4-digit PIN** (e.g., `4821`).
  2. *Host Waiting Lobby*: Displays the code, copy button, and waits in an active stream listener. **Zero bots are used, and no timeout exists.** The room stays open indefinitely until the friend joins or host cancels.
  3. *Guest Device*: Taps **CUSTOM GAME** $\to$ **JOIN ROOM**, enters the 4-digit code, and connects.
  4. *Atomic Pairing*: Firestore document (`matches/room_4821`) atomically updates `player2` and status to `countdown`.
  5. *Synchronized 3-2-1 Start*: Both phones display a synchronized countdown overlay and transition to gameplay.
- **Same-Account Testing**: If two test phones use the same user profile or guest account, Player 2 is automatically assigned a client suffix (`_p2`) to avoid document ID collisions.

#### B. Public Matchmaking (Global Radar)
- **Status**: ✅ **Fully Implemented**
- **Access**: Tapping **QUICK PLAY** or **Multiplayer** from the game modes screen.
- **Flow**: Searches the global Firestore matchmaking pool for open rooms with status `waiting`. If an opponent is found, it pairs immediately; if no player joins within 15 seconds, it safely matches with a practice opponent so solo players are never stranded.

---

## ⚡ Gameplay Mechanics

```
   [ 3.. 2.. 1.. GO! ]
            │
            ▼
┌───────────────────────┐
│     Question Card     │
│   (Math/Logic/Word)   │
└───────────┬───────────┘
            │
     Player Selection
            │
   ┌────────┴────────┐
   ▼                 ▼
[ CORRECT ]       [ WRONG ]
   │                 │
   ├─ +100 Base Pts  ├─ -3 Seconds Penalty Clock
   ├─ +Speed Bonus   ├─ Streak Reset to 0
   ├─ Streak +1      ├─ Highlight Correct Option
   └─ Difficulty +1  └─ 2 Consecutive Wrong = Difficulty -1
```

1. **Synchronized 3-2-1 Countdown**: All matches commence with an animated 3-second countdown before questions unlock.
2. **Four Answer Choices**: Every challenge presents 4 distinct, randomized options.
3. **Speed Bonus**: Players earn up to 50 additional bonus points for answering within the first 5 seconds.
4. **Streak Multiplier**: Consecutive correct answers accumulate an increasing multiplier badge ($+10 \times \text{Streak}$).
5. **Time Penalty (-3s)**: Choosing an incorrect option triggers a red shake feedback animation, displays a floating `"-3 SEC"` toast, deducts 3 seconds from the clock, and resets the streak to 0.
6. **Non-Negative Score Floor**: Scores are clamped at $\ge 0$ and never drop into negative values.

---

## 📊 Scoring System

$$\text{Total Points} = \text{Base Points} + \text{Speed Bonus} + \text{Streak Bonus}$$

| Component | Formula / Rule | Range |
| :--- | :--- | :---: |
| **Base Score** | Awarded for each correct answer | $100\text{ pts}$ |
| **Speed Bonus** | $\max\left(0, \lfloor(5.0 - \text{elapsedSeconds}) \times 10\rfloor\right)$ | $0 - 50\text{ pts}$ |
| **Streak Bonus** | $\text{streak} \times 10$ | $0 - 100+\text{ pts}$ |
| **Wrong Answer Penalty** | $-3\text{ seconds}$ from round timer; Streak $\to 0$ | $-3\text{s}$ |
| **Minimum Score Clamp** | $\text{Score} = \max(0, \text{Score})$ | $\ge 0$ |

---

## 📈 Adaptive Difficulty Engine

```
[Level 1] ──(+)──> [Level 2] ──(+)──> [Level 3] ──(+)──> [Level 4] ──(+)──> [Level 5] ──(+)──> [Level 6]
    ▲                  ▲                  ▲                  ▲                  ▲                  ▲
    │                  │                  │                  │                  │                  │
    └───────(-2)───────┴───────(-2)───────┴───────(-2)───────┴───────(-2)───────┴───────(-2)───────┘
```

- **Initial Level**: Level 1.
- **Promotion (+1)**: Each correct answer advances the difficulty level by $+1$ up to **Level 6** maximum.
- **Demotion (-1)**: A single wrong answer retains the current difficulty level; **two consecutive wrong answers** decrease the difficulty level by $-1$ (down to Level 1 minimum).
- **Reset Trigger**: Decreasing difficulty resets the consecutive error counter to 0.

---

## 🤖 AI Opponent System

The AI opponent service (`AiOpponentService`) runs asynchronously during VS AI matches. Rather than hardcoding fixed scores, the AI generates simulated human responses:

| Tier | Accuracy | Response Time Range | Behavior Characteristics |
| :--- | :---: | :---: | :--- |
| **Easy** | $55\%$ | $2.5\text{s} - 4.5\text{s}$ | Frequent mistakes, low streak maintenance, casual pacing. |
| **Medium** | $75\%$ | $1.5\text{s} - 3.0\text{s}$ | Steady speed, moderate streaks, realistic error rate. |
| **Hard** | $92\%$ | $0.8\text{s} - 1.8\text{s}$ | Rapid responses, long streak multipliers, formidable competitor. |

---

## 🌐 Multiplayer & Network Architecture

### Deterministic Seed Synchronization
Transmitting entire question structures across the wire causes latency spikes. Think Rush solves this by generating a single 32-bit random integer `seed` at match creation:
```dart
// Host creates match with shared seed
final seed = Random().nextInt(1000000);

// Both devices instantiate deterministic generators
final generator = MathRushGenerator(Random(seed));
```
Because the pseudorandom sequence is identical on both devices, **both players receive the exact same sequence of questions and distractors** without transmitting puzzle payloads over the network.

### Real-Time Score Streaming
During active gameplay, each player's answers trigger an atomic Firestore field update:
```dart
await firestore.collection('matches').doc(matchId).update({
  'player1.score': score,
  'player1.streak': streak,
});
```
Each device listens to `snapshots()` on the match document, updating the opponent's progress bar and score counter in real time with sub-100ms latency.

---

## 🔥 Firebase Integration

| Firebase Service | Implementation Details |
| :--- | :--- |
| **Firebase Core** | Initialized in `main.dart` via `FirebaseConfig.initialize()`. Contains graceful fallback if offline. |
| **Firebase Authentication** | Supports **Email/Password**, **Anonymous Guest Login**, and Password Reset. Session tokens are cached via `SharedPreferences`. |
| **Cloud Firestore** | Houses the `matches` collection used for real-time room discovery, player pairing, and live score sync. |
| **Region** | Recommended: `asia-south1 (Mumbai)` for lowest latency in South Asia. |
| **Firestore Security Rules** | Supports standard test mode during development, allowing reads and writes to `/matches/{matchId}`. |

---

## 🛠️ Technology Stack

### Framework & Language
- **Flutter SDK**: `^3.13.2` (Targeting modern Flutter 3.x)
- **Dart SDK**: `^3.x`

### Dependencies (`pubspec.yaml`)
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8       # iOS-style iconography
  google_fonts: ^8.2.1          # Poppins font family
  provider: ^6.1.5+1            # Reactive state management
  shared_preferences: ^2.5.6    # Local persistence & session caching
  uuid: ^4.6.0                  # Unique identifier generation
  firebase_core: ^4.15.0        # Core Firebase SDK
  firebase_auth: ^6.7.0         # Firebase Authentication
  cloud_firestore: ^6.10.0      # Real-time Cloud Firestore database

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0         # Official Flutter lint standards
```

### Build & Platform Tools
- **Gradle**: 9.x with Kotlin DSL (`settings.gradle.kts`, `app/build.gradle.kts`)
- **Google Services Plugin**: `com.google.gms.google-services:4.4.2`
- **Android Target**: Android 11+ (API 30+), portrait orientation locked.

---

## 🏗️ Project Architecture

Think Rush follows a strict **Layered Clean Architecture** pattern:

```
lib/
├── core/         # Cross-cutting constants, dark neon theme, audio/haptics, routing
├── models/       # Pure immutable Dart data classes & JSON serialization
├── providers/    # ChangeNotifier state containers (Business Logic Layer)
├── services/     # Pure services (AI engine, Auth, Generators, Firestore, Timers)
├── widgets/      # Modular, reusable presentation widgets (Buttons, Toasts, Badges)
├── screens/      # Feature screens (Auth, Home, Custom Room, Gameplay, Ranks)
└── main.dart     # Application bootstrap, orientation locking, provider setup
```

### Component Interaction Flow
1. **Screens** observe state via `context.watch<T>()` and trigger user intents via `context.read<T>()`.
2. **Providers** (`GameProvider`, `MatchmakingProvider`, `PlayerProvider`, `AuthProvider`, `SettingsProvider`) coordinate game flow and update state.
3. **Services** (`MathRushGenerator`, `MatchmakingService`, `AiOpponentService`, `ScoringService`) perform deterministic computations, audio triggers, and network I/O.
4. **Models** (`UserProfile`, `MatchModel`, `GameQuestion`, `GameResult`) enforce type-safe data transfer.

---

## 📁 Project Structure

```
think_rush/
├── android/
│   ├── app/
│   │   ├── src/main/AndroidManifest.xml     # Portrait orientation lock & permissions
│   │   ├── build.gradle.kts                 # Google services plugin & SDK versions
│   │   └── google-services.json             # Firebase configuration
│   ├── settings.gradle.kts                  # Gradle plugin dependency definitions
│   └── build.gradle.kts
├── assets/
│   ├── icons/                               # Vector assets
│   ├── images/
│   │   └── logo.png                         # Think Rush branding logo
│   └── sounds/                              # Audio resource placeholders
├── lib/
│   ├── core/
│   │   ├── audio/
│   │   │   └── sound_service.dart           # Haptics & audio dispatcher
│   │   ├── constants/
│   │   │   ├── app_colors.dart              # Dark neon palette definition
│   │   │   └── app_constants.dart           # Game timers, scoring multipliers, XP
│   │   └── theme/
│   │       └── app_theme.dart               # Poppins typography & dark ThemeData
│   ├── models/
│   │   ├── game_question.dart               # Challenge options & memory flash items
│   │   ├── game_result.dart                 # Match recap, XP/coin rewards
│   │   ├── game_session.dart                # GameModeType & GamePlayType enums
│   │   ├── leaderboard_entry.dart           # Ranking entry data
│   │   ├── match_model.dart                 # Firestore match & player models
│   │   ├── reward_item.dart                 # Daily calendar & achievements
│   │   └── user_profile.dart                # Player profile, stats, avatars
│   ├── providers/
│   │   ├── auth_provider.dart               # Sign-in, sign-up, guest auth state
│   │   ├── game_provider.dart               # Round loop, scoring, timer, opponent sync
│   │   ├── matchmaking_provider.dart        # Radar queue & custom room orchestration
│   │   ├── player_provider.dart             # Profile stats, XP, avatar unlocks
│   │   └── settings_provider.dart           # Sound, vibration, notification state
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── forgot_password_screen.dart  # Password reset flow
│   │   │   ├── login_screen.dart            # Email/password & instant guest login
│   │   │   └── signup_screen.dart           # Account registration
│   │   ├── custom_room/
│   │   │   └── custom_room_screen.dart      # Private 4-digit room host & join hub
│   │   ├── game/
│   │   │   ├── game_mode_screen.dart        # 5-mode selection view
│   │   │   └── game_play_screen.dart        # Active round UI with option buttons
│   │   ├── home/
│   │   │   └── home_screen.dart             # Battle hub, quick play, ranks, stats
│   │   ├── leaderboard/
│   │   │   └── leaderboard_screen.dart      # Global, Weekly, Friends podium
│   │   ├── matchmaking/
│   │   │   └── matchmaking_screen.dart      # Radar scanning animation
│   │   ├── profile/
│   │   │   └── profile_screen.dart          # Avatar picker, win rates, XP level
│   │   ├── results/
│   │   │   └── results_screen.dart          # Victory/defeat summary & rewards
│   │   ├── rewards/
│   │   │   └── rewards_screen.dart          # 7-day login calendar & 5 achievements
│   │   ├── settings/
│   │   │   └── settings_screen.dart         # Preferences & logout
│   │   └── splash/
│   │       └── splash_screen.dart           # Animated splash & auth routing
│   ├── services/
│   │   ├── ai/
│   │   │   └── ai_opponent_service.dart     # Easy, Medium, Hard bot simulation
│   │   ├── auth/
│   │   │   └── auth_service.dart            # Firebase Auth & local engine
│   │   ├── firebase/
│   │   │   └── firebase_config.dart         # Safe Firebase initialization
│   │   ├── game/
│   │   │   ├── game_generator.dart          # Generator contract
│   │   │   ├── game_timer_service.dart      # 60s countdown & -3s penalties
│   │   │   ├── logic_grid_generator.dart    # Logic puzzle procedural generator
│   │   │   ├── math_rush_generator.dart     # Arithmetic generator (whole division)
│   │   │   ├── memory_flash_generator.dart  # Visual symbol generator
│   │   │   ├── pattern_finder_generator.dart# Sequence deduction generator
│   │   │   ├── scoring_service.dart         # Scoring formulas & speed bonuses
│   │   │   └── word_rush_generator.dart     # Anagram procedural generator
│   │   ├── leaderboard/
│   │   │   └── leaderboard_service.dart     # Ranking calculation service
│   │   ├── matchmaking/
│   │   │   └── matchmaking_service.dart     # Firestore match queries & room streams
│   │   ├── player/
│   │   │   └── player_service.dart          # Profile storage service
│   │   ├── rewards/
│   │   │   └── rewards_service.dart         # Daily login & achievements service
│   │   └── settings/
│   │       └── settings_service.dart        # App preferences persistence
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── app_header.dart              # Universal top bar with coins & avatar
│   │   │   └── stat_card.dart               # Reusable profile stat box
│   │   ├── dialogs/
│   │   │   └── ai_difficulty_dialog.dart    # Easy/Medium/Hard selection modal
│   │   └── game/
│   │       ├── option_button.dart           # Interactive answer button
│   │       ├── penalty_toast.dart           # Floating "-3 SEC" feedback
│   │       ├── streak_badge.dart            # Glowing multiplier badge
│   │       └── timer_bar.dart               # Smooth decreasing countdown bar
│   └── main.dart                            # Application root
├── test/
│   ├── unit/
│   │   ├── ai_opponent_service_test.dart    # Bot timing & accuracy tests
│   │   ├── game_timer_service_test.dart     # Timer & penalty clamp tests
│   │   ├── leaderboard_service_test.dart    # Ranking sort order tests
│   │   ├── logic_grid_generator_test.dart   # Deduction option tests
│   │   ├── math_rush_generator_test.dart    # Math levels & whole division tests
│   │   ├── memory_flash_generator_test.dart # Symbol scaling tests (3-8 symbols)
│   │   ├── pattern_finder_generator_test.dart# Arithmetic & geometric tests
│   │   ├── scoring_service_test.dart        # Base, speed, streak & floor tests
│   │   ├── user_profile_test.dart           # Serialization & default coin tests
│   │   └── word_rush_generator_test.dart    # Word puzzle tests
│   └── widget_test.dart                     # App smoke test
├── pubspec.yaml                             # Package specifications & assets
└── README.md                                # Comprehensive documentation
```

---

## 🎨 UI/UX Design System

Think Rush utilizes an original dark competitive aesthetic with soft neon accents, subtle glows, and high-contrast typography.

```
+-------------------------------------------------------------------------+
|                         THINK RUSH COLOR PALETTE                        |
+-------------------+--------------------+--------------------------------+
| Primary Background| Surface (Card)     | Secondary Surface (Borders)    |
| #0B0B1A           | #1F1E2E            | #29273D / #343149              |
+-------------------+--------------------+--------------------------------+
| Accent Purple     | Neon Cyan          | Success Green                  |
| #6C5CE7           | #00D4FF            | #00C853                        |
+-------------------+--------------------+--------------------------------+
| Warning Yellow    | Penalty Red        | Secondary Text                 |
| #FFB703           | #FF6B6B            | #B8B6C9                        |
+-------------------+--------------------+--------------------------------+
```

- **Typography**: Clean, rounded typography powered by **Google Fonts (`Poppins`)**.
- **Cards & Borders**: 16px–20px rounded corners with subtle borders (`#343149`) and elevated dark surfaces.
- **Haptic Feedback**: Mapped via `SoundService` for light impacts on button presses, selection clicks on timer ticks, and heavy impacts on penalties or victories.
- **Micro-Animations**: Pulsing radar rings on matchmaking, scale transitions on room codes, and animated countdown timers.

---

## 💻 Installation & Setup

### Prerequisites
- **Flutter SDK**: `3.13.2` or higher (Verify with `flutter --version`).
- **Dart SDK**: `3.x` (Bundled with Flutter).
- **Android Studio / VS Code**: With Flutter and Dart plugins installed.
- **Android SDK**: Platform 34+, Build-Tools 34+.
- **Physical Android Phone or Emulator**: USB Debugging enabled.

### Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/think_rush.git
   cd think_rush
   ```

2. **Verify Flutter environment**:
   ```bash
   flutter doctor
   ```

3. **Install project dependencies**:
   ```bash
   flutter pub get
   ```

4. **Verify connected devices**:
   ```bash
   flutter devices
   ```

5. **Run the application**:
   ```bash
   flutter run
   ```

---

## ⚙️ Firebase Setup (For Live 2-Device Multiplayer)

The application includes an offline fallback engine that runs immediately out of the box. To activate **live cross-network 2-device multiplayer**:

1. **Create a Firebase Project**:
   - Navigate to [Firebase Console](https://console.firebase.google.com).
   - Create a project named `Think Rush` (or use your preferred ID).

2. **Register Android Application**:
   - Package Name: `com.example.think_rush`
   - Download the generated `google-services.json`.
   - Place the file at:
     ```
     think_rush/android/app/google-services.json
     ```

3. **Enable Firebase Authentication**:
   - In Firebase Console, navigate to **Build > Authentication > Sign-in method**.
   - Enable **Email/Password**.
   - Enable **Anonymous** *(enables instant Guest play)*.

4. **Create Cloud Firestore Database**:
   - In Firebase Console, navigate to **Build > Firestore Database > Create database**.
   - Location: Select `asia-south1 (Mumbai)` (or your nearest regional location).
   - Security Rules: Select **Start in test mode** for development:
     ```javascript
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         match /{document=**} {
           allow read, write: if true;
         }
       }
     }
     ```

---

## 🧪 Testing & Quality Assurance

Think Rush contains an extensive automated test suite covering game generators, scoring, timer penalties, difficulty scaling, model serialization, and bot simulation.

### Running Code Analysis
```bash
flutter analyze
```
*Expected Result: `No issues found!` (0 errors, 0 warnings, 0 lints).*

### Running Automated Test Suite
```bash
flutter test
```
*Expected Result: `17/17 tests passed`.*

### Test Suite Summary
| Test File | Target | Coverage Highlights |
| :--- | :--- | :--- |
| `ai_opponent_service_test.dart` | `AiOpponentService` | Verifies bot name pools, async thinking simulation, and score state. |
| `game_timer_service_test.dart` | `GameTimerService` | Validates 60s countdown, -3s wrong-answer deduction, and zero clamp. |
| `leaderboard_service_test.dart` | `LeaderboardService` | Verifies sorting by score, win counts, and current user inclusion. |
| `logic_grid_generator_test.dart` | `LogicGridGenerator` | Tests procedural logic deductions, 4 distinct options, valid index. |
| `math_rush_generator_test.dart` | `MathRushGenerator` | Tests operations across Levels 1–6 and verifies integer division rules. |
| `memory_flash_generator_test.dart` | `MemoryFlashGenerator` | Verifies symbol scaling from 3 to 8 symbols across Levels 1–6. |
| `pattern_finder_generator_test.dart` | `PatternFinderGenerator` | Tests arithmetic, geometric, alternating, and Fibonacci sequences. |
| `scoring_service_test.dart` | `ScoringService` | Tests 100 base score, speed bonus, streak multiplier, and zero floor. |
| `user_profile_test.dart` | `UserProfile` | Verifies initial 500 coins, Level 1 stats, and JSON serialization. |
| `word_rush_generator_test.dart` | `WordRushGenerator` | Validates procedural word anagrams, 4 options, and correct answers. |
| `widget_test.dart` | `ThinkRushApp` | App smoke test verifying startup and root widget hierarchy. |

---

## 📦 Building the Android APK

To assemble a standalone Android APK:

### 1. Build Debug APK (For immediate device sideloading & testing)
```bash
flutter build apk --debug
```
*Output location:*
```
think_rush/build/app/outputs/flutter-apk/app-debug.apk
```

### 2. Build Release APK (Optimized for production)
```bash
flutter build apk --release
```
*Output location:*
```
think_rush/build/app/outputs/flutter-apk/app-release.apk
```

### 3. Sideload onto Android Phone via ADB
```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

---

## 🗺️ Development Roadmap

### ✅ Completed
- [x] Vertical/Portrait orientation locked across Android native manifest and Flutter engine.
- [x] All 5 cognitive game generators (Math Rush, Pattern Finder, Memory Flash, Logic Grid, Word Rush).
- [x] Adaptive difficulty engine (Levels 1 to 6) with streak promotion and 2-error demotion.
- [x] Scoring engine with speed bonus, streak multiplier, and -3s penalty toasts.
- [x] Non-negative score protection.
- [x] AI opponent simulation across Easy, Medium, and Hard tiers.
- [x] Dual-engine Authentication (Firebase Email/Password + Anonymous Guest + offline fallback).
- [x] Global Radar Matchmaking with queue timeout fallback.
- [x] Dedicated Custom Room 2-device multiplayer with 4-digit PINs, zero bots, and zero timeouts.
- [x] Deterministic random seed synchronization for identical question sequences.
- [x] Real-time live score and streak streaming via Cloud Firestore.
- [x] Metagame systems: Leaderboards (podium), 7-Day Login Rewards, 5 Achievements, and 6 Profile Avatars.
- [x] Settings screen with audio, music, and vibration haptic controls.
- [x] 17/17 automated unit and widget test cases passing with zero lint warnings.

### 🔄 In Progress
- [ ] Sound audio clip assets integration (currently utilizing native Android haptic feedback vibration patterns).
- [ ] Push notifications for daily streak reminders.

### 📋 Planned (Future Enhancements)
- [ ] Ranked Seasons & Elo matchmaking rating (MMR) tiers (Bronze, Silver, Gold, Diamond, Master).
- [ ] Tournament Bracket Mode (8-player knockout cup).
- [ ] Bluetooth LE / Local Wi-Fi Direct matchmaking for offline zero-data multiplayer battles.
- [ ] Audio sound pack customization in the store.

---

## ⚠️ Known Limitations

1. **Audio Clips**: Audio sound toggles trigger native Android haptic vibration feedback patterns; custom `.mp3`/`.wav` sound files can be placed into `assets/sounds/` for audible sound effects.
2. **Network Dependency for Custom Rooms**: Cross-device custom room multiplayer requires an active internet connection to communicate with Cloud Firestore.
3. **Android Platform Primary**: The application is tested and optimized specifically for Android devices in portrait mode. iOS build configurations require standard Apple Developer provisioning.

---

## 🎓 Academic Project Information

- **Project Title**: *Think Rush: A Real-Time Multiplayer Competitive Brain Battle Game*
- **Degree**: Master of Computer Applications (MCA)
- **Student Name**: Akaash Ravi Bhandary
- **University Seat Number (USN)**: `4JK25MC005`
- **Institution**: A.J. Institute of Engineering and Technology (AJIET), Mangaluru
- **Department**: Department of Master of Computer Applications
- **Project Mentor / Guide**: Mrs. Amitha Roshan Vakil

---

## 📄 License

This project is developed as an academic MCA project. Released under the [MIT License](LICENSE).
