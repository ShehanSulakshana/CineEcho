
# CineEcho

A Flutter mobile application for movie and TV show discovery, watchlist tracking, and community sharing. Powered by TMDB API.

## Features

- Browse trending movies and TV shows with detailed metadata
- Manage personal watchlists with total watch time tracking
- View movie/TV details including cast, synopsis, and trailers
- Share reviews and recommendations via in-app posts feed
- User profiles with viewing statistics
- Dark mode support

## Quick Setup

```bash
git clone https://github.com/yourusername/cineecho.git
cd cineecho
flutter pub get
# Configure .env with TMDB API key and Firebase credentials
flutter run
```

## Architecture
```
lib/
├── core/          # App-wide utilities, themes, constants
├── features/      # Domain-specific modules (movies, watchlist, posts)
├── shared/        # Reusable widgets, models, services
└── app.dart       # Root app widget
```


### Contributing

- Fork the repository, create a feature branch, and submit a pull request.

### License
- MIT License


#### © 2026 CineEcho. Built with Flutter.

>>>>>>> b5d27db1ea1f4f4bc3083a246f2c90faea4d5996
