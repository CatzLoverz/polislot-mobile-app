// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProfileRepositoryInstance)
const profileRepositoryInstanceProvider = ProfileRepositoryInstanceProvider._();

final class ProfileRepositoryInstanceProvider
    extends $NotifierProvider<ProfileRepositoryInstance, ProfileRepository> {
  const ProfileRepositoryInstanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryInstanceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryInstanceHash();

  @$internal
  @override
  ProfileRepositoryInstance create() => ProfileRepositoryInstance();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryInstanceHash() =>
    r'89c8c65a52eb13e1cbd8f72baee337de41fd311a';

abstract class _$ProfileRepositoryInstance
    extends $Notifier<ProfileRepository> {
  ProfileRepository build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ProfileRepository, ProfileRepository>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProfileRepository, ProfileRepository>,
              ProfileRepository,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
