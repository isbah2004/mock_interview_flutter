# Voice Interview Screen - UI Wireframe & Feature Summary

## Screen Layout (Top to Bottom)

```
┌─────────────────────────────────────────────────┐
│                   App Bar                       │
│  "Voice Interview"                        [X]   │
├─────────────────────────────────────────────────┤
│              Progress Tracker                   │
│  Question Progress      [●●●○○○○○○○] 3 of 10    │
│  ████████████████████████░░░░░░░░░░░░░ 30%      │
├─────────────────────────────────────────────────┤
│                    Timer                        │
│  ⏱️ Time Remaining    [Progress] 01:30          │
├─────────────────────────────────────────────────┤
│                                                 │
│           Question Display Card                 │
│  📝 Current Question                            │
│                                                 │
│  "Tell me about your experience with Flutter    │
│   and how you've used it in previous projects?" │
│                                                 │
├─────────────────────────────────────────────────┤
│              TTS Controls                       │
│  🔊 Text-to-Speech Controls                     │
│     [▶️] [⏹️] [🔄]                              │
│     Play  Stop  Replay                          │
│          [Playing]                              │
├─────────────────────────────────────────────────┤
│                                                 │
│           Microphone Widget                     │
│              [Mic Active] 🟢                    │
│                                                 │
│                   🎤                           │
│           (Pulsing Animation)                   │
│                                                 │
│          "Tap to stop recording"                │
│             Recording ●●●                       │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│           Transcript Input Area                 │
│  📝 Your Response                      [LIVE]   │
│  ┌─────────────────────────────────────────────┐│
│  │ I have been working with Flutter for the   ││
│  │ past two years. In my previous role at XYZ ││
│  │ company, I developed a mobile app that...   ││
│  │                                             ││
│  │                                             ││
│  │ (Scrollable text area)                      ││
│  └─────────────────────────────────────────────┘│
│  15 words                Min. 10 words required │
│                                                 │
├─────────────────────────────────────────────────┤
│              Submit Button                      │
│            [Submit Response]                    │
└─────────────────────────────────────────────────┘
```

## Key Features Implemented

### 1. **Progress Tracking**

- Question counter (e.g., "3 of 10")
- Visual progress bar with percentage
- Dot indicators for each question
- Real-time updates as user progresses

### 2. **Interview Timer**

- 2-minute countdown per question
- Visual progress circle
- Color-coded warnings (orange at 30s, red at 10s)
- Pulsing animation for urgency
- Auto-submission when time expires

### 3. **Question Display**

- Clean card-based design
- Loading state indicator
- Clear typography with proper spacing
- Auto-scrolling for long questions

### 4. **Text-to-Speech Controls**

- Play/Pause toggle button
- Stop functionality
- Replay question option
- Visual status indicator (Playing/Paused/Stopped)
- Disabled state when not available

### 5. **Microphone Management**

- Visual status indicator (Green "Mic Active" / Red "Mic Off")
- Large, accessible microphone button
- Pulsing animation during recording
- Recording indicator with animated dots
- Clear instructions for user interaction

### 6. **Real-time Transcription**

- Live transcription display
- Scrollable text area for long responses
- Manual editing capability
- Word count with color coding
- Minimum word requirement (10 words)
- "LIVE" indicator during active recording

### 7. **Validation & Restrictions**

- Empty response prevention
- Minimum word count enforcement
- Real-time word count display
- Visual feedback for validation state
- Disabled submit when processing

### 8. **Accessibility Features**

- High contrast mode support
- Large touch targets (48dp minimum)
- Clear visual hierarchy
- Screen reader friendly labels
- Keyboard navigation support
- Adjustable text sizes

### 9. **Error Handling**

- Microphone permission errors
- Network connectivity issues
- TTS initialization failures
- Speech recognition errors
- Graceful error recovery options

### 10. **User Experience**

- Smooth animations and transitions
- Immediate visual feedback
- Clear action buttons
- Intuitive navigation
- Progress preservation
- End interview confirmation dialog

## BLoC Architecture Events & States

### Events Added:

- `PlayTTS` - Start text-to-speech
- `PauseTTS` - Pause TTS playback
- `StopTTS` - Stop TTS completely
- `ReplayTTS` - Replay current question
- `EndInterview` - User initiated end
- `RetryCurrentQuestion` - Retry on error
- `TimeUpForQuestion` - Timer expiry
- `UpdateTranscriptText` - Manual text edits

### Key States:

- `VoiceInterviewReady` - Active interview state
- `VoiceInterviewLoading` - Initialization
- `VoiceInterviewError` - Error handling
- `VoiceInterviewCompleted` - Interview finished

## Integration Notes

The voice interview screen integrates seamlessly with:

- **Navigation**: Routes to result screen on completion
- **Persistence**: Session data automatically saved
- **Theme**: Responds to light/dark mode changes
- **Permissions**: Handles mic access gracefully
- **Background**: Prevents app backgrounding during interview

## Technical Dependencies Met:

✅ flutter_tts for text-to-speech
✅ speech_to_text for transcription  
✅ permission_handler for microphone access
✅ flutter_bloc for state management
✅ Clean architecture pattern followed
