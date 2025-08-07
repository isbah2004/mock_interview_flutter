# Interview Feature Database Design Document

## Architecture Overview

This document outlines the database design for the Interview Feature in the Mock Interview Flutter application. The system follows Clean Architecture principles with BLoC state management and uses both external API services and Appwrite as the database backend.

## Technology Stack

- **Database**: Appwrite (NoSQL Document Database)
- **Authentication**: Firebase Auth
- **API Integration**: External MCQ Interview API via Dio HTTP client
- **State Management**: BLoC Pattern
- **Architecture**: Clean Architecture (Domain, Data, Presentation layers)

## Data Flow Architecture

### 1. Interview Workflow

```
User Setup → Start Interview → Submit Answers → Store Results
     ↓              ↓               ↓              ↓
   UI Setup    API Request    API Response    Database Storage
```

### 2. Layer Interaction

```
Presentation Layer (BLoC)
        ↓
Domain Layer (Use Cases & Entities)
        ↓
Data Layer (Repository & Remote Data Source)
        ↓
External API + Appwrite Database
```

## Core Entities

### 1. Interview Entity

```dart
class Interview {
  final String sessionId;           // Unique session identifier
  final String jobRole;            // Target job position
  final DifficultyLevel difficulty; // easy, medium, hard
  final QuestionCategory category;  // general, technical, behavioral, industrySpecific
  final int totalQuestions;        // Number of questions in session
  final List<Question> questions;  // List of questions for the interview
  final String message;            // Response message from API
  final DateTime sessionCreatedAt; // Session creation timestamp
}
```

### 2. Question Entity

```dart
class Question {
  final int id;                    // Question unique identifier
  final String question;           // Question text
  final List<String> options;      // Multiple choice options (A, B, C, D)
  final String correctAnswer;      // Correct answer (A, B, C, D)
  final String explanation;        // Detailed explanation
  final DifficultyLevel difficulty; // Question difficulty
  final QuestionCategory category;  // Question category
  final String topic;              // Specific topic/skill area
}
```

### 3. EvaluationResult Entity

```dart
class EvaluationResult {
  final String sessionId;          // Session identifier
  final int totalQuestions;        // Total number of questions
  final List<QuestionResult> results; // Individual question results
  final double finalScore;         // Calculated final score
  final double percentage;         // Score percentage
  final bool passed;              // Pass/fail status
  final bool sessionComplete;     // Completion status
  final DateTime completedAt;     // Completion timestamp
}
```

### 4. QuestionResult Entity

```dart
class QuestionResult {
  final int questionId;           // Question identifier
  final String question;          // Question text snapshot
  final String userAnswer;        // User's selected answer
  final String correctAnswer;     // Correct answer
  final bool isCorrect;          // Whether answer was correct
  final int score;               // Points awarded
  final String explanation;       // Answer explanation
}
```

## Database Collections Schema

### 1. Users Collection

**Collection ID**: `68777f1300324ee21d1e`

```json
{
  "id": "string (Firebase UID)",
  "name": "string (Display name)",
  "email": "string (Email address)",
  "photoUrl": "string (Profile image URL)",
  "totalInterviews": "integer (Count of completed interviews)",
  "averageScore": "float (Average score across interviews)",
  "createdAt": "datetime (Account creation)",
  "updatedAt": "datetime (Last profile update)",
  "provider": "string (auth provider: email, google, facebook)"
}
```

#### Appwrite Attributes Table

| Attribute Key     | Type     | Size/Length | Required | Default | Array | Enum Values             |
| ----------------- | -------- | ----------- | -------- | ------- | ----- | ----------------------- |
| `id`              | String   | 128         | ✅       | -       | ❌    | -                       |
| `name`            | String   | 100         | ✅       | -       | ❌    | -                       |
| `email`           | Email    | 255         | ✅       | -       | ❌    | -                       |
| `photoUrl`        | URL      | 500         | ❌       | null    | ❌    | -                       |
| `totalInterviews` | Integer  | -           | ✅       | 0       | ❌    | -                       |
| `averageScore`    | Float    | -           | ✅       | 0.0     | ❌    | -                       |
| `createdAt`       | DateTime | -           | ✅       | -       | ❌    | -                       |
| `updatedAt`       | DateTime | -           | ✅       | -       | ❌    | -                       |
| `provider`        | String   | 20          | ✅       | 'email' | ❌    | email, google, facebook |

