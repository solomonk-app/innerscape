# 🌙 Feelong — AI Mood Journal

A beautiful, AI-powered mood journal built with Flutter for iOS & Android.

## ✨ Features

- **Daily Mood Check-Ins** — Track your mood with 6 emoji-based levels
- **Freeform Journaling** — Write what's on your mind with rotating daily prompts
- **AI-Powered Reflections** — Each entry receives a personalized insight from Claude AI
- **🔔 Push Notification Reminders** — Gentle daily nudges with customizable time & quick presets
- **Mood Trend Chart** — Visualize your emotional patterns over the last 14 entries
- **Insights Dashboard** — Average mood, streak tracking, mood distribution
- **Wellness Tips** — Tailored suggestions based on your current mood
- **Persistent Storage** — All entries saved locally on device
- **Warm Earthy UI** — Dark theme with organic, calming design language

## 📱 Screenshots

The app features three main views:
1. **Check In** — Select mood, write journal entry, get AI insight
2. **History** — Mood trend chart + scrollable list of past entries
3. **Insights** — Stats grid, mood distribution, streak info

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.2.0+)
- Dart SDK (3.2.0+)
- Xcode (for iOS)
- Android Studio (for Android)

### Setup

1. **Clone or copy the project files** into a new Flutter project:
   ```bash
   flutter create feelong
   ```
   Then replace the `lib/` folder and `pubspec.yaml` with the files provided.

2. **Install dependencies:**
   ```bash
   cd feelong
   flutter pub get
   ```

3. **Configure your Anthropic API key:**
   Open `lib/services/ai_service.dart` and replace `YOUR_ANTHROPIC_API_KEY` with your actual key.

   ⚠️ **Security Note:** For production, use a backend proxy to keep your API key secure. Never ship API keys in client apps. Consider using:
   - A simple backend API (Firebase Functions, Supabase Edge Functions, etc.)
   - Environment variables via `--dart-define`

4. **Run the app:**
   ```bash
   # iOS
   flutter run -d ios

   # Android
   flutter run -d android
   ```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point & home screen
├── models/
│   └── mood_entry.dart          # MoodEntry model & MoodOption config
├── screens/
│   ├── checkin_screen.dart      # Mood selection & journal entry
│   ├── result_screen.dart       # Post-checkin AI insight display
│   ├── history_screen.dart      # Mood chart & entry timeline
│   ├── insights_screen.dart     # Stats, distribution & analytics
│   └── reminder_settings_screen.dart  # Push notification settings
├── services/
│   ├── ai_service.dart          # Anthropic Claude API integration
│   ├── notification_service.dart # Local push notification scheduling
│   └── storage_service.dart     # SharedPreferences persistence
├── theme/
│   └── app_theme.dart           # Colors, typography, theme data
└── widgets/
    └── glass_card.dart          # Reusable styled card component
```

> 📌 **Important:** See `NOTIFICATION_SETUP.md` for platform-specific notification configuration (Android manifest, iOS AppDelegate, permissions).

## 🎨 Design

The app uses a warm, earthy dark theme:
- **Background:** Deep charcoal browns (#1A1512)
- **Accent:** Burnt orange (#E8945A)
- **Typography:** Lora (Google Fonts) — elegant serif
- **Cards:** Glass-morphism style with subtle borders
- **Animations:** Smooth fade-in/slide-up transitions

## 🔧 Dependencies

| Package | Purpose |
|---------|---------|
| `shared_preferences` | Local data persistence |
| `http` | Anthropic API calls |
| `fl_chart` | Mood trend line chart |
| `google_fonts` | Lora typography |
| `animate_do` | Entry animations |
| `uuid` | Unique entry IDs |
| `intl` | Date formatting |
| `flutter_local_notifications` | Push notification reminders |
| `timezone` | Timezone-aware scheduling |

## 🛡️ Privacy

All journal data is stored **locally on the device** using SharedPreferences. The only network call is to the Anthropic API for generating AI reflections. No data is shared with third parties.

## 📄 License

MIT — feel free to customize and ship! 🚀
