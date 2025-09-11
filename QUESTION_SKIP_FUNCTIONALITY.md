# Question Skip Functionality

## Overview

Implemented intelligent question skipping functionality in the voice interview system. When users express reluctance to answer a question or explicitly request to skip, the AI interviewer will gracefully move to the next question without repeating or insisting.

## How It Works

### User Skip Detection

The system automatically detects when users want to skip questions through natural language processing. It recognizes various skip phrases and converts them into a standardized skip request.

### Supported Skip Phrases

The system recognizes these phrases (case-insensitive):

#### Direct Skip Requests

- "skip"
- "skip this"
- "skip this question"
- "skip question"
- "next question"
- "move to next"
- "move to the next"
- "next"
- "move on"

#### Polite Decline Phrases

- "pass"
- "pass this"
- "pass this question"
- "I don't want to answer"
- "don't want to answer"
- "I'd rather not answer"
- "rather not answer"
- "I prefer not to answer"
- "prefer not to answer"

#### Uncertainty Expressions

- "I don't know"
- "no answer"
- "no comment"
- "I'll skip this"
- "I'll pass"

#### Collaborative Skip Requests

- "can we skip this"
- "let's skip this"

## Technical Implementation

### 1. Message Processing (`_processUserMessage`)

```dart
String _processUserMessage(String message) {
  final lowerMessage = message.toLowerCase().trim();

  // Detects skip phrases using multiple matching strategies:
  // - Exact match
  // - Starts with phrase
  // - Ends with phrase
  // - Contains phrase with word boundaries

  if (isSkipRequest) {
    return 'I would prefer to skip this question and move to the next one.';
  }

  return message; // Original message if no skip detected
}
```

### 2. Enhanced System Prompt

The AI interviewer receives specific instructions on handling skip requests:

```
IMPORTANT SKIP HANDLING: If a candidate says they want to skip a question,
prefer not to answer, or express reluctance to respond, DO NOT repeat the
question or insist. Instead, respond with: "That's perfectly fine.
Let's move on to the next question." Then immediately proceed to the next question.
Do not provide feedback on skipped questions. Simply acknowledge and move forward.
```

### 3. Logging and Monitoring

- **Skip detection logging**: Tracks when skip requests are identified
- **Message transformation logging**: Records original vs processed messages
- **Interview flow tracking**: Monitors question progression and skips

## User Experience

### Before

- ❌ AI would repeat questions if user seemed reluctant
- ❌ No graceful way to skip uncomfortable questions
- ❌ Could create awkward interview situations
- ❌ Users might give poor answers just to move on

### After

- ✅ **Natural skip detection** from conversational phrases
- ✅ **Graceful acknowledgment** without judgment
- ✅ **Immediate progression** to next question
- ✅ **Professional interview flow** maintained
- ✅ **User comfort** prioritized

## Example Interactions

### Scenario 1: Direct Skip Request

**User**: "Can we skip this question?"
**System Processing**: Detects skip → Converts to standardized request
**AI Response**: "That's perfectly fine. Let's move on to the next question. Question 3 of 5: [Next question]"

### Scenario 2: Polite Decline

**User**: "I'd rather not answer that"
**System Processing**: Detects reluctance → Converts to skip request
**AI Response**: "That's perfectly fine. Let's move on to the next question. Question 4 of 5: [Next question]"

### Scenario 3: Uncertainty Expression

**User**: "I don't really know"
**System Processing**: Detects uncertainty → Converts to skip request
**AI Response**: "That's perfectly fine. Let's move on to the next question. Question 2 of 5: [Next question]"

## Benefits

### For Users

- **Reduced stress** during difficult questions
- **Maintained dignity** when uncomfortable topics arise
- **Natural conversation flow** without awkward repetition
- **Better interview experience** overall

### For Interview Quality

- **Authentic responses** rather than forced poor answers
- **Professional atmosphere** maintained
- **Focus on answerable questions** where user can demonstrate skills
- **Realistic simulation** of professional interview dynamics

### For System Performance

- **Intelligent conversation management**
- **Reduced API calls** from repeated questions
- **Better interview completion rates**
- **Enhanced user satisfaction**

## Edge Cases Handled

### 1. Partial Phrase Matching

- "I think I'll skip this one" ✅ Detected
- "Let's move to the next question please" ✅ Detected
- "Can we pass on this?" ✅ Detected

### 2. Natural Language Variations

- Different word orders and combinations
- Casual vs formal language
- Hesitation patterns

### 3. False Positive Prevention

- Context-aware matching
- Word boundary detection
- Phrase position awareness

## Files Modified

- `lib/core/services/gemini_ai_service/voice_interview_service.dart`

## Configuration

No additional configuration required. The functionality is automatically active for all voice interviews.

## Testing Recommendations

1. **Test skip phrase recognition** with various formulations
2. **Verify AI response appropriateness** to skip requests
3. **Check interview flow continuity** after skips
4. **Monitor skip frequency** in real interviews
5. **Validate question counting** remains accurate with skips

## Future Enhancements

- **Multilingual skip detection** for international users
- **Skip reason categorization** for analytics
- **Adaptive questioning** based on skip patterns
- **User preference learning** for question types
- **Skip limit configuration** to ensure minimum interview coverage