**Indexes**:

- Primary: `id`
- Secondary: `email`, `createdAt`

### 2. Questions Collection

**Collection ID**: `68777f4b0004adb16d79`

```json
{
  "id": "integer (Auto-increment)",
  "question": "string (Question text)",
  "options": "array<string> (4 options)",
  "correctAnswer": "string (A, B, C, D)",
  "explanation": "string (Detailed explanation)",
  "difficulty": "string (easy, medium, hard)",
  "category": "string (general, technical, behavioral, industrySpecific)",
  "topic": "string (Specific topic)",
  "jobRoles": "array<string> (Applicable job roles)",
  "tags": "array<string> (Categorization tags)",
  "timeRecommended": "integer (Recommended time in seconds)",
  "createdAt": "datetime",
  "updatedAt": "datetime",
  "isActive": "boolean (Question availability)",
  "usageCount": "integer (Times used)",
  "successRate": "float (Correct answer percentage)"
}
```

#### Appwrite Attributes Table

| Attribute Key     | Type     | Size/Length | Required | Default   | Array | Enum Values                                      |
| ----------------- | -------- | ----------- | -------- | --------- | ----- | ------------------------------------------------ |
| `id`              | Integer  | -           | ✅       | -         | ❌    | -                                                |
| `question`        | String   | 1000        | ✅       | -         | ❌    | -                                                |
| `options`         | String   | 100         | ✅       | -         | ✅    | -                                                |
| `correctAnswer`   | String   | 1           | ✅       | -         | ❌    | A, B, C, D                                       |
| `explanation`     | String   | 2000        | ✅       | -         | ❌    | -                                                |
| `difficulty`      | String   | 10          | ✅       | 'medium'  | ❌    | easy, medium, hard                               |
| `category`        | String   | 20          | ✅       | 'general' | ❌    | general, technical, behavioral, industrySpecific |
| `topic`           | String   | 100         | ✅       | -         | ❌    | -                                                |
| `jobRoles`        | String   | 50          | ❌       | -         | ✅    | -                                                |
| `tags`            | String   | 30          | ❌       | -         | ✅    | -                                                |
| `timeRecommended` | Integer  | -           | ✅       | 30        | ❌    | -                                                |
| `createdAt`       | DateTime | -           | ✅       | -         | ❌    | -                                                |
| `updatedAt`       | DateTime | -           | ✅       | -         | ❌    | -                                                |
| `isActive`        | Boolean  | -           | ✅       | true      | ❌    | -                                                |
| `usageCount`      | Integer  | -           | ✅       | 0         | ❌    | -                                                |
| `successRate`     | Float    | -           | ✅       | 0.0       | ❌    | -                                                |

**Indexes**:

- Primary: `id`
- Composite: `difficulty + category`, `category + topic`
- Secondary: `isActive`, `jobRoles` (fulltext)

### 3. Sessions Collection

**Collection ID**: `68777f59001dc82cdeea`

```json
{
  "sessionId": "string (UUID)",
  "userId": "string (Foreign Key - Users.id)",
  "jobRole": "string (Target job role)",
  "type": "string (mcq, voice)",
  "difficulty": "string (easy, medium, hard)",
  "category": "string (general, technical, behavioral, industrySpecific)",
  "totalQuestions": "integer",
  "timePerQuestion": "integer (seconds)",
  "status": "string (started, in_progress, completed, abandoned)",
  "score": "float (null until completion)",
  "percentage": "float (Score percentage)",
  "isComplete": "boolean",
  "passed": "boolean (null until completion)",
  "startedAt": "datetime",
  "completedAt": "datetime (null if not completed)",
  "duration": "integer (seconds, null until completion)",
  "questionIds": "array<integer> (IDs of questions used)",
  "configuration": "string (JSON config object)"
}
```

