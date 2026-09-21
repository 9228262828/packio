PACKIO — Packing List & Trip Organizer
Tagline: Pack smart. Travel ready.
Package: com.packio.tripplanner

Add to pubspec.yaml:

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.3.2

Included:
- Splash Screen
- Travel-journal Home Screen
- Trip creation and editing
- Destination and trip dates
- Trip notes
- Packing lists
- Categories
- Quantity
- Essential item flag
- Packed / unpacked state
- Packing progress
- Ready-made templates
- Duplicate previous trip
- Search trips and destinations
- Trip history
- Statistics
- Dark Mode
- Privacy Policy
- Terms & Conditions
- Reset data
- Offline SharedPreferences persistence

UI:
- Warm Ivory background
- Forest Green primary
- Terracotta Orange secondary
- Sand Gold accent
- Travel journal / ticket visual style

No Firebase
No backend
No login
No ads
No analytics
No network API
No image assets required

Stability notes:
- TextEditingControllers are owned and disposed by TripEditorScreen.
- Packing-item dialog uses state values rather than disposable local controllers.
- JSON decoding is guarded.
- SharedPreferences persistence is explicit.
- Local relative imports were statically checked.
