# Feelong — Codebase Documentation

## Overview

**Feelong** is an AI-powered mood journal mobile app built with **Flutter/Dart**. Users track their emotional well-being through daily check-ins and receive personalized wellness insights powered by Google's Gemini AI.

**Platforms:** iOS & Android | **Lines of Code:** ~2,576 Dart | **License:** MIT

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart 3.2+) |
| AI | Google Gemini 2.0 Flash |
| Storage | SharedPreferences (local only) |
| Charts | fl_chart 0.66.0 |
| Notifications | flutter_local_notifications 17.0.0 |
| Typography | Google Fonts (Lora serif) |
| Animations | animate_do, Lottie |

---

## Architecture

Layered architecture with local state management (`setState`), no global state manager:

```
┌─────────────────────────────────┐
│  Screens (Presentation Layer)   │  5 screens + reusable widgets
├─────────────────────────────────┤
│  Services (Business Logic)      │  AI, Storage, Notifications
├─────────────────────────────────┤
│  Models (Data)                  │  MoodEntry, MoodOption
├─────────────────────────────────┤
│  Theme (Styling)                │  Centralized dark warm palette
└─────────────────────────────────┘
```

---

## Project Structure

```
lib/
├── main.dart                          # Entry point & HomeScreen (3-tab nav)
├── models/
│   └── mood_entry.dart                # MoodEntry & MoodOption data classes
├── screens/
│   ├── checkin_screen.dart            # Mood selection + journal input
│   ├── result_screen.dart             # AI insight display post check-in
│   ├── history_screen.dart            # Line chart + entry timeline
│   ├── insights_screen.dart           # Stats dashboard & mood distribution
│   └── reminder_settings_screen.dart  # Notification scheduling UI
├── services/
│   ├── ai_service.dart                # Gemini API integration + fallbacks
│   ├── storage_service.dart           # SharedPreferences persistence (singleton)
│   └── notification_service.dart      # Daily reminder scheduling (singleton)
├── theme/
│   └── app_theme.dart                 # Color palette, typography, ThemeData
└── widgets/
    └── glass_card.dart                # Reusable glass-morphism card
```

---

## Data Model

**MoodEntry** — represents a single journal entry:

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID string | Unique identifier |
| `mood` | int (1–6) | Mood level: 1=Awful → 6=Amazing |
| `text` | String | Optional journal text |
| `timestamp` | ISO 8601 | Creation time |
| `aiInsight` | String | AI-generated reflection |

**Mood Scale:** 😢 Awful (1) · 😟 Bad (2) · 😐 Meh (3) · 🙂 Good (4) · 😊 Great (5) · 🤩 Amazing (6)

All data is stored locally via SharedPreferences under the key `'mood_entries'` as a JSON array. No cloud storage, no user accounts.

---

## Key Services

### AI Service (`ai_service.dart`)
- Calls Gemini 2.0 Flash with mood + journal text + last 5 entries as context
- System prompt: warm, empathetic wellness companion (2–3 sentence responses)
- Falls back to pre-written insights if API fails
- Also provides mood-specific wellness tips and rotating daily journal prompts

### Storage Service (`storage_service.dart`)
- Singleton with `getInstance()` factory
- CRUD for mood entries + streak calculation (consecutive check-in days, up to 30)

### Notification Service (`notification_service.dart`)
- Timezone-aware daily reminders with randomized message content
- 6 quick presets: Morning, Midday, Lunch, After Work, Evening, Bedtime
- Persists reminder state across app restarts

---

## App Flow

```
main() → Init notifications → FeelongApp → HomeScreen
                                                  │
                              ┌────────────────────┼────────────────────┐
                              ▼                    ▼                    ▼
                         Check In             History              Insights
                         (Tab 0)              (Tab 1)              (Tab 2)
                              │
                    Select mood + write
                              │
                    Save → AI insight
                              │
                         ResultScreen
```

---

## Design System

- **Theme:** Dark warm palette — deep charcoal brown (`#1A1512`) background, burnt orange (`#E8945A`) accent, warm gold (`#D4A574`) secondary
- **Typography:** Lora serif via Google Fonts
- **Components:** Glass-morphism cards (`GlassCard` widget) used throughout
- **Animations:** Staggered fade-in/slide-up transitions on screen elements

---

## Security Notes

| Status | Item |
|--------|------|
| ⚠️ | API key hardcoded in `ai_service.dart` — should use env vars or backend proxy |
| ⚠️ | No encryption at rest for SharedPreferences data |
| ✅ | All data local, no cloud sync |
| ✅ | Only network call is to Gemini API |
| ✅ | Notifications generated locally |

---

## Testing

Currently only a template widget test exists (`test/widget_test.dart`) that doesn't test actual app functionality. Missing: unit tests for services, widget tests for screens, integration tests.

---

## Build & Run

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device
flutter build apk        # Android release build
flutter build ios        # iOS release build
flutter analyze          # Lint check
```