#### Appwrite Attributes Table

| Attribute Key     | Type     | Size/Length | Required | Default   | Array | Enum Values                                      |
| ----------------- | -------- | ----------- | -------- | --------- | ----- | ------------------------------------------------ |
| `sessionId`       | String   | 36          | ✅       | -         | ❌    | -                                                |
| `userId`          | String   | 128         | ✅       | -         | ❌    | -                                                |
| `jobRole`         | String   | 100         | ✅       | -         | ❌    | -                                                |
| `type`            | String   | 10          | ✅       | 'mcq'     | ❌    | mcq, voice                                       |
| `difficulty`      | String   | 10          | ✅       | 'medium'  | ❌    | easy, medium, hard                               |
| `category`        | String   | 20          | ✅       | 'general' | ❌    | general, technical, behavioral, industrySpecific |
| `totalQuestions`  | Integer  | -           | ✅       | 10        | ❌    | -                                                |
| `timePerQuestion` | Integer  | -           | ✅       | 30        | ❌    | -                                                |
| `status`          | String   | 15          | ✅       | 'started' | ❌    | started, in_progress, completed, abandoned       |
| `score`           | Float    | -           | ❌       | null      | ❌    | -                                                |
| `percentage`      | Float    | -           | ❌       | null      | ❌    | -                                                |
| `isComplete`      | Boolean  | -           | ✅       | false     | ❌    | -                                                |
| `passed`          | Boolean  | -           | ❌       | null      | ❌    | -                                                |
| `startedAt`       | DateTime | -           | ✅       | -         | ❌    | -                                                |
| `completedAt`     | DateTime | -           | ❌       | null      | ❌    | -                                                |
| `duration`        | Integer  | -           | ❌       | null      | ❌    | -                                                |
| `questionIds`     | Integer  | -           | ✅       | -         | ✅    | -                                                |
| `configuration`   | String   | 500         | ✅       | -         | ❌    | -                                                |

**Indexes**:

- Primary: `sessionId`
- Composite: `userId + completedAt`, `jobRole + category`
- Secondary: `status`, `type`, `isComplete`

### 4. Interviews Collection

**Collection ID**: `68777f3d0018267de13f`

```json
{
  "interviewId": "string (UUID)",
  "sessionId": "string (Foreign Key - Sessions.sessionId)",
  "userId": "string (Foreign Key - Users.id)",
  "jobRole": "string",
  "category": "string",
  "difficulty": "string",
  "totalQuestions": "integer",
  "correctAnswers": "integer",
  "incorrectAnswers": "integer",
  "skippedQuestions": "integer",
  "finalScore": "float",
  "percentage": "float",
  "passed": "boolean",
  "timeSpent": "integer (seconds)",
  "averageTimePerQuestion": "float",
  "completedAt": "datetime",
  "results": "string (JSON array of QuestionResult objects)",
  "analytics": "string (JSON analytics object)"
}
```

#### Appwrite Attributes Table

| Attribute Key            | Type     | Size/Length | Required | Default | Array | Enum Values                                      |
| ------------------------ | -------- | ----------- | -------- | ------- | ----- | ------------------------------------------------ |
| `interviewId`            | String   | 36          | ✅       | -       | ❌    | -                                                |
| `sessionId`              | String   | 36          | ✅       | -       | ❌    | -                                                |
| `userId`                 | String   | 128         | ✅       | -       | ❌    | -                                                |
| `jobRole`                | String   | 100         | ✅       | -       | ❌    | -                                                |
| `category`               | String   | 20          | ✅       | -       | ❌    | general, technical, behavioral, industrySpecific |
| `difficulty`             | String   | 10          | ✅       | -       | ❌    | easy, medium, hard                               |
| `totalQuestions`         | Integer  | -           | ✅       | -       | ❌    | -                                                |
| `correctAnswers`         | Integer  | -           | ✅       | -       | ❌    | -                                                |
| `incorrectAnswers`       | Integer  | -           | ✅       | -       | ❌    | -                                                |
| `skippedQuestions`       | Integer  | -           | ✅       | 0       | ❌    | -                                                |
| `finalScore`             | Float    | -           | ✅       | -       | ❌    | -                                                |
| `percentage`             | Float    | -           | ✅       | -       | ❌    | -                                                |
| `passed`                 | Boolean  | -           | ✅       | -       | ❌    | -                                                |
| `timeSpent`              | Integer  | -           | ✅       | -       | ❌    | -                                                |
| `averageTimePerQuestion` | Float    | -           | ✅       | -       | ❌    | -                                                |
| `completedAt`            | DateTime | -           | ✅       | -       | ❌    | -                                                |
| `results`                | String   | 10000       | ✅       | -       | ❌    | -                                                |
| `analytics`              | String   | 5000        | ✅       | -       | ❌    | -                                                |

