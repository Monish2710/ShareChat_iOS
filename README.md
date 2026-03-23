# ShareChat_iOS

A two-screen iOS video discovery and playback app built with SwiftUI.

The app shows a paginated 3-column video grid on the home screen and opens a dedicated player screen with autoplay and a "Next Up" queue for videos from the current page.

## Features

- Popular video discovery from `https://api.pexels.com/videos/popular`
- 3-column responsive video grid
- Video duration and videographer metadata on each card
- Navigation from grid item to player screen
- Native video playback using `AVKit`
- "Next Up" list for videos from the current loaded page
- Autoplay to the next video when playback finishes
- Infinite scroll / load more pagination
- Loading state and error state handling

## Architecture

The project is organized using a Clean Architecture style MVVM structure.

### Layers

- `Presentation`
  - SwiftUI screens and view models
- `Domain`
  - Entities, repository abstractions, and use cases
- `Data`
  - Remote data source and repository implementation
- `Support`
  - Dependency wiring via `AppContainer`

### Flow

1. `ContentView` creates the app dependencies through `AppContainer`
2. `HomeViewModel` calls `GetPopularVideosUseCase`
3. The use case talks to `VideoRepository`
4. `PexelsVideoRepository` delegates to `DefaultPexelsRemoteDataSource`
5. The response is mapped into UI state and rendered by SwiftUI screens

## Project Structure

```text
Share/
├── ContentView.swift
├── ShareApp.swift
├── Data/
│   ├── Repositories/
│   └── Services/
├── Domain/
│   ├── Entities/
│   ├── Repositories/
│   └── UseCases/
├── Presentation/
│   ├── Home/
│   └── Player/
└── Support/
```

## Main Screens

### Home Screen

- Displays videos in a fixed 3-column grid
- Shows thumbnail, duration, and videographer
- Loads more items as the user scrolls

### Player Screen

- Plays the selected video
- Shows a "Next Up" list from the current page
- Automatically advances to the next video after completion

## Tech Stack

- Swift
- SwiftUI
- AVKit
- MVVM
- Clean Architecture style layering

## Setup

1. Open `Share.xcodeproj` in Xcode
2. Select an iPhone simulator or device
3. Build and run the app

## Notes

- The app currently calls the Pexels popular videos endpoint directly.
- If the API rejects unauthenticated requests in your environment, the UI will show the returned error state.
- The player selects the most suitable MP4 from `video_files`, preferring a size close to `720x1280` when available.

## Future Improvements

- Add API key configuration if required by the runtime environment
- Add unit tests for use cases and view models
- Add image caching
- Improve offline and retry behavior
- Add search and filtering
