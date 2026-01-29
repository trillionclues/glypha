// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_record_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scanRecordRepositoryHash() =>
    r'a6ba3f24c962f02637ed6aaeb56795b17d7c93e8';

/// See also [scanRecordRepository].
@ProviderFor(scanRecordRepository)
final scanRecordRepositoryProvider =
    AutoDisposeProvider<ScanRecordRepository>.internal(
  scanRecordRepository,
  name: r'scanRecordRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scanRecordRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScanRecordRepositoryRef = AutoDisposeProviderRef<ScanRecordRepository>;
String _$userScansHash() => r'ac4e3985b1ade4b5ff7137de8e399c6a6808825f';

/// See also [userScans].
@ProviderFor(userScans)
final userScansProvider = AutoDisposeStreamProvider<List<ScanRecord>>.internal(
  userScans,
  name: r'userScansProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userScansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserScansRef = AutoDisposeStreamProviderRef<List<ScanRecord>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
