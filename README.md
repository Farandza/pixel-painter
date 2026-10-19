# Pixel Painter 🎨

An offline Flutter drawing app with freehand brush, spray paint, eraser, fill,
lines, rectangles, ellipses, triangles, undo history, local saving, and an
editable gallery.

## Run locally

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) and
   an Android device/emulator or iOS Simulator.
2. From this folder run `flutter pub get` and then `flutter run`.
3. Draw on the white canvas. Choose a tool from the bottom panel, select a
   colour or size, then drag on the canvas. Use Save to create a PNG, or Gallery
   to reopen it and continue drawing.

## Reviewer guide

The release APK is roughly 45 MB. If it is not attached to the repository
release because of the host's binary-file limit, rebuild it with `flutter build
apk --release`; the generated file is
`build/app/outputs/flutter-apk/app-release.apk`.

- **Android device:** copy the APK to the device, permit installs from the file
  manager when prompted, then tap it to install.
- **NoxPlayer / BlueStacks:** drag the APK into the emulator window (or use its
  APK install button) and open **Pixel Painter**.
- **Appetize.io:** upload `PixelPainter-release.apk` (or the generated
  `app-release.apk`), wait for processing, then use the touch canvas in the
  browser preview.

Saved drawings are private PNGs in the application documents directory; the
in-app Gallery lists them newest first. Opening a card imports it as the base
layer. Save updates that file; **Save copy** creates a new one.
