# Event Planner (Campus Sports & Events Planner)

Flutter app that fetches events from an API (`http` package), shows them with
`ListView.builder`, and supports Join toggle and Delete.

## Setup
This zip contains the Dart source only. Generate the platform folders first:

```bash
cd event_planner
flutter create .        # adds android/, ios/, web/, etc. (keeps lib/ and pubspec.yaml)
flutter pub get
flutter run -d chrome
```

Android only: make sure `android/app/src/main/AndroidManifest.xml` has
`<uses-permission android:name="android.permission.INTERNET" />`

## Structure
- `lib/models/event.dart`           Event model (eventTitle, date, venue, organizer, image, description, isJoined) + `fromJson`
- `lib/services/event_service.dart` `fetchEvents()` (GET) and `deleteEvent()` (DELETE)
- `lib/widgets/event_card.dart`     Card UI with Join and Delete
- `lib/screens/home_screen.dart`    FutureBuilder + ListView.builder
- `lib/main.dart`                   App entry

## Push to GitHub
```bash
git init
git add .
git commit -m "Event Planner: fetch events from API with ListView.builder"
git branch -M main
git remote add origin <your-repo-url>
git push -u origin main
```


## Custom Event List

The app now includes a **Custom Event List**.

### How to use it
1. Run the Flutter app.
2. Tap **Custom Event** at the bottom-right.
3. Enter the event title, date, venue, organizer, and description.
4. Tap **Add Event**.
5. The event appears under **Custom Event List**.
6. Custom events can also be joined or deleted.

Custom events are stored locally in memory, so they remain visible while the app is running. They are not saved to the API or permanent device storage.
