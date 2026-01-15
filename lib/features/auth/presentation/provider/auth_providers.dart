import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glypha/core/services/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

@riverpod
Future<bool> needsAdditionalDetails(
  Ref ref,
  String userId,
) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.needsAdditionalDetails(userId);
}
