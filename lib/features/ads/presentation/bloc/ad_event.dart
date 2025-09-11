// Events
import 'package:equatable/equatable.dart';

abstract class InterstitialAdEvent extends Equatable {
  const InterstitialAdEvent();

  @override
  List<Object> get props => [];
}

class InitializeAdsEvent extends InterstitialAdEvent {
  const InitializeAdsEvent();
}

class LoadInterstitialAdEvent extends InterstitialAdEvent {
  final String adUnitId;

  const LoadInterstitialAdEvent(this.adUnitId);

  @override
  List<Object> get props => [adUnitId];
}

class ShowInterstitialAdEvent extends InterstitialAdEvent {
  const ShowInterstitialAdEvent();
}
