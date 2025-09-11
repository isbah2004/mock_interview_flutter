# Voice Interview Feature — Architecture & Flow

Last updated: 2025-09-11

This document explains the complete voice interview feature in the mock_interview project, from services (data layer) through domain/use-cases, to presentation (UI and navigation). It is written for developers who need a deep understanding of the implementation and the runtime flow.

## Table of contents

- Overview
- High-level sequence (user -> UI -> BLoC -> UseCases -> Services -> DB -> UI)
- Data layer: services and APIs
  - Gemini AI service and VoiceInterviewService
  - OpenRouterApiService (AI API adapter)
  - Database service
  - Speech service
- Domain layer: entities, models, use cases
  - InterviewConfig, InterviewSession, InterviewMessage
  - VoiceEvaluationModel
  - UseCases (SendResponseUseCase, HandleSpeechUseCase)
- Presentation layer
  - Setup view (`voice_interview_setup_view.dart`)
  - Interview view (`voice_interview_view.dart`)
  - Result view (`interview_result_view.dart`)
- BLoC: `VoiceInterviewBloc` — events, states, and handlers
- Full request/response flow (detailed step-by-step)
- Error handling, retries, and fallbacks
- Persistence and telemetry
- Edge cases and testing checklist
- Files & symbols map
- Troubleshooting & recommended improvements

## Overview

The voice interview feature provides an interactive mock interview experience where an AI interviewer (Gemini/OpenRouter) asks a sequence of questions to a user. The user answers by voice; answers are transcribed, appended to the interview session, and used by the AI to generate the next question and brief feedback. After the configured number of questions (or manual end), the entire conversation is evaluated by the AI and an evaluation record is stored and shown to the user.

## High-level sequence

1. User configures interview in setup view and starts session.
2. Presentation creates an `InterviewSession` and dispatches an initialization event to `VoiceInterviewBloc`.
3. Bloc manages listening/speaking cycles, delegates speech recognition to `HandleSpeechUseCase` (speech service), and asks AI for the next question using `SendResponseUseCase`.
4. The AI generates an AI message (question + brief feedback). Bloc appends messages to the session and triggers TTS to speak the AI message.
5. User answers; speech is transcribed and appended as a user message.
6. Repeat until question count reached or user triggers manual completion.
7. On completion, Bloc calls `SendResponseUseCase.evaluateInterview()` which uses the AI evaluation service to produce scores, feedback, and ideal answers.
8. Bloc saves `VoiceEvaluationModel` via the DB service, updates user stats, and emits `VoiceInterviewEvaluated` state.
9. The view listens for the evaluated state and navigates to `InterviewResultView` with evaluation details.

## Data layer: services and APIs

Gemini AI / VoiceInterviewService

- Location: `lib/core/services/gemini_ai_service/voice_interview_service.dart`
- Responsibilities:
  - Build prompts (system prompt + conversation) for the AI.
  - Call the underlying API adapter (`OpenRouterApiService`) to get generated text.
  - Parse AI evaluation responses into structured maps (communicationScore, contentScore, overallScore, percentageScore, feedback, correctAnswers).
  - Provide robust retry logic with exponential backoff for transient failures (503 handling).
  - Create fallback evaluation results when parsing fails or on timeouts.
- Important behaviors:
  - It logs API call metrics and tracks 503 errors to drive monitoring.
  - It expects the session object with `messages` and `currentQuestionNumber` to compute questionCount.

GeminiAiService façade

- Location: `lib/core/services/gemini_ai_service/gemini_ai_service.dart`
- Responsibilities:
  - Provide higher-level helpers: `evaluateVoiceInterview(session, config)`, `sendVoiceMessage()` etc.
  - Delegates to the appropriate subservices (voice interview, mcq generation/evaluation).
  - Consolidates metrics and error stats across subservices.

OpenRouterApiService (AI API adapter)

- Location: `lib/core/services/openrouter_api_service.dart` (or similar)
- Responsibilities:
  - Perform HTTP requests to the AI provider.
  - Expose simple functions like `generateText({prompt, maxTokens, temperature})`.
  - Handle API-level retry, rate limit parsing, and error mapping.

