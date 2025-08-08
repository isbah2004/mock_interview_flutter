# Appwrite Database Setup Guide - MCQ Interview System

## Database Configuration

**Database ID**: `687765bf0013ce99c541`

## Collection Attributes Setup

### 1. Users Collection

**Collection ID**: `68777f1300324ee21d1e`

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

**Indexes to Create**:

- `email` (Key: idx_users_email, Type: key, Attributes: [email])
- `createdAt` (Key: idx_users_created, Type: key, Attributes: [createdAt])

### 2. Questions Collection

**Collection ID**: `68777f4b0004adb16d79`

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
| `jobRoles`        | String   | 50          | ✅       | -         | ❌    | -                                                |
| `tags`            | String   | 30          | ❌       | -         | ✅    | -                                                |
| `timeRecommended` | Integer  | -           | ✅       | 30        | ❌    | -                                                |
| `createdAt`       | DateTime | -           | ✅       | -         | ❌    | -                                                |
| `updatedAt`       | DateTime | -           | ✅       | -         | ❌    | -                                                |
| `isActive`        | Boolean  | -           | ✅       | true      | ❌    | -                                                |
| `usageCount`      | Integer  | -           | ✅       | 0         | ❌    | -                                                |
| `successRate`     | Float    | -           | ✅       | 0.0       | ❌    | -                                                |

**Indexes to Create**:

- `difficulty_category` (Key: idx_questions_diff_cat, Type: key, Attributes: [difficulty, category])
- `category_topic` (Key: idx_questions_cat_topic, Type: key, Attributes: [category, topic])
- `isActive` (Key: idx_questions_active, Type: key, Attributes: [isActive])
- `jobRoles` (Key: idx_questions_roles, Type: fulltext, Attributes: [jobRoles])

### 3. Sessions Collection

**Collection ID**: `68777f59001dc82cdeea`

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

**Indexes to Create**:

- `userId_completedAt` (Key: idx_sessions_user_completed, Type: key, Attributes: [userId, completedAt])
- `jobRole_category` (Key: idx_sessions_role_cat, Type: key, Attributes: [jobRole, category])
- `status` (Key: idx_sessions_status, Type: key, Attributes: [status])
- `type` (Key: idx_sessions_type, Type: key, Attributes: [type])

### 4. Interviews Collection

**Collection ID**: `68777f3d0018267de13f`

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

**Indexes to Create**:

- `userId_completedAt` (Key: idx_interviews_user_completed, Type: key, Attributes: [userId, completedAt])
- `jobRole_category` (Key: idx_interviews_role_cat, Type: key, Attributes: [jobRole, category])
- `passed` (Key: idx_interviews_passed, Type: key, Attributes: [passed])
- `percentage` (Key: idx_interviews_percentage, Type: key, Attributes: [percentage])

## Field Size Explanations

### String Field Sizes:

1. **Small Text Fields (1-50 chars)**:

   - `correctAnswer`, `userAnswer`: 1 char (A, B, C, D) - stored in results JSON
   - `provider`: 20 chars (email, google, facebook)
   - `difficulty`: 10 chars (easy, medium, hard)
   - `category`: 20 chars (enough for longest enum)
   - `type`: 10 chars (mcq, voice)
   - `status`: 15 chars (longest: "in_progress")

2. **Medium Text Fields (50-500 chars)**:

   - `name`: 100 chars (user display names)
   - `jobRole`: 100 chars (job titles)
   - `topic`: 100 chars (question topics)
   - `jobRoles` (array): 50 chars each (multiple job roles)
   - `tags` (array): 30 chars each (categorization tags)
   - `options` (array): 100 chars each (question options)
   - `sessionId`, `interviewId`: 36 chars (UUID)
   - `userId`: 128 chars (Firebase UID)
   - `configuration`: 500 chars (JSON config object)

3. **Large Text Fields (500+ chars)**:
   - `photoUrl`: 500 chars (image URLs)
   - `question`: 1000 chars (question content)
   - `explanation`: 2000 chars (detailed explanations)
   - `results`: 10000 chars (JSON array of results)
   - `analytics`: 5000 chars (JSON analytics object)

### Numeric Field Ranges:

- **Integers**: Standard 32-bit integers

  - `totalInterviews`, `usageCount`: 0 to 2,147,483,647
  - `timeRecommended`, `timePerQuestion`: seconds (15-300)
  - `totalQuestions`: 1-50
  - `questionOrder`: 1-totalQuestions
  - `score`: 0-100 points per question
  - `timeSpent`, `duration`: seconds (0-3600)

- **Floats**: Standard precision
  - `averageScore`, `percentage`: 0.0-100.0
  - `finalScore`: calculated score
  - `successRate`: 0.0-1.0 (percentage as decimal)
  - `averageTimePerQuestion`: calculated average

## Setup Commands (Appwrite CLI)

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

## Important Notes

1. **Array Fields**: In Appwrite, arrays are created by enabling the "Array" option when creating string/integer attributes.

2. **JSON Fields**: Large JSON objects (`configuration`, `results`, `analytics`) are stored as strings and parsed in the application.

3. **Enum Validation**: Appwrite doesn't have native enum support, so validation should be handled in the application layer.

4. **UUID Fields**: Use 36 characters to accommodate standard UUID format (8-4-4-4-12).

5. **DateTime Fields**: Appwrite automatically handles ISO 8601 format timestamps.

6. **Required vs Optional**: Set based on business logic - some fields like `score` and `completedAt` are only available after completion.

7. **No Responses Collection**: Individual question responses are stored in the `results` JSON field of the Interviews collection for better performance and data consistency.

## Performance Tips

- **Indexes**: Create composite indexes for frequently used query combinations
- **Pagination**: Use limit and offset for large result sets
- **Caching**: Cache frequently accessed questions and user profiles
- **Batch Operations**: Use batch operations for creating multiple responses

This setup will provide optimal performance for your MCQ interview system while maintaining data integrity and query efficiency.
