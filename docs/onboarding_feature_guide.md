# Onboarding Feature Implementation

## Overview

The onboarding feature provides a smooth first-time user experience for new app installations. It introduces users to the key features of Mockee (the interview preparation app) through 5 beautifully designed screens.

## Architecture

### Files Structure

```
lib/features/onboarding/
├── domain/entities/
│   └── onboarding_page.dart          # OnboardingPage entity
├── data/
│   └── onboarding_data.dart          # Static onboarding content
└── presentation/
    ├── cubit/
    │   └── onboarding_cubit.dart     # State management
    ├── view/
    │   └── onboarding_view.dart      # Main onboarding screen
    └── widgets/
        ├── onboarding_page_widget.dart   # Individual page widget
        └── onboarding_indicator.dart     # Page indicator dots
```

### Key Components

#### 1. **OnboardingPage Entity**

- Defines the structure of each onboarding screen
- Properties: title, description, icon, iconColor
- Immutable and extends Equatable for state management

#### 2. **OnboardingCubit**

- Manages onboarding state and navigation
- Handles storage of completion status using GetStorage
- States: OnboardingInitial, OnboardingInProgress, OnboardingFinished
- Methods: startOnboarding, changePage, completeOnboarding, skipOnboarding

#### 3. **Onboarding Screens Content**

The app includes 5 onboarding screens:

1. **Welcome to Mockee** - Introduction and app overview
2. **Voice Interviews** - AI-powered voice interview practice
3. **MCQ Practice** - Multiple choice question testing
4. **Smart Analytics** - Performance tracking and insights
5. **Ready to Start?** - Final screen with call to action

## Integration

### Routes

- Added `/onboarding` route to AppRoutes
- Updated AppRouter to handle onboarding navigation
- Navigation flow: Splash → Onboarding (first time) → Login → Home

### Dependency Injection

- OnboardingCubit registered in injection_container.dart
- Available as singleton throughout app lifecycle

### Splash Screen Integration

- Modified SplashView to check onboarding completion status
- Routes to onboarding on first install, login on subsequent launches
- Uses OnboardingCubit.hasSeenOnboarding() for decision making

## Theme Integration

### Design System Compliance

- Uses AppColors.primaryPurple for consistent branding
- Follows light/dark theme switching from ThemeCubit
- Responsive design with proper spacing and typography
- Material 3 design principles with custom purple color scheme

### Visual Features

- Animated page transitions with PageController
- Smooth scaling animations for icons and content
- Animated page indicators with smooth transitions
- Back/Skip/Next navigation with proper state management

## Usage

### First Time User Flow

1. App launches → SplashView loads
2. AuthBloc determines user is unauthenticated
3. OnboardingCubit checks hasSeenOnboarding() → returns false
4. User navigates to OnboardingView
5. User can navigate through pages or skip
6. On completion, onboarding status is saved to storage
7. User navigates to LoginView

### Subsequent Launches

1. App launches → SplashView loads
2. OnboardingCubit checks hasSeenOnboarding() → returns true
3. User directly navigates to LoginView (skipping onboarding)

## Testing

### Unit Tests

- Comprehensive test suite for OnboardingCubit
- Tests cover state management, storage operations, and navigation logic
- Located: `test/features/onboarding/presentation/cubit/onboarding_cubit_test.dart`

### Test Cases Covered

- Initial state verification
- Start onboarding functionality
- Page navigation and state updates
- Completion and skip functionality
- Storage persistence verification

## API Reference

### OnboardingCubit Methods

```dart
// Start onboarding with specified number of pages
void startOnboarding(int totalPages)

// Change to specific page
void changePage(int pageIndex, int totalPages)

// Complete onboarding and save to storage
void completeOnboarding()

// Skip onboarding and save to storage
void skipOnboarding()

// Check if user has seen onboarding
bool hasSeenOnboarding()

// Reset onboarding status (for testing)
void resetOnboarding()
```

### Storage Keys

- `has_seen_onboarding`: Boolean flag stored in GetStorage

## Customization

### Adding New Onboarding Pages

1. Update `OnboardingData.getOnboardingPages()` in `onboarding_data.dart`
2. Add new OnboardingPage with title, description, and icon
3. Test the updated flow

### Styling Modifications

- Colors: Modify AppColors in `core/theme/colorpalette/app_colors.dart`
- Typography: Update text themes in theme files
- Animations: Adjust duration/curves in OnboardingPageWidget and OnboardingView

## Dependencies

- flutter_bloc: State management with BLoC pattern
- get_storage: Local storage for onboarding completion status
- equatable: Value equality for entities and states

## Performance Considerations

- Lazy loading of onboarding content
- Efficient state management with BLoC
- Minimal memory footprint with factory registration in DI
- Smooth animations without blocking UI thread

## Accessibility

- Screen reader friendly labels
- High contrast support
- Large touch targets (48dp minimum)
- Semantic navigation structure

## Future Enhancements

- Lottie animations support (imagePath/animation properties ready)
- Localization support for multiple languages
- Dynamic onboarding content from remote config
- A/B testing for different onboarding flows
- Analytics tracking for onboarding completion rates
