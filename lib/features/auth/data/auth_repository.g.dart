// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthRepositoryInstance)
const authRepositoryInstanceProvider = AuthRepositoryInstanceProvider._();

final class AuthRepositoryInstanceProvider
    extends $NotifierProvider<AuthRepositoryInstance, AuthRepository> {
  const AuthRepositoryInstanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryInstanceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryInstanceHash();

  @$internal
  @override
  AuthRepositoryInstance create() => AuthRepositoryInstance();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryInstanceHash() =>
    r'5fadd9a2384e176b8a1e449350483be8e8fd4e8e';

abstract class _$AuthRepositoryInstance extends $Notifier<AuthRepository> {
  AuthRepository build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AuthRepository, AuthRepository>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthRepository, AuthRepository>,
              AuthRepository,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
