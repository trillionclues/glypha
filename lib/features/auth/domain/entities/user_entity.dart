import 'package:json_annotation/json_annotation.dart';

part 'user_entity.g.dart';

@JsonSerializable()
class UserEntity {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;

  // Additional details from onboarding
  final List<String>? interests;
  final DateTime? createdAt;
  final String? dailyGoal;
  final String? learningStyle;
  final bool isOnboardingCompleted;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
    this.interests,
    this.createdAt,
    this.dailyGoal,
    this.learningStyle,
    this.isOnboardingCompleted = false,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);
  Map<String, dynamic> toJson() => _$UserEntityToJson(this);
}
