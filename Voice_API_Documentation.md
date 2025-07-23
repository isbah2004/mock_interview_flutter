# Voice Interview API Documentation

## Overview

The Voice interview system provides real-time, conversational interview experiences using WebSocket connections. It supports enhanced features including difficulty levels, question categories, and dynamic conversation flow with AI-powered evaluation.

## New Features

### 1. Difficulty Levels

- **Easy**: Basic questions and fundamental knowledge assessment
- **Medium**: Practical application and intermediate concept evaluation
- **Hard**: Advanced scenarios and complex problem-solving discussions

### 2. Question Categories

- **General**: Basic professional skills and workplace knowledge
- **Technical**: Job-specific technical skills and deep knowledge
- **Behavioral**: Soft skills, teamwork, leadership, and problem-solving approach
- **Industry Specific**: Industry trends, standards, and domain expertise

### 3. Real-time Conversation

- Dynamic question generation based on previous answers
- Immediate feedback and scoring
- Context-aware follow-up questions
- Natural conversation flow

## WebSocket API

### Connection Endpoint

```
ws://localhost:8000/ws/voice_interview
```

### Message Protocol

All messages follow this structure:

```json
{
  "type": "message_type",
  "data": {
    /* message-specific data */
  }
}
```

## API Flow

### 1. Start Voice Interview

**Client → Server (Start Message):**

```json
{
  "type": "start",
  "data": {
    "user_id": "user123",
    "job_role": "Software Engineer",
    "interview_type": "voice",
    "difficulty_level": "medium",
    "category": "technical"
  }
}
```

**Server → Client (First Question):**

```json
{
  "type": "question",
  "data": {
    "question": "Tell me about your experience with Python and why you chose it for your recent projects?",
    "question_id": "session-uuid"
  }
}
```

### 2. Submit Answer

**Client → Server (Answer Message):**

```json
{
  "type": "answer",
  "data": {
    "user_id": "user123",
    "job_role": "Software Engineer",
    "interview_type": "voice",
    "answer": "I have been working with Python for 3 years. I chose it for my recent projects because of its simplicity and extensive library ecosystem, particularly for data analysis and web development.",
    "question_id": "session-uuid"
  }
}
```

**Server → Client (Response with Next Question):**

```json
{
  "type": "response",
  "data": {
    "question": "That's great! Can you walk me through a specific challenge you faced while working with Python libraries and how you solved it?",
    "feedback": "Good answer! You demonstrated understanding of Python's strengths. Your experience shows practical application.",
    "score": 85.0,
    "question_id": "session-uuid"
  }
}
```

### 3. End Interview

**Client → Server (End Message):**

```json
{
  "type": "end",
  "data": {
    "reason": "time_up"
  }
}
```

**Server → Client (Final Summary):**

```json
{
  "type": "summary",
  "data": {
    "session_complete": true,
    "total_questions": 8,
    "average_score": 82.5,
    "feedback": "Overall strong performance with good technical knowledge and clear communication."
  }
}
```

## Message Types

### Client to Server

| Type     | Purpose         | Required Data                                                 |
| -------- | --------------- | ------------------------------------------------------------- |
| `start`  | Begin interview | user_id, job_role, interview_type, difficulty_level, category |
| `answer` | Submit response | user_id, job_role, interview_type, answer, question_id        |
| `end`    | End interview   | reason (optional)                                             |

### Server to Client

| Type       | Purpose                           | Data Included                                              |
| ---------- | --------------------------------- | ---------------------------------------------------------- |
| `question` | First question                    | question, question_id                                      |
| `response` | Answer evaluation + next question | question, feedback, score, question_id                     |
| `error`    | Error message                     | detail (error description)                                 |
| `summary`  | Final interview summary           | session_complete, total_questions, average_score, feedback |

## Usage Examples

### 1. Easy Behavioral Interview for Entry Level

```json
{
  "type": "start",
  "data": {
    "user_id": "junior_dev_001",
    "job_role": "Junior Software Developer",
    "interview_type": "voice",
    "difficulty_level": "easy",
    "category": "behavioral"
  }
}
```

**Expected Questions:**

- "Tell me about yourself and why you're interested in software development"
- "Describe a time when you had to learn something new quickly"
- "How do you handle working in a team environment?"

### 2. Hard Technical Interview for Senior Position

```json
{
  "type": "start",
  "data": {
    "user_id": "senior_dev_001",
    "job_role": "Senior Full Stack Engineer",
    "interview_type": "voice",
    "difficulty_level": "hard",
    "category": "technical"
  }
}
```

**Expected Questions:**

- "Explain the trade-offs between microservices and monolithic architecture"
- "How would you design a system to handle 1 million concurrent users?"
- "Walk me through your approach to debugging a performance issue in production"

