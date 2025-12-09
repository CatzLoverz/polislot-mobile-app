import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connection_status_provider.g.dart';

@Riverpod(keepAlive: true)
class ConnectionStatus extends _$ConnectionStatus {
  @override
  bool build() {
    return false; // Default: false (Dianggap Online/Tidak Offline)
  }

  void setOffline() => state = true;
  void setOnline() => state = false;
}