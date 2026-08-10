# Privacy

Bing 4All is designed to keep data on your machine.

## What the app does

- Fetches public Bing wallpaper metadata/images over HTTPS
- Stores settings, cache, and logs locally under the application support directory
- Optionally writes a desktop autostart entry when you enable “start with system”

## What the app does not do

- No accounts
- No advertising
- No analytics / telemetry by default
- No browser homepage/search changes
- No sale of personal data

## Data stored locally

Typical local files include:
- `config.json` — preferences
- `state.json` — last applied wallpaper / update status
- cached images and metadata
- local logs (without intentional personal data)

You can delete the application data directory to wipe local state.

## Third parties

Image requests go to Bing/Microsoft endpoints. Their privacy policies apply to those network requests. This project is unofficial and unaffiliated with Microsoft.
