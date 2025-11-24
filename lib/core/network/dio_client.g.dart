// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DioClientService)
const dioClientServiceProvider = DioClientServiceProvider._();

final class DioClientServiceProvider
    extends $NotifierProvider<DioClientService, Dio> {
  const DioClientServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioClientServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioClientServiceHash();

  @$internal
  @override
  DioClientService create() => DioClientService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioClientServiceHash() => r'63cc069c9d89295e2363f4c4aadf9947ee30414e';

abstract class _$DioClientService extends $Notifier<Dio> {
  Dio build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Dio, Dio>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Dio, Dio>,
              Dio,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
