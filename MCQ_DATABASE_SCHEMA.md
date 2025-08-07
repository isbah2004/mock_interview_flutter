# MCQ Interview Database Schema Design

## Overview

This document outlines the database schema design for the MCQ (Multiple Choice Questions) interview system in the Mock Interview Flutter application. The schema is designed to support comprehensive MCQ interview functionality with user management, question banks, session tracking, and detailed analytics.

## Database Technology

- **Primary Database**: Appwrite (NoSQL Document Database)
- **Authentication**: Firebase Auth
- **Storage**: Appwrite Storage (for profile images and audio recordings)

## Collections Schema

### 1. Users Collection (`usersCollection`)

**Collection ID**: `68777f1300324ee21d1e`

Stores authenticated user information and profile data.

```json
{
  "id": "string (Primary Key - Firebase UID)",
  "name": "string (Display name)",
  "email": "string (Email address)",
  "photoUrl": "string (Profile image URL)",
  "totalInterviews": "integer (Count of completed interviews)",
  "averageScore": "float (Average score across all interviews)",
  "createdAt": "string (ISO 8601 timestamp)",
  "updatedAt": "string (ISO 8601 timestamp)",
  "provider": "string (auth provider: 'email', 'google', 'facebook')"
}
```

**Indexes**:

- Primary: `id`
- Secondary: `email`, `createdAt`

### 2. Questions Collection (`questionsCollection`)

**Collection ID**: `68777f4b0004adb16d79`

Central repository for all MCQ questions used in interviews.

```json
{
  "id": "integer (Auto-increment Primary Key)",
  "question": "string (Question text)",
  "options": "array<string> (4 options: A, B, C, D)",
  "correctAnswer": "string (Correct option letter)",
  "explanation": "string (Detailed explanation)",
  "difficulty": "string (enum: 'easy', 'medium', 'hard')",
  "category": "string (enum: 'general', 'technical', 'behavioral', 'industrySpecific')",
  "topic": "string (Specific topic/skill area)",
  "jobRoles": "array<string> (Applicable job roles)",
  "tags": "array<string> (Additional categorization)",
  "timeRecommended": "integer (Recommended time in seconds)",
  "createdAt": "string (ISO 8601 timestamp)",
  "updatedAt": "string (ISO 8601 timestamp)",
  "isActive": "boolean (Question availability status)",
  "usageCount": "integer (How many times used)",
  "successRate": "float (Percentage of correct answers)"
}
```

**Indexes**:

- Primary: `id`
- Composite: `difficulty + category`, `category + topic`
- Secondary: `jobRoles`, `tags`, `isActive`

### 3. Sessions Collection (`sessionsCollection`)

**Collection ID**: `68777f59001dc82cdeea`

Tracks individual interview sessions and their metadata.

```json
{
  "sessionId": "string (Primary Key - UUID)",
  "userId": "string (Foreign Key - Users.id)",
  "jobRole": "string (Target job role)",
  "type": "string (Interview type: 'mcq', 'voice')",
  "difficulty": "string (enum: 'easy', 'medium', 'hard')",
  "category": "string (enum: 'general', 'technical', 'behavioral', 'industrySpecific')",
  "totalQuestions": "integer (Number of questions)",
  "timePerQuestion": "integer (Time limit per question in seconds)",
  "status": "string (enum: 'started', 'in_progress', 'completed', 'abandoned')",
  "score": "float (Final score - null until completion)",
  "percentage": "float (Score percentage)",
  "isComplete": "boolean (Completion status)",
  "passed": "boolean (Pass/fail status)",
  "startedAt": "string (ISO 8601 timestamp)",
  "completedAt": "string (ISO 8601 timestamp - null if not completed)",
  "duration": "integer (Total session duration in seconds)",
  "questionIds": "array<integer> (IDs of questions used)",
  "configuration": {
    "timePerQuestion": "integer",
    "totalQuestions": "integer",
    "passingScore": "float"
  }
}
```

**Indexes**:

- Primary: `sessionId`
- Composite: `userId + completedAt`, `jobRole + category`
- Secondary: `status`, `isComplete`, `type`

### 4. Responses Collection (`responsesCollection`)

**Collection ID**: `68777f530031b34d058d`

Stores individual question responses within interview sessions.

```json
{
  "responseId": "string (Primary Key - UUID)",
  "sessionId": "string (Foreign Key - Sessions.sessionId)",
  "userId": "string (Foreign Key - Users.id)",
  "questionId": "integer (Foreign Key - Questions.id)",
  "questionOrder": "integer (Order in the session)",
  "userAnswer": "string (Selected option: A, B, C, D)",
  "correctAnswer": "string (Correct option: A, B, C, D)",
  "isCorrect": "boolean (Answer correctness)",
  "score": "integer (Points awarded)",
  "timeSpent": "integer (Time spent on question in seconds)",
  "answeredAt": "string (ISO 8601 timestamp)",
  "explanation": "string (Explanation shown after answer)",
  "questionText": "string (Snapshot of question text)",
  "optionsSnapshot": "array<string> (Snapshot of options)"
}
```

**Indexes**:

- Primary: `responseId`
- Composite: `sessionId + questionOrder`, `userId + answeredAt`
- Secondary: `questionId`, `isCorrect`

### 5. Interviews Collection (`interviewsCollection`)

**Collection ID**: `68777f3d0018267de13f`

Aggregated interview results and analytics (denormalized for performance).

