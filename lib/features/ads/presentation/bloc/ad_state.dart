// States
import 'package:equatable/equatable.dart';
import 'package:mock_interview/features/ads/domain/entities/ad_entity.dart';

abstract class InterstitialAdState extends Equatable {
  const InterstitialAdState();

  @override
  List<Object?> get props => [];
}

class InterstitialAdInitial extends InterstitialAdState {
  const InterstitialAdInitial();
}

class InterstitialAdInitialized extends InterstitialAdState {
  const InterstitialAdInitialized();
}

class InterstitialAdLoading extends InterstitialAdState {
  const InterstitialAdLoading();
}

class InterstitialAdLoaded extends InterstitialAdState {
  final AdEntity ad;

  const InterstitialAdLoaded(this.ad);

  @override
  List<Object> get props => [ad];
}

class InterstitialAdShown extends InterstitialAdState {
  const InterstitialAdShown();
}

class InterstitialAdError extends InterstitialAdState {
  final String message;
  final AdEntity? ad;

  const InterstitialAdError(this.message, [this.ad]);

  @override
  List<Object?> get props => [message, ad];
}

class InterstitialAdImpression extends InterstitialAdState {
  final AdEntity ad;

  const InterstitialAdImpression(this.ad);

  @override
  List<Object> get props => [ad];
}
