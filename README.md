# RoadMapped

A learning roadmap tracking application built with Flutter and Firebase.

## Features

- 📱 Cross-platform support (iOS, Android, Web)
- 🔐 User authentication with Firebase
- 📊 Create and track learning roadmaps with progress monitoring
- 🌐 Share roadmaps with the community
- 📈 Real-time progress tracking and visualization
- 🎨 Customizable view layouts (Grid/List)
- 📚 Resource management for steps (Add, view, and manage resources)

## Architecture

The project follows a repository pattern with the following structure:
- `models/`: Data models for roadmaps, progress, and resources
- `repositories/`: Firebase interactions and data management
- `screens/`: UI screens and business logic
- `widgets/`: Reusable UI components
- `services/`: Core services like authentication

## Project Progress (70% Complete)

### Core Features
- [x] User Authentication
- [x] Basic Roadmap CRUD
- [x] Progress Tracking
- [x] Step Management
- [x] Public/Private Roadmaps
- [x] Responsive Layout
- [x] Progress Visualization
- [x] Resource Management
- [x] Search & Filter
- [ ] Social Features

### UI/UX
- [x] Material Design Implementation
- [x] Grid/List View Toggle
- [x] Progress Indicators
- [x] Loading States
- [x] Error Handling
- [x] Dark Mode
- [ ] Animations
- [ ] Offline Support

### Technical
- [x] Firebase Integration
- [x] State Management
- [x] Stream-based Updates
- [x] Data Models
- [ ] Caching
- [ ] Testing
- [ ] CI/CD
- [ ] Performance Optimization

### Documentation
- [x] Basic README
- [x] Installation Guide
- [ ] Code Documentation
- [ ] User Guide
- [ ] API Documentation

## Getting Started

### Prerequisites
- Flutter SDK (3.5.2 or higher)
- Firebase project setup
- Git

### Installation
1. Clone the repository
2. Run `flutter pub get`
3. Configure Firebase (add google-services.json/GoogleService-Info.plist)
4. Create .env file with required keys
5. Run `flutter run`

## Contributing

Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details