### 3. Medium Industry-Specific Interview for Data Scientist

```json
{
  "type": "start",
  "data": {
    "user_id": "data_scientist_001",
    "job_role": "Data Scientist",
    "interview_type": "voice",
    "difficulty_level": "medium",
    "category": "industry_specific"
  }
}
```

**Expected Questions:**

- "What's your experience with A/B testing and statistical significance?"
- "How do you handle missing data in your machine learning models?"
- "Explain how you would measure the success of a recommendation system"

## Session Management

### Voice Interview Sessions

- Sessions are created automatically when starting a voice interview
- Each session maintains conversation history and context
- Sessions include difficulty level and category for consistent question generation
- Automatic cleanup after 30 minutes of inactivity
- Memory management with ConversationBufferMemory for context retention

### Session Storage

```python
# Session structure
{
  "session_id": "uuid",
  "job_role": "Software Engineer",
  "difficulty": "medium",
  "category": "technical",
  "memory": ConversationBufferMemory(),
  "created_at": timestamp,
  "last_activity": timestamp
}
```

## Error Handling

### Common Error Scenarios

1. **Invalid Start Message**

```json
{
  "type": "error",
  "data": {
    "detail": "Expected 'start' message to begin interview"
  }
}
```

2. **Invalid Interview Type**

```json
{
  "type": "error",
  "data": {
    "detail": "Invalid interview type for WebSocket"
  }
}
```

3. **Session Expired**

```json
{
  "type": "error",
  "data": {
    "detail": "Session expired or not found"
  }
}
```

4. **Invalid Answer Format**

```json
{
  "type": "error",
  "data": {
    "detail": "Invalid answer or session ID"
  }
}
```

## Duration Control (Recommended Approach)

### Client-Side Duration Management

The Flutter app should handle interview duration for optimal user experience:

```dart
// Example Flutter implementation
class VoiceInterviewTimer {
  Timer? _timer;
  int remainingSeconds;
  WebSocketChannel? channel;

  void startInterview(int durationMinutes) {
    remainingSeconds = durationMinutes * 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 0) {
        endInterview("time_up");
      } else {
        remainingSeconds--;
        updateUI(); // Update timer display
      }
    });
  }

  void endInterview(String reason) {
    channel?.sink.add(jsonEncode({
      "type": "end",
      "data": {"reason": reason}
    }));
    _timer?.cancel();
  }
}
```

**Benefits of Client-Side Duration Control:**

- Real-time visual feedback for users
- Consistent experience across all interview types
- Ability to pause/extend interviews
- Works offline during temporary connection issues
- Reduces backend complexity

## WebSocket Connection Management

### Connection Lifecycle

1. **Connect**: Client establishes WebSocket connection
2. **Start**: Client sends start message with interview parameters
3. **Question Loop**: Server sends questions, client responds with answers
4. **End**: Either client ends interview or session times out
5. **Cleanup**: Server removes session from memory

### Connection Best Practices

- Handle connection drops gracefully
- Implement reconnection logic with session restoration
- Send periodic heartbeat messages to maintain connection
- Store session state locally for recovery
- Implement proper error handling for all message types

## Performance Considerations

- Sessions are stored in memory for fast access
- Automatic session cleanup prevents memory leaks
- ConversationBufferMemory maintains context efficiently
- Rate limiting prevents abuse
- Caching reduces LLM API calls

## Security Features

- Session isolation with unique UUIDs
- Input validation for all messages
- Rate limiting per connection
- CORS configuration for Flutter origins
- No persistent storage of sensitive data

## Integration with Flutter App

### WebSocket Connection Setup

```dart
// Flutter WebSocket connection
final channel = WebSocketChannel.connect(
  Uri.parse('ws://your-api-domain.com/ws/voice_interview'),
);

// Send start message
channel.sink.add(jsonEncode({
  "type": "start",
  "data": {
    "user_id": userId,
    "job_role": jobRole,
    "interview_type": "voice",
    "difficulty_level": difficultyLevel,
    "category": category
  }
}));

// Listen for responses
channel.stream.listen((message) {
  final data = jsonDecode(message);
  handleServerMessage(data);
});
```

### Message Handling

```dart
void handleServerMessage(Map<String, dynamic> data) {
  switch (data['type']) {
    case 'question':
      displayQuestion(data['data']['question']);
      break;
    case 'response':
      displayFeedback(data['data']['feedback']);
      displayNextQuestion(data['data']['question']);
      updateScore(data['data']['score']);
      break;
    case 'error':
      showError(data['data']['detail']);
      break;
    case 'summary':
      showFinalResults(data['data']);
      break;
  }
}
```

This documentation provides comprehensive guidance for implementing and using the Voice Interview API with all the enhanced features including difficulty levels and categories!