**Indexes**:

- Primary: `interviewId`
- Composite: `userId + completedAt`, `jobRole + category`
- Secondary: `passed`, `percentage`

## Data Storage Strategy

### 1. Hybrid Approach

- **External API**: Primary source for questions and evaluation logic
- **Appwrite Database**: Persistent storage for user data, sessions, and results
- **Local Storage**: Temporary session data during interviews

### 2. API Integration Points

#### Start Interview

```
POST /api/v1/start_interview
→ Returns: Interview object with questions
→ Store session in Appwrite Sessions collection
```

#### Submit Answers

```
POST /api/v1/submit_answer
→ Returns: EvaluationResult with scores and analysis
→ Store results in Appwrite Interviews collection
```

#### Session Management

```
GET /api/v1/session_stats/{sessionId}
DELETE /api/v1/session/{sessionId}
GET /api/v1/active_sessions
```

### 3. No Individual Response Storage

**Important**: Individual question responses are NOT stored in a separate collection. Instead:

- All question results are embedded in the `results` JSON field of the Interviews collection
- This provides better performance and data consistency
- Matches the `EvaluationResult.results` entity structure

## Use Cases Implementation

### 1. Start Interview Use Case

```dart
class StartInterview {
  // Input: userId, jobRole, difficulty, numQuestions, category
  // Output: Interview entity with questions
  // Side Effects: Creates session in Appwrite
}
```

### 2. Submit Answers Use Case

```dart
class SubmitAnswers {
  // Input: sessionId, userId, answers array
  // Output: EvaluationResult with scores and analysis
  // Side Effects: Creates interview record in Appwrite
}
```

### 3. Session Management Use Cases

```dart
class GetSessionStats    // Retrieve session statistics
class DeleteSession      // Delete session data
class GetActiveSessions  // Get active sessions
class CheckHealth        // API health check
```

## Key Relationships

```
Users (1) ←→ (N) Sessions
Sessions (1) ←→ (1) Interviews
Questions (N) ←→ (N) Sessions (via questionIds array)
```

## Field Size Specifications

### String Fields

- **Small (1-50 chars)**: `correctAnswer`, `userAnswer`, `difficulty`, `category`, `type`, `status`
- **Medium (50-500 chars)**: `name`, `jobRole`, `topic`, `sessionId`, `userId`, `configuration`
- **Large (500+ chars)**: `question`, `explanation`, `results`, `analytics`

### Numeric Fields

- **Integers**: `totalQuestions` (1-50), `timePerQuestion` (15-300), `score` (0-100)
- **Floats**: `percentage` (0.0-100.0), `finalScore`, `averageScore`

## Security & Permissions

### Appwrite Permissions

1. **Users**: Read/write own profile
2. **Questions**: Read-only for authenticated users
3. **Sessions**: Read/write own sessions
4. **Interviews**: Read own interviews, system-write only

## Performance Optimizations

### Indexing Strategy

- **Composite indexes** for multi-field queries (userId + dates)
- **Selective indexes** on frequently queried fields
- **Full-text search** on job roles and tags

### Data Patterns

- **Denormalization** in Interviews collection for performance
- **JSON storage** for complex objects (results, analytics)
- **Pagination** for large result sets
- **Caching** of frequently accessed questions