Database service

- Typical functions called by the Bloc:
  - `storeVoiceEvaluation(VoiceEvaluationModel)`
  - `storeVoiceMessage(VoiceMessageModel)`
  - `updateInterviewSession(UnifiedInterviewSession)`
- Role:
  - Persist evaluation results and conversation messages separately to allow smaller evaluation documents and message collections.

Speech service

- Location: `lib/core/services/flutter_speech_service.dart` (or similar)
- Responsibilities:
  - Start/stop listening; provide partial + final transcripts.
  - Integrate with `HandleSpeechUseCase` for a simplified interface to BLoC.

## Domain layer: entities, models, use cases

Entities & Models

- `InterviewConfig` (lib/features/voiceinterviews/domain/entities/interview_config.dart)

  - jobRole: String
  - category: InterviewCategory (enum)
  - difficulty: InterviewDifficulty (enum)
  - numberOfQuestions: int

- `InterviewSession` (lib/features/voiceinterviews/domain/entities/interview_session.dart)

  - config: InterviewConfig
  - messages: List<InterviewMessage>
  - currentQuestionNumber: int
  - status: InterviewStatus
  - helpers: `isCompleted` (currentQuestionNumber > numberOfQuestions), `progress`

- `InterviewMessage` (lib/features/voiceinterviews/domain/entities/interview_message.dart)

  - type: MessageType (ai|user)
  - content: String
  - timestamp: DateTime

- `VoiceEvaluationModel` (lib/core/models/voice_evaluation_model.dart)
  - evaluationId, sessionId, feedback, communicationScore, contentScore, overallScore,
    aiCorrectAnswers (List<String>), totalQuestions, finalScore, percentage, passed, sessionComplete, completedAt

Use Cases

- `SendResponseUseCase` (lib/features/voiceinterviews/domain/usecases/send_response_usecase.dart)

  - `call(String userResponse)`: sends the user response to AI service and returns AI message text.
  - `evaluateInterview(InterviewSession session, InterviewConfig config)`: delegates to GeminiAiService to evaluate the whole session.

- `HandleSpeechUseCase` (lib/features/voiceinterviews/domain/usecases/handle_speech_usecase.dart)
  - Wraps speech service calls (startListening, stopListening), converts platform-specific results to domain-friendly events.

## Presentation layer

1. `VoiceInterviewSetupView`

   - Lets the user choose job role, category, difficulty, and number of questions.
   - On start, constructs `InterviewConfig`, initializes `InterviewSession`, and navigates to `VoiceInterviewView`.

2. `VoiceInterviewView` (lib/features/voiceinterviews/presentation/view/voice_interview_view.dart)

   - UI shows current AI question, listening state, transcript, progress, and an "End Interview" button.
   - Uses a `BlocProvider` and `BlocConsumer<VoiceInterviewBloc, VoiceInterviewState>`.
   - Listener handles navigation for `VoiceInterviewEvaluated` state and error states.
   - The "End Interview" dialog triggers `CompleteInterview()` event.
   - When AI responses come back, the view triggers TTS (text-to-speech) for the AI message (via `SpeakResponse` event).

3. `InterviewResultView` (lib/features/voiceinterviews/presentation/view/interview_result_view.dart)
   - Receives evaluation data (scores, feedback, ideal answers).
   - Displays overall score, communication/content breakdown, and written feedback.
   - Shows option to review recorded messages if stored.

## BLoC: VoiceInterviewBloc

Events (non-exhaustive):

- `InitializeInterview` - sets up session state
- `StartInterviewSetup` - user begins setup
- `SendUserResponse` - user response available (string)
- `StartListening` / `StopListening` / `UpdateListeningText` - speech control
- `SpeakResponse` / `CompleteSpeaking` - TTS control
- `CompleteInterview` - user or auto triggers interview end
- `StartEvaluation` / `RetryEvaluation` - explicit evaluation control
- `ResetInterviewState` - reset