```json
{
  "interviewId": "string (Primary Key - UUID)",
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
  "timeSpent": "integer (Total time in seconds)",
  "averageTimePerQuestion": "float",
  "completedAt": "string (ISO 8601 timestamp)",
  "results": "array<object> (Summary of each question result)",
  "analytics": {
    "categoryBreakdown": "object (Score by category)",
    "difficultyBreakdown": "object (Score by difficulty)",
    "topicBreakdown": "object (Score by topic)",
    "timeAnalysis": "object (Time spent analysis)"
  }
}
```

**Indexes**:

- Primary: `interviewId`
- Composite: `userId + completedAt`, `jobRole + category`
- Secondary: `passed`, `percentage`

## Relationships

### Entity Relationship Diagram

```
Users (1) ←→ (N) Sessions
Sessions (1) ←→ (N) Responses
Questions (1) ←→ (N) Responses
Sessions (1) ←→ (1) Interviews
Users (1) ←→ (N) Interviews
```

### Key Relationships

1. **User → Sessions**: One user can have multiple interview sessions
2. **Session → Responses**: One session contains multiple question responses
3. **Question → Responses**: One question can be answered in multiple sessions
4. **Session → Interview**: One session produces one interview result
5. **User → Interviews**: One user can have multiple completed interviews

## Data Flow

### MCQ Interview Process

1. **Session Creation**:

   ```
   User starts MCQ → Create Session record → Generate question set → Update questionIds
   ```

2. **Question Response**:

   ```
   User answers question → Create Response record → Update session progress
   ```

3. **Interview Completion**:
   ```
   All questions answered → Calculate scores → Create Interview record → Update User stats
   ```

## Query Patterns

### Common Queries

1. **Get User's Interview History**:

   ```javascript
   // Get all completed interviews for a user
   Query.equal("userId", userId),
     Query.equal("passed", true),
     Query.orderDesc("completedAt");
   ```

2. **Get Session Details**:

   ```javascript
   // Get session with all responses
   Query.equal("sessionId", sessionId), Query.orderAsc("questionOrder");
   ```

3. **Question Bank Filtering**:

   ```javascript
   // Get questions by criteria
   Query.equal("difficulty", "medium"),
     Query.equal("category", "technical"),
     Query.equal("isActive", true);
   ```

4. **Analytics Queries**:
   ```javascript
   // Get user performance analytics
   Query.equal("userId", userId),
     Query.greaterThanEqual("completedAt", startDate),
     Query.lessThanEqual("completedAt", endDate);
   ```

## Performance Considerations

### Indexing Strategy

- **Primary Indexes**: All primary keys auto-indexed
- **Composite Indexes**: For multi-field queries (userId + date ranges)
- **Selective Indexes**: Only on frequently queried fields

### Data Optimization

- **Denormalization**: Interview collection stores computed results
- **Snapshots**: Response collection stores question/option snapshots
- **Pagination**: Large result sets use cursor-based pagination
- **Caching**: Frequently accessed questions cached client-side

## Security Rules

### Appwrite Permissions

1. **Users Collection**:

   - Read: User can read their own profile
   - Write: User can update their own profile
   - Admin: Full access for user management

2. **Questions Collection**:

   - Read: All authenticated users
   - Write: Admin only
   - Public: No access

3. **Sessions Collection**:

   - Read: User can read their own sessions
   - Write: User can create/update their own sessions
   - Admin: Full access

4. **Responses Collection**:

   - Read: User can read their own responses
   - Write: User can create their own responses
   - Admin: Full access

5. **Interviews Collection**:
   - Read: User can read their own interviews
   - Write: System-generated only
   - Admin: Full access

## Data Validation

### Field Validations

1. **Enum Validations**:

   - `difficulty`: ['easy', 'medium', 'hard']
   - `category`: ['general', 'technical', 'behavioral', 'industrySpecific']
   - `status`: ['started', 'in_progress', 'completed', 'abandoned']

2. **Range Validations**:

   - `score`: 0.0 - 100.0
   - `timeSpent`: > 0
   - `questionOrder`: 1 - totalQuestions

3. **Required Fields**:
   - All primary keys
   - User identification fields
   - Timestamp fields

## Backup and Migration

### Backup Strategy

- **Daily Snapshots**: Full database backup
- **Real-time Replication**: For critical collections
- **Export Capability**: JSON export for data portability

### Migration Considerations

- **Schema Versioning**: Track schema changes
- **Backward Compatibility**: Support old app versions
- **Data Transformation**: Handle enum value changes

## Analytics and Reporting

### Built-in Analytics

- User performance trends
- Question difficulty analysis
- Category-wise performance
- Time-based analytics

### Custom Reports

- Interview completion rates
- Popular job roles
- Question effectiveness metrics
- User engagement patterns

## Scalability Considerations

### Horizontal Scaling

- **Sharding Strategy**: By user ID or date ranges
- **Read Replicas**: For analytics workloads
- **Caching Layer**: Redis for frequently accessed data

### Data Archival

- **Cold Storage**: Old completed interviews
- **Data Retention**: Configurable retention policies
- **Cleanup Jobs**: Automated data lifecycle management

## Future Enhancements

### Potential Schema Extensions

1. **Question Variations**: Multiple versions of same question
2. **Adaptive Testing**: Dynamic difficulty adjustment
3. **Team Interviews**: Multi-user session support
4. **Custom Question Sets**: User-created question banks
5. **Video Questions**: Multimedia question support

### Integration Points

- **ML Analytics**: Question recommendation engine
- **External APIs**: Job market integration
- **Reporting Tools**: Business intelligence integration
- **Mobile Optimization**: Offline capability support

---

_This schema design supports the current MCQ interview functionality while providing flexibility for future enhancements and scalability requirements._
