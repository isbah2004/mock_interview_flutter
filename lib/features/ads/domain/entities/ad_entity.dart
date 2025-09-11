import 'package:equatable/equatable.dart';

enum AdState { initial, loading, loaded, showing, dismissed, failed }

class AdEntity extends Equatable {
  final String adUnitId;
  final AdState state;
  final String? errorMessage;

  const AdEntity({
    required this.adUnitId,
    required this.state,
    this.errorMessage,
  });

  AdEntity copyWith({String? adUnitId, AdState? state, String? errorMessage}) {
    return AdEntity(
      adUnitId: adUnitId ?? this.adUnitId,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [adUnitId, state, errorMessage];
}
