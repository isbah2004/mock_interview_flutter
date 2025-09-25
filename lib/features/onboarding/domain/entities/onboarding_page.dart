import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class OnboardingPage extends Equatable {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final String? animation; // For future lottie animations if needed
  final String? imagePath; // For custom images

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    this.animation,
    this.imagePath,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    icon,
    iconColor,
    animation,
    imagePath,
  ];
}