## API Constants

```dart
class ApiConstants {
  static const String startInterview = '/api/v1/start_interview';
  static const String submitResponse = '/api/v1/submit_answer';
  static const String sessionStats = '/api/v1/session_stats';
  static const String deleteSession = '/api/v1/session';
  static const String activeSessions = '/api/v1/active_sessions';
  static const String healthCheck = '/api/v1/health';
}
```

## Appwrite Configuration

```dart
class AppSecrets {
  static const String databaseId = '687765bf0013ce99c541';
  static const String usersCollection = '68777f1300324ee21d1e';
  static const String questionsCollection = '68777f4b0004adb16d79';
  static const String sessionsCollection = '68777f59001dc82cdeea';
  static const String interviewsCollection = '68777f3d0018267de13f';
}
```

## Appwrite Setup Instructions

### 1. Field Size Guidelines

#### String Field Categories

- **Small (1-50 chars)**: `correctAnswer`, `difficulty`, `category`, `type`, `status`
- **Medium (50-500 chars)**: `name`, `jobRole`, `topic`, `sessionId`, `userId`, `configuration`
- **Large (500+ chars)**: `question`, `explanation`, `results`, `analytics`

#### Numeric Field Ranges

- **Integers**: `totalQuestions` (1-50), `timePerQuestion` (15-300), `score` (0-100)
- **Floats**: `percentage` (0.0-100.0), `finalScore`, `averageScore`

### 2. Appwrite CLI Setup Commands

```bash
# Create indexes for Users collection
appwrite databases createIndex 687765bf0013ce99c541 68777f1300324ee21d1e --key idx_users_email --type key --attributes email
appwrite databases createIndex 687765bf0013ce99c541 68777f1300324ee21d1e --key idx_users_created --type key --attributes createdAt

# Create indexes for Questions collection
appwrite databases createIndex 687765bf0013ce99c541 68777f4b0004adb16d79 --key idx_questions_diff_cat --type key --attributes difficulty,category
appwrite databases createIndex 687765bf0013ce99c541 68777f4b0004adb16d79 --key idx_questions_cat_topic --type key --attributes category,topic
appwrite databases createIndex 687765bf0013ce99c541 68777f4b0004adb16d79 --key idx_questions_active --type key --attributes isActive
appwrite databases createIndex 687765bf0013ce99c541 68777f4b0004adb16d79 --key idx_questions_roles --type fulltext --attributes jobRoles

# Create indexes for Sessions collection
appwrite databases createIndex 687765bf0013ce99c541 68777f59001dc82cdeea --key idx_sessions_user_completed --type key --attributes userId,completedAt
appwrite databases createIndex 687765bf0013ce99c541 68777f59001dc82cdeea --key idx_sessions_role_cat --type key --attributes jobRole,category
appwrite databases createIndex 687765bf0013ce99c541 68777f59001dc82cdeea --key idx_sessions_status --type key --attributes status
appwrite databases createIndex 687765bf0013ce99c541 68777f59001dc82cdeea --key idx_sessions_type --type key --attributes type

# Create indexes for Interviews collection
appwrite databases createIndex 687765bf0013ce99c541 68777f3d0018267de13f --key idx_interviews_user_completed --type key --attributes userId,completedAt
appwrite databases createIndex 687765bf0013ce99c541 68777f3d0018267de13f --key idx_interviews_role_cat --type key --attributes jobRole,category
appwrite databases createIndex 687765bf0013ce99c541 68777f3d0018267de13f --key idx_interviews_passed --type key --attributes passed
appwrite databases createIndex 687765bf0013ce99c541 68777f3d0018267de13f --key idx_interviews_percentage --type key --attributes percentage
```

### 3. Important Setup Notes

