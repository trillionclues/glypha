import 'package:json_annotation/json_annotation.dart';

enum GameType {
  @JsonValue('runner')
  runner,
  @JsonValue('swipe')
  swipe,
  @JsonValue('stack')
  stack,
  @JsonValue('match')
  match,
}
