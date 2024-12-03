# RoadMapped

A learning roadmap tracking application built with Flutter and Firebase.

## Features

- 📱 Cross-platform support (iOS, Android, Web)
- 🔐 User authentication with Firebase
- 📊 Create and track learning roadmaps with progress monitoring
- 🌐 Share roadmaps with the community
- 📈 Real-time progress tracking and visualization
- 🎨 Customizable view layouts (Grid/List)

## Architecture

The project follows a repository pattern with the following structure:
- `models/`: Data models for roadmaps, progress, and resources
- `repositories/`: Firebase interactions and data management
- `screens/`: UI screens and business logic
- `widgets/`: Reusable UI components
- `services/`: Core services like authentication

## Getting Started

### Prerequisites

- Flutter SDK (3.5.2 or higher)
- Firebase CLI
- Git

### Installation

1. Clone the repository

```bash
git clone https://github.com/hussaynzaidi/roadmapped.git
cd roadmapped
```

2. Install dependencies

```bash
flutter pub get
```

## Project Progress (65% Complete)

### Core Features
- [x] User Authentication
- [x] Basic Roadmap CRUD
- [x] Progress Tracking
- [x] Step Management
- [x] Public/Private Roadmaps
- [x] Responsive Layout
- [x] Progress Visualization
- [ ] Resource Management
- [ ] Search & Filter
- [ ] Social Features

### UI/UX
- [x] Material Design Implementation
- [x] Grid/List View Toggle
- [x] Progress Indicators
- [x] Loading States
- [x] Error Handling
- [ ] Dark Mode
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

## AI Development Prompt

Use this prompt for AI-assisted development:

"You are assisting with the RoadMapped project, a Flutter application for creating and tracking learning roadmaps. The project uses Firebase for backend services and follows Material Design principles.

Current tech stack:
- Flutter 3.5.2+
- Firebase (Auth, Firestore, Storage)
- Provider for state management
- Material Design components

Key models:
- Roadmap (title, description, steps, visibility)
- RoadmapStep (title, description, resources)
- RoadmapProgress (user progress tracking)

TODO List:
1. Resource Management
   - Resource model implementation
   - Resource linking to steps
   - Resource viewing interface
   - Resource type handling (links, files, text)

2. Social Features
   - User profiles
   - Roadmap sharing
   - Following system
   - Activity feed

3. Search & Filter
   - Search functionality
   - Category system
   - Filter implementation
   - Sort options

4. Performance
   - Caching strategy
   - Pagination
   - Image optimization
   - Query optimization

5. Testing
   - Unit tests
   - Widget tests
   - Integration tests
   - Performance tests

Please help implement/improve [specific component] while maintaining the existing architecture and following Flutter best practices."