States (non-exhaustive):

- `VoiceInterviewInitial`
- `VoiceInterviewReady` - session in progress
- `VoiceInterviewEvaluating` - waiting on AI evaluation
- `VoiceInterviewEvaluated` - evaluation complete, contains `VoiceInterviewEvaluationResult`
- `VoiceInterviewError`

Key handlers

- `_onSendUserResponse`

  - Append user message to session
  - Call `SendResponseUseCase.call(userResponse)` to get AI reply
  - Append AI message and add `SpeakResponse` to play it
  - Check if question limit reached; if yes, `add(CompleteInterview())`

- `_onCompleteInterview`
  - Emit `VoiceInterviewEvaluating`
  - If messages empty -> create performance fallback evaluation
  - Else call `SendResponseUseCase.evaluateInterview(session, session.config)` with timeout (2 minutes)
  - Map evaluation response to typed `VoiceInterviewEvaluationResult`
  - Save `VoiceEvaluationModel` and conversation messages via DB service
  - Update user stats via user stats service
  - Emit `VoiceInterviewEvaluated`

## Full runtime flow (detailed)

1. Setup: User selects config -> `InterviewConfig` created -> navigation to `VoiceInterviewView` with new `InterviewSession`.

2. First AI question generation: Either controller seeds initial AI prompt or `VoiceInterviewBloc` triggers `SendResponseUseCase.call('')` to ask the first question.

3. AI response arrives (question + brief feedback): `VoiceInterviewBloc` appends AI message to session and emits `VoiceInterviewReady` with updated session.

4. The view calls `StartListening` (user presses mic) -> `HandleSpeechUseCase` starts platform listener.

5. Speech transcription arrives as `UpdateListeningText` events (partial results); final transcript triggers `SendUserResponse`.

6. `_onSendUserResponse` appends the user message and calls `SendResponseUseCase.call(userResponse)`; the AI generates the next question and short feedback.

7. The view plays the AI message via TTS. Loop repeats until question count reached.

8. When `currentQuestionNumber >= config.numberOfQuestions` (or user triggers `CompleteInterview`):

   - Bloc emits `VoiceInterviewEvaluating` and calls `SendResponseUseCase.evaluateInterview()`.
   - The Gemini/VoiceInterviewService builds an evaluation prompt combining the full conversation and asks the AI for structured evaluation.
   - The response is parsed into scores, feedback, and an array of `correctAnswers` (ideal answers per question).
   - If parsing fails or AI returns empty, a fallback evaluation is generated based on participation.

9. The Bloc converts evaluation map into `VoiceInterviewEvaluationResult`/`VoiceEvaluationModel`, saves it, stores messages, updates user stats, and emits `VoiceInterviewEvaluated`.

10. The view's `BlocConsumer` listener sees `VoiceInterviewEvaluated` and navigates to `InterviewResultView` with the evaluation data.

## Error handling, retries, and fallbacks

- VoiceInterviewService has `_retryApiCall()` with exponential backoff (configurable `maxRetries`, `baseDelay`). It increments internal 503 counters and logs errors for monitoring.
- `evaluateInterview()` treats empty response, parse errors, timeouts, 503, 429, and 401 specially. Timeouts and parse errors fall back to `_createFallbackEvaluationResult()`.
- The Bloc wraps evaluation calls in a `.timeout(Duration(minutes:2), onTimeout: () => fallback)` to avoid hanging the UI.
- Database save errors are logged and surfaced as `VoiceInterviewError` when saving evaluation fails.

## Persistence and telemetry

- Evaluations are persisted as `VoiceEvaluationModel` (Appwrite or other DB) and conversation messages are stored as separate `VoiceMessageModel` entries.
- User stats are updated after evaluation via `UserStatsService` (e.g., increment totals, recompute averages).
- GeminiAiService and subservices record metrics (total API calls, 503 errors, successfulRetries). `GeminiAiService.logErrorStats()` aggregates and prints or pushes metrics to monitoring.

## Edge cases and testing checklist

