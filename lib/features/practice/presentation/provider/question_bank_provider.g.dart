// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_bank_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$questionBankRepositoryHash() =>
    r'd735b5d38a3e8c9fd265097a62f9c0227b30360a';

/// See also [questionBankRepository].
@ProviderFor(questionBankRepository)
final questionBankRepositoryProvider =
    AutoDisposeProvider<QuestionBankRepository>.internal(
  questionBankRepository,
  name: r'questionBankRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$questionBankRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QuestionBankRepositoryRef
    = AutoDisposeProviderRef<QuestionBankRepository>;
String _$userQuestionBanksHash() => r'b581b82babd6e7685b00fb56d6b44c3923253562';

/// See also [userQuestionBanks].
@ProviderFor(userQuestionBanks)
final userQuestionBanksProvider =
    AutoDisposeStreamProvider<List<QuestionBank>>.internal(
  userQuestionBanks,
  name: r'userQuestionBanksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userQuestionBanksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserQuestionBanksRef = AutoDisposeStreamProviderRef<List<QuestionBank>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
