// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$levelListHash() => r'5a46bc8ca43e6eba9fc6f14f1a2458eb9d66b518';

/// See also [levelList].
@ProviderFor(levelList)
final levelListProvider =
    AutoDisposeFutureProvider<List<VirtualLevel>>.internal(
  levelList,
  name: r'levelListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$levelListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LevelListRef = AutoDisposeFutureProviderRef<List<VirtualLevel>>;
String _$virtualLevelHash() => r'2e8f723e8874f77c2845650f801684004492bf35';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [virtualLevel].
@ProviderFor(virtualLevel)
const virtualLevelProvider = VirtualLevelFamily();

/// See also [virtualLevel].
class VirtualLevelFamily extends Family<AsyncValue<VirtualLevel?>> {
  /// See also [virtualLevel].
  const VirtualLevelFamily();

  /// See also [virtualLevel].
  VirtualLevelProvider call(
    String levelId,
  ) {
    return VirtualLevelProvider(
      levelId,
    );
  }

  @override
  VirtualLevelProvider getProviderOverride(
    covariant VirtualLevelProvider provider,
  ) {
    return call(
      provider.levelId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'virtualLevelProvider';
}

/// See also [virtualLevel].
class VirtualLevelProvider extends AutoDisposeFutureProvider<VirtualLevel?> {
  /// See also [virtualLevel].
  VirtualLevelProvider(
    String levelId,
  ) : this._internal(
          (ref) => virtualLevel(
            ref as VirtualLevelRef,
            levelId,
          ),
          from: virtualLevelProvider,
          name: r'virtualLevelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$virtualLevelHash,
          dependencies: VirtualLevelFamily._dependencies,
          allTransitiveDependencies:
              VirtualLevelFamily._allTransitiveDependencies,
          levelId: levelId,
        );

  VirtualLevelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.levelId,
  }) : super.internal();

  final String levelId;

  @override
  Override overrideWith(
    FutureOr<VirtualLevel?> Function(VirtualLevelRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VirtualLevelProvider._internal(
        (ref) => create(ref as VirtualLevelRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        levelId: levelId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<VirtualLevel?> createElement() {
    return _VirtualLevelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VirtualLevelProvider && other.levelId == levelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, levelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VirtualLevelRef on AutoDisposeFutureProviderRef<VirtualLevel?> {
  /// The parameter `levelId` of this provider.
  String get levelId;
}

class _VirtualLevelProviderElement
    extends AutoDisposeFutureProviderElement<VirtualLevel?>
    with VirtualLevelRef {
  _VirtualLevelProviderElement(super.provider);

  @override
  String get levelId => (origin as VirtualLevelProvider).levelId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