- [ ] Empty conversation (user never answered): ensure fallback evaluation is informative.
- [ ] Partial transcripts (speech recognition partial results): ensure final transcript replaces partials and only final triggers `SendUserResponse`.
- [ ] API rate-limit (429): ensure user-facing message suggests retry.
- [ ] API transient errors (503): verify exponential backoff and eventual fallback if retry fails.
- [ ] Large conversation: ensure evaluation prompt size stays within provider token limits. Consider truncating early AI messages or summarizing conversation.
- [ ] Concurrency: ensure only one evaluation request runs at a time per session.
- [ ] Permissions: microphone permission flow on supported platforms.

Test cases (unit + integration):

- Unit: prompt builder produces expected system prompt from `InterviewConfig`.
- Unit: response parsing correctly extracts scores and correct answers from sample AI output.
- Integration: simulate entire flow with mocked AI service and verify `VoiceInterviewEvaluated` emitted and DB save called.
- End-to-end: run app and manually test the flow on device/emulator with microphone.

## Files & symbols map (main files referenced)

- lib/features/voiceinterviews/presentation/view/voice_interview_setup_view.dart — setup UI
- lib/features/voiceinterviews/presentation/view/voice_interview_view.dart — main interview UI and BlocConsumer
- lib/features/voiceinterviews/presentation/view/interview_result_view.dart — result UI
- lib/features/voiceinterviews/presentation/bloc/voice_interview_bloc.dart — Bloc for voice interview
- lib/features/voiceinterviews/domain/usecases/send_response_usecase.dart
- lib/features/voiceinterviews/domain/usecases/handle_speech_usecase.dart
- lib/features/voiceinterviews/domain/entities/interview_config.dart
- lib/features/voiceinterviews/domain/entities/interview_session.dart
- lib/core/services/gemini_ai_service/voice_interview_service.dart
- lib/core/services/gemini_ai_service/gemini_ai_service.dart
- lib/core/models/voice_evaluation_model.dart
- lib/core/services/openrouter_api_service.dart (AI adapter)
- lib/core/services/flutter_speech_service.dart (speech)
- lib/core/services/unified_database_service.dart (database abstraction)

## Troubleshooting & recommended improvements

1. Token limits: Implement conversation summarization before evaluation if prompt length exceeds provider limits.
2. UI feedback: show progress indicator during evaluation and a cancel option for evaluation (with safe fallback behavior).
3. Offline mode: queue messages locally and evaluate when network is available, with a clear UX for "evaluation pending".
4. Telemetry: push metrics to a service (Prometheus/Datadog) instead of purely logging.
5. Caching: cache common interview prompts or templates to reduce prompt construction cost.
6. Tests: add unit tests for `_parseEvaluationResponse()` and integration tests for BLoC with mocked services.

## Appendix: Example prompt schematic

System prompt (simplified):

"You are a professional job interviewer conducting a mock interview for a [JOB] position. You will ask exactly [N] questions, one at a time. After each answer, provide brief constructive feedback before moving to the next question. After the final question provide comprehensive feedback and an overall score out of 10 for communication, content and an overall assessment. Return structured sections labeled COMMUNICATION_SCORE, CONTENT_SCORE, OVERALL_SCORE, FEEDBACK, IDEAL_ANSWERS: (IDEAL_ANSWER_1, IDEAL_ANSWER_2...)."

Conversation appended as:

- AI: Question 1
- User: [transcribed answer]
- AI: Brief feedback
- AI: Question 2
- ...

Evaluation expected output (AI-generated) (simplified):

COMMUNICATION_SCORE: 7
CONTENT_SCORE: 8
OVERALL_SCORE: 7.5
FEEDBACK: "..."
IDEAL_ANSWER_1: "..."
IDEAL_ANSWER_2: "..."

## Contact & next steps

- If you'd like, I can also:
  - Generate unit tests that mock the AI service and validate the Bloc flows.
  - Create a sequence diagram image and include it in the PDF.
  - Run automated integration tests with a mocked OpenRouter API.

---

Generated by an assistant; file: `docs/voice_interview_architecture.md`
