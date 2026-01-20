// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
      xp: (json['xp'] as num).toInt(),
      streak: (json['streak'] as num).toInt(),
      energy: (json['energy'] as num).toDouble(),
      lastEnergyUpdate:
          UserStats._timestampToDateTime(json['lastEnergyUpdate']),
    );

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
      'xp': instance.xp,
      'streak': instance.streak,
      'energy': instance.energy,
      'lastEnergyUpdate':
          UserStats._dateTimeToTimestamp(instance.lastEnergyUpdate),
    };
