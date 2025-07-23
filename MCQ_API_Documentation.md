# MCQ Interview API Documentation

## Overview

The MCQ (Multiple Choice Questions) interview system now supports enhanced features including difficulty levels, question categories, and configurable session management.

## New Features

### 1. Difficulty Levels

- **Easy**: Basic concepts and fundamental knowledge
- **Medium**: Practical application and intermediate concepts
- **Hard**: Advanced scenarios and complex problem-solving

### 2. Question Categories

- **General**: Basic professional skills and workplace knowledge
- **Technical**: Job-specific technical skills and knowledge
- **Behavioral**: Soft skills, teamwork, problem-solving approach
- **Industry Specific**: Industry trends, standards, and practices

### 3. Number of Questions

- Supported values: 5, 10, 15, 20 questions per session

## API Endpoints

### Start MCQ Interview

```http
POST /api/v1/interview/start_interview
```

**Request Body:**

```json
{
  "user_id": "user123",
  "job_role": "Software Engineer",
  "interview_type": "mcq",
  "difficulty_level": "medium",
  "num_questions": 10,
  "category": "technical"
}
```

**Response:**

```json
{
  "question": "What is the time complexity of binary search?",
  "options": ["O(n)", "O(log n)", "O(n²)", "O(1)"],
  "question_id": "session-uuid",
  "current_question_number": 1,
  "total_questions": 10,
  "session_complete": false
}
```

### Submit Answer

```http
POST /api/v1/interview/submit_response
```

**Request Body:**

```json
{
  "user_id": "user123",
  "job_role": "Software Engineer",
  "interview_type": "mcq",
  "answer": "O(log n)",
  "question_id": "session-uuid"
}
```

**Response (Next Question):**

```json
{
  "question": "Next question text...",
  "options": ["Option A", "Option B", "Option C", "Option D"],
  "feedback": "Correct! Binary search divides the search space in half...",
  "score": 100.0,
  "question_id": "session-uuid",
  "current_question_number": 2,
  "total_questions": 10,
  "session_complete": false
}
```

**Response (Session Complete):**

```json
{
  "feedback": "Correct! Explanation...",
  "score": 100.0,
  "question_id": "session-uuid",
  "current_question_number": 10,
  "total_questions": 10,
  "session_complete": true,
  "final_score": 85.0
}
```

### Get Session Statistics

```http
GET /api/v1/interview/session_stats/{session_id}
```

**Response:**

```json
{
    "session_id": "session-uuid",
    "job_role": "Software Engineer",
    "difficulty": "medium",
    "category": "technical",
    "total_questions": 10,
    "completed_questions": 10,
    "is_complete": true,
    "scores": [100, 0, 100, 100, 0, 100, 100, 100, 0, 100],
    "average_score": 80.0,
    "answers": ["O(log n)", "Wrong answer", ...],
    "questions": [
        {
            "question": "What is the time complexity...",
            "correct_answer": "O(log n)"
        }
    ]
}
```

### Delete Session

```http
DELETE /api/v1/interview/session/{session_id}
```

## Usage Examples

### 1. Easy Technical Questions for Junior Developer

```json
{
  "user_id": "user123",
  "job_role": "Junior Developer",
  "interview_type": "mcq",
  "difficulty_level": "easy",
  "num_questions": 5,
  "category": "technical"
}
```

### 2. Hard Behavioral Questions for Senior Manager

```json
{
  "user_id": "user456",
  "job_role": "Senior Manager",
  "interview_type": "mcq",
  "difficulty_level": "hard",
  "num_questions": 15,
  "category": "behavioral"
}
```

### 3. Medium Industry-Specific Questions for Data Scientist

```json
{
  "user_id": "user789",
  "job_role": "Data Scientist",
  "interview_type": "mcq",
  "difficulty_level": "medium",
  "num_questions": 20,
  "category": "industry_specific"
}
```

## Session Management

- Sessions are automatically created when starting an interview
- All questions are pre-generated for better performance
- Sessions store progress and can be resumed
- Use the session statistics endpoint to get detailed results
- Delete sessions when no longer needed to free up memory

## Error Handling

- Invalid number of questions (not 5, 10, 15, or 20) returns 400 error
- Session not found returns 404 error
- LLM generation failures return 500 error with details
