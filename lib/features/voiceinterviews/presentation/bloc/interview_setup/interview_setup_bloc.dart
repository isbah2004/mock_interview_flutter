import 'package:bloc/bloc.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';

import 'interview_setup_event.dart';
import 'interview_setup_state.dart';

class InterviewSetupBloc
    extends Bloc<InterviewSetupEvent, InterviewSetupState> {
  InterviewConfig _config = const InterviewConfig(
    jobRole: '',
    category: InterviewCategory.general,
    difficulty: InterviewDifficulty.intermediate,
    numberOfQuestions: 5,
  );

  InterviewSetupBloc() : super(InterviewSetupInitial()) {
    on<UpdateJobRole>(_onUpdateJobRole);
    on<UpdateCategory>(_onUpdateCategory);
    on<UpdateDifficulty>(_onUpdateDifficulty);
    on<UpdateQuestionCount>(_onUpdateQuestionCount);
    on<StartInterview>(_onStartInterview);

    // Emit initial state
    add(UpdateJobRole(''));
  }

  void _onUpdateJobRole(
    UpdateJobRole event,
    Emitter<InterviewSetupState> emit,
  ) {
    _config = _config.copyWith(jobRole: event.jobRole);
    emit(InterviewSetupConfiguring(_config, _isConfigValid()));
  }

  void _onUpdateCategory(
    UpdateCategory event,
    Emitter<InterviewSetupState> emit,
  ) {
    _config = _config.copyWith(category: event.category);
    emit(InterviewSetupConfiguring(_config, _isConfigValid()));
  }

  void _onUpdateDifficulty(
    UpdateDifficulty event,
    Emitter<InterviewSetupState> emit,
  ) {
    _config = _config.copyWith(difficulty: event.difficulty);
    emit(InterviewSetupConfiguring(_config, _isConfigValid()));
  }

  void _onUpdateQuestionCount(
    UpdateQuestionCount event,
    Emitter<InterviewSetupState> emit,
  ) {
    _config = _config.copyWith(numberOfQuestions: event.count);
    emit(InterviewSetupConfiguring(_config, _isConfigValid()));
  }

  void _onStartInterview(
    StartInterview event,
    Emitter<InterviewSetupState> emit,
  ) {
    if (_isConfigValid()) {
      emit(InterviewSetupReady(_config));
    }
  }

  bool _isConfigValid() {
    return _config.jobRole.trim().isNotEmpty &&
        _config.numberOfQuestions > 0 &&
        _config.numberOfQuestions <= 10;
  }
}
