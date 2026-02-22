# 🚚 CeylonDash Mobile

A high-accessibility logistics platform optimized for the Sri Lankan market.

## 🏗 Architecture: Clean Architecture + BLoC
We follow a strict separation of layers to ensure testability and scalability:

1. **Domain Layer (Inner Circle):** Pure Dart. Contains Entities, Use Cases, and Repository Interfaces. **No dependencies on Flutter.**
2. **Data Layer:** Repository implementations and Data Sources (API/Local DB). Handles JSON serialization.
3. **Presentation Layer:** Flutter widgets and BLoC state management.

## 🎨 Accessibility Principles
- **Minimal Text:** Rely on icons and colors for status.
- **High Contrast:** Optimized for outdoor usage (delivery riders).
- **Haptic Feedback:** Vibration confirmation for all critical security actions (QR generation).

## 🛠 Tech Stack
- **State Management:** Flutter BLoC
- **Navigation:** GoRouter (planned)
- **Networking:** Dio
- **Dependency Injection:** GetIt