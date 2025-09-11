# Ad Test Screen Usage Guide

## How to Access the Test Screen

1. **Run the app in debug mode** (`flutter run`)
2. **Navigate to the Home screen**
3. **Look for the orange "Test Ads" floating action button** (only visible in debug mode)
4. **Tap the button** to open the Ad Test Screen

## Test Screen Features

### 🚀 Initialization

- **Initialize Ads**: Sets up the ad system and initializes AdMob

### 🎯 Ad Display Tests (Green Buttons)

These are the only buttons that will actually show ads:

- **Test Post-Interview Ad (MCQ)**: Simulates completing an MCQ interview
- **Test Post-Interview Ad (Voice)**: Simulates completing a voice interview

**Important**: Ads will only show if:

- At least 3 interactions have been tracked
- At least 3 minutes have passed since the last ad was shown

### 📊 Tracking Tests (Orange Buttons)

These buttons only track interactions but don't show ads:

- **Pre-Interview Tracking**: Tracks when user starts an interview
- **Results Viewing Tracking**: Tracks when user views results
- **Menu Navigation Tracking**: Tracks menu navigation
- **Interview Retry Tracking**: Tracks when user retries an interview

### 🔧 Direct Ad Controls (Purple Buttons)

For debugging purposes:

- **Force Load Ad**: Directly loads an interstitial ad
- **Force Show Ad**: Directly shows a loaded ad (if available)

### ⚙️ Session Management (Cyan/Red Buttons)

- **Add Interaction**: Manually add an interaction to the counter
- **Reset Session**: Reset interaction counter and ad timing

## Understanding the Status Card

The status card shows:

- **Initialization Status**: Whether ads have been initialized
- **Last Action**: The most recent action performed
- **Interactions**: Current interaction count
- **Last Ad**: When the last ad was shown (if any)

## Understanding the Logs

The logs section shows real-time information about:

- Ad initialization status
- Ad loading attempts
- Ad display attempts
- Tracking events
- Error messages

## Testing Workflow

1. **Start by initializing ads**
2. **Add some interactions** (at least 3)
3. **Test post-interview ads** to see if they display
4. **Check logs** for detailed information about what's happening
5. **Use tracking tests** to verify interaction counting works
6. **Reset session** to test different scenarios

## Troubleshooting

### Ads Not Showing?

1. Check if you have at least 3 interactions
2. Ensure at least 3 minutes have passed since last ad
3. Check logs for error messages
4. Try "Force Load Ad" then "Force Show Ad" to test direct AdMob integration

### No Logs Appearing?

1. Make sure AppLogger is working in your environment
2. Check the terminal/console for log output
3. Verify ad services are properly initialized

### Test Screen Not Accessible?

1. Make sure you're running in debug mode (`flutter run`)
2. The floating action button only appears in debug mode
3. Check that kDebugMode is true in your environment
