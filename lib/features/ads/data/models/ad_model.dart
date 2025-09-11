import '../../domain/entities/ad_entity.dart';

class AdModel extends AdEntity {
  const AdModel({
    required super.adUnitId,
    required super.state,
    super.errorMessage,
  });

  factory AdModel.fromEntity(AdEntity entity) {
    return AdModel(
      adUnitId: entity.adUnitId,
      state: entity.state,
      errorMessage: entity.errorMessage,
    );
  }

  AdEntity toEntity() {
    return AdEntity(
      adUnitId: adUnitId,
      state: state,
      errorMessage: errorMessage,
    );
  }

  @override
  AdModel copyWith({String? adUnitId, AdState? state, String? errorMessage}) {
    return AdModel(
      adUnitId: adUnitId ?? this.adUnitId,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