1. **Array Fields**: Enable "Array" option when creating string/integer attributes in Appwrite console
2. **JSON Fields**: Store as strings (`results`, `analytics`, `configuration`) and parse in application
3. **Enum Validation**: Handle validation in application layer (Appwrite doesn't support native enums)
4. **UUID Fields**: Use 36 characters for standard UUID format (8-4-4-4-12)
5. **DateTime Fields**: Appwrite automatically handles ISO 8601 timestamps
6. **Nullable Fields**: Mark fields like `score`, `completedAt`, `passed` as not required until completion

### 4. Attribute Creation Order

**Recommended order for creating attributes in Appwrite console:**

1. **Users Collection**:

   - `id` (String, 128, Required, Primary Key)
   - `name` (String, 100, Required)
   - `email` (Email, 255, Required)
   - `photoUrl` (URL, 500, Optional)
   - `totalInterviews` (Integer, Required, Default: 0)
   - `averageScore` (Float, Required, Default: 0.0)
   - `createdAt` (DateTime, Required)
   - `updatedAt` (DateTime, Required)
   - `provider` (String, 20, Required, Default: 'email')

2. **Questions Collection**:

   - `id` (Integer, Required, Auto-increment)
   - `question` (String, 1000, Required)
   - `options` (String, 100, Required, Array)
   - `correctAnswer` (String, 1, Required)
   - `explanation` (String, 2000, Required)
   - `difficulty` (String, 10, Required, Default: 'medium')
   - `category` (String, 20, Required, Default: 'general')
   - `topic` (String, 100, Required)
   - `jobRoles` (String, 50, Optional, Array)
   - `tags` (String, 30, Optional, Array)
   - `timeRecommended` (Integer, Required, Default: 30)
   - `createdAt` (DateTime, Required)
   - `updatedAt` (DateTime, Required)
   - `isActive` (Boolean, Required, Default: true)
   - `usageCount` (Integer, Required, Default: 0)
   - `successRate` (Float, Required, Default: 0.0)

3. **Sessions Collection**:

   - `sessionId` (String, 36, Required, Primary Key)
   - `userId` (String, 128, Required)
   - `jobRole` (String, 100, Required)
   - `type` (String, 10, Required, Default: 'mcq')
   - `difficulty` (String, 10, Required, Default: 'medium')
   - `category` (String, 20, Required, Default: 'general')
   - `totalQuestions` (Integer, Required, Default: 10)
   - `timePerQuestion` (Integer, Required, Default: 30)
   - `status` (String, 15, Required, Default: 'started')
   - `score` (Float, Optional)
   - `percentage` (Float, Optional)
   - `isComplete` (Boolean, Required, Default: false)
   - `passed` (Boolean, Optional)
   - `startedAt` (DateTime, Required)
   - `completedAt` (DateTime, Optional)
   - `duration` (Integer, Optional)
   - `questionIds` (Integer, Required, Array)
   - `configuration` (String, 500, Required)

4. **Interviews Collection**:
   - `interviewId` (String, 36, Required, Primary Key)
   - `sessionId` (String, 36, Required)
   - `userId` (String, 128, Required)
   - `jobRole` (String, 100, Required)
   - `category` (String, 20, Required)
   - `difficulty` (String, 10, Required)
   - `totalQuestions` (Integer, Required)
   - `correctAnswers` (Integer, Required)
   - `incorrectAnswers` (Integer, Required)
   - `skippedQuestions` (Integer, Required, Default: 0)
   - `finalScore` (Float, Required)
   - `percentage` (Float, Required)
   - `passed` (Boolean, Required)
   - `timeSpent` (Integer, Required)
   - `averageTimePerQuestion` (Float, Required)
   - `completedAt` (DateTime, Required)
   - `results` (String, 10000, Required)
   - `analytics` (String, 5000, Required)

## Migration Considerations

### Future Enhancements

- Voice interview support (already architected)
- Adaptive difficulty algorithms
- Real-time collaboration features
- Advanced analytics and reporting
- Offline capability with sync

### Scalability

- **Horizontal scaling**: Shard by user ID or date ranges
- **Data archival**: Cold storage for old interviews
- **Caching layer**: Redis for frequently accessed data
- **Read replicas**: For analytics workloads

---

This database design supports the current MCQ interview functionality while providing flexibility for future enhancements and maintaining optimal performance through strategic denormalization and indexing.
