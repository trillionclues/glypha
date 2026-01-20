// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progression_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$progressionStreamHash() => r'08b99f338006b9f19682f53651248c1eec8a2fe6';

/// See also [progressionStream].
@ProviderFor(progressionStream)
final progressionStreamProvider =
    AutoDisposeStreamProvider<List<LevelProgression>>.internal(
  progressionStream,
  name: r'progressionStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$progressionStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProgressionStreamRef
    = AutoDisposeStreamProviderRef<List<LevelProgression>>;
String _$progressionMapHash() => r'a227f58327d2bfdff763ce12635bba4a69a2a9f3';

/// See also [progressionMap].
@ProviderFor(progressionMap)
final progressionMapProvider =
    AutoDisposeProvider<Map<String, LevelProgression>>.internal(
  progressionMap,
  name: r'progressionMapProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$progressionMapHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProgressionMapRef
    = AutoDisposeProviderRef<Map<String, LevelProgression>>;
String _$progressionNotifierHash() =>
    r'ff498e7dc93d378c022d39f049a8c83ef159ca39';

/// See also [ProgressionNotifier].
@ProviderFor(ProgressionNotifier)
final progressionNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ProgressionNotifier, void>.internal(
  ProgressionNotifier.new,
  name: r'progressionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$progressionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProgressionNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
