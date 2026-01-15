// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) => UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      dailyGoal: json['dailyGoal'] as String?,
      learningStyle: json['learningStyle'] as String?,
      isOnboardingCompleted: json['isOnboardingCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'isEmailVerified': instance.isEmailVerified,
      'interests': instance.interests,
      'createdAt': instance.createdAt?.toIso8601String(),
      'dailyGoal': instance.dailyGoal,
      'learningStyle': instance.learningStyle,
      'isOnboardingCompleted': instance.isOnboardingCompleted,
    };
