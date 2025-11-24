// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_ui_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProfileSection)
const profileSectionProvider = ProfileSectionProvider._();

final class ProfileSectionProvider
    extends $NotifierProvider<ProfileSection, int> {
  const ProfileSectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileSectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileSectionHash();

  @$internal
  @override
  ProfileSection create() => ProfileSection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$profileSectionHash() => r'b7358941297a7cbd1bddb63a73848dfb3839d468';

abstract class _$ProfileSection extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
