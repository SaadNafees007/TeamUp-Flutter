# TeamUp — Offline-First Student Collaboration & Networking Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.44+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State_Management-Riverpod-00599C)](https://riverpod.dev)
[![Local Storage](https://img.shields.io/badge/Persistence-Hive_Storage-FFA000)](https://docs.hivedb.dev)
[![Navigation](https://img.shields.io/badge/Routing-GoRouter-42A5F5)](https://pub.dev/packages/go_router)
[![License](https://img.shields.io/badge/Competition-VisioSpark_FA26-4F46E5)](#)

> Developed for the **VisioSpark FA26 Intra-Campus Mobile App Competition**, Department of Computer Science, **COMSATS University Islamabad, Wah Campus**.

---

## 📌 Problem Statement

Students commonly form project teams based on friendships or physical proximity rather than technical compatibility. This results in skill gaps, uneven workload distribution, missing expertise, delays, and poor project outcomes.

**TeamUp** solves this by offering an offline-first mobile platform where students discover and connect with technically compatible teammates using a transparent, deterministic matching algorithm based on skills, shared research interests, project scope, availability, and academic semester.

---

## 🚀 Key Features

### 1. 🎯 Smart Match Engine (Highest Weight)
- **Deterministic 4-Part Scoring Formula**:
  $$\text{Match Score } S = (0.40 \times \text{Skills}) + (0.25 \times \text{Interests}) + (0.20 \times \text{Project Scope}) + (0.15 \times \text{Availability \& Semester})$$
  Bounded as an integer strictly between 0 and 100.
- **Skills Score (40%)**: Evaluates candidate skills against the open required roles of the user's project team.
- **Shared Interests (25%)**: Mathematically computed using the **Jaccard Similarity Index** ($\frac{|A \cap B|}{|A \cup B|} \times 100$).
- **Project Scope (20%)**: 100% for compatible scopes (*Both* matches either *Semester Project* or *FYP*); 0% for conflicts.
- **Availability & Semester (15%)**: Schedule compatibility plus linear semester proximity decay.
- **Explainable Reasons & Transparency**: Generates human-readable match factors and includes a full formula breakdown modal with point contributions ($85 \times 0.40 = 34.0\text{ pts}$, etc.).
- **Team Skill Gap Analysis**: Dynamically compares required role skills with active roster skills, identifying missing skills and highlighting candidates who bridge critical skill gaps.

### 2. 🔍 Discover & Multi-Criteria Filtering
- **Pre-Seeded Realistic Dataset**: 16 complete student profiles across diverse departments (SE, CS, AI, Cyber Security, Data Science, EE), semesters (1–8), and technical skillsets.
- **Real-Time Live Search**: Case-insensitive instant filtering by student name and technical skills.
- **Multi-Criteria Filtering**: Filter simultaneously by Department, Semester range, Skills, and Project Type with active filter badges.
- **Dynamic Sorting**: Reorder candidates by *Match Score: Highest First*, *Semester: Senior First*, or *Alphabetical Name*.
- **Saved Filter Presets**: Save, view, apply with one tap, and delete custom filter configurations (comes with 3 pre-seeded presets).

### 3. ✉️ Team Invitations & Requests Hub
- **Custom Invitations**: Send custom invitation messages with inline validation and 72-hour expiration tracking.
- **Two-Tab Interface**: Separate *Received* and *Sent* tabs.
- **Interactive Actions**: Accept/Reject received requests; Cancel sent requests with safety confirmation dialogs.
- **Dynamic Notification Badge**: Bottom navigation bar displays a live badge of pending incoming requests (starts at 3 and decrements automatically).
- **Status Badges**: Color-coded badges for *Pending* (Amber), *Accepted* (Green), *Rejected* (Red), *Cancelled* (Grey), and *Expired*.

### 4. 👥 My Team & Automatic Roster Synchronization
- **Team Configuration**: Project Title, Scope, Description, and required role management.
- **Automatic Roster Synchronization**: Accepting a received invitation automatically adds the candidate to the roster, assigns them to the best-matching open role, decrements open role slots, and recalculates team skill coverage.
- **Interactive Team Task Checklist**: Create, toggle completion, and delete milestone tasks with visual progress tracking.
- **Simulated Local Chat**: Offline-first team discussion channel with timestamps, sender tags, and simulated peer interactions.

### 5. 👤 Profile & Completeness Meter
- **Complete Academic Profile**: Name, Department, Semester (1–8), Skills, Interests, Project Type, Availability, and Bio.
- **Profile Completeness Meter**: Weighted indicator (0–100%) providing friendly, actionable tips to complete profile fields.
- **Avatar Selection**: 6 stylish preset designer avatars plus device gallery image picker with graceful fallbacks.
- **Demo Reset Button**: One-tap reset to initial competition seed state for judging evaluation.

---

## 🛠️ Technology Stack & Architecture

- **Language & Framework**: Dart 3.12+ & Flutter 3.44+
- **Design System**: Material 3 with custom palette:
  - Primary Indigo: `#4F46E5`
  - Secondary Slate: `#64748B`
  - Background: `#F8FAFC`
  - Accent Emerald: `#10B981`
- **State Management**: [Riverpod](https://riverpod.dev)
- **Local Persistence**: [Hive](https://docs.hivedb.dev) (100% offline-first, surviving app restarts and process kills)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) with stateful indexed branches

### Project Structure

```
lib/
├── app/                  # GoRouter configuration & Navigation Shell with dynamic badge
├── core/
│   ├── constants/        # App colors, departments, suggested skills & presets
│   ├── theme/            # Material 3 light theme definition
│   └── widgets/          # Reusable Avatar, StatusBadge, SkillChip, EmptyState
├── data/
│   ├── local_storage/    # Hive storage service & seed initialization
│   ├── models/           # StudentProfile, Team, TeamRole, TeamRequest, TeamTask, ChatMessage
│   └── seed/             # 16 student profiles, 5 requests, 4 tasks, 3 presets
└── features/
    ├── chat/             # Simulated local team chat
    ├── discover/         # Search, multi-criteria filtering, sorting, student cards
    ├── matching/         # Deterministic Smart Match Engine & score transparency modal
    ├── profile/          # Profile view, edit form, completeness meter & avatar picker
    ├── requests/         # Received & Sent invitations hub with dynamic badge
    ├── tasks/            # Milestone task checklist
    └── team/             # Team configuration, roster, open roles & skill gap analysis
```

---

## 🧪 Testing & Code Quality

### Unit Tests
The Smart Match Engine is verified with unit tests covering all edge cases:
- ✅ Perfect skills match on open role (100%)
- ✅ No matching skills (0%)
- ✅ Jaccard similarity index on shared interests
- ✅ No shared interests (0%)
- ✅ Project type match (100%) vs mismatch (0%)
- ✅ Availability compatibility and semester decay
- ✅ Strict score boundary clamping (0–100)
- ✅ Empty collection safety
- ✅ Skill gap detection and candidate bridging
- ✅ Deterministic repeatability across executions

To run tests:
```bash
flutter test
```

### Static Analysis
```bash
flutter analyze
```
> **Result**: `No issues found!` (0 errors, 0 warnings, 0 lints).

---

## 💻 Getting Started

### Prerequisites
- Flutter SDK 3.44+ installed
- Dart SDK 3.12+

### Installation & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/SaadNafees007/TeamUp-Flutter.git
   cd TeamUp-Flutter
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   # On Windows Desktop
   flutter run -d windows

   # On Chrome Web
   flutter run -d chrome
   ```

---

## 🏆 VisioSpark FA26 Evaluation Flow (2-Minute Demo)

1. **Profile (0:00 - 0:20)**: Open Profile tab $\rightarrow$ review Profile Completeness Meter ($100\%$) $\rightarrow$ tap *Edit Profile* to adjust fields $\rightarrow$ test Avatar picker.
2. **Discover (0:20 - 0:45)**: Type `Flutter` in the search bar $\rightarrow$ open Filters modal $\rightarrow$ apply saved preset *"7th Semester Mobile Developers"* $\rightarrow$ inspect filtered candidates.
3. **Smart Matches (0:45 - 1:15)**: Open Best Matches tab $\rightarrow$ view candidates ranked in strict descending score order $\rightarrow$ tap *"Score Breakdown"* on top candidate (*Ayesha Noor*) $\rightarrow$ review the mathematical contribution and skill gap tag $\rightarrow$ send custom invitation.
4. **Requests (1:15 - 1:40)**: Open Requests tab (notice dynamic badge *"3"*) $\rightarrow$ review Received requests $\rightarrow$ tap *"Accept & Add"* on Ayesha Noor's invitation $\rightarrow$ badge decrements to *"2"*.
5. **My Team (1:40 - 2:00)**: Open My Team tab $\rightarrow$ see Ayesha Noor automatically placed in the *"Machine Learning & AI Engineer"* role $\rightarrow$ observe Skill Gap Analysis update $\rightarrow$ open Tasks and Local Chat to demonstrate persistent collaboration.
