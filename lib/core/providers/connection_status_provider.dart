import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connection_status_provider.g.dart';

enum ConnectionStateType { online, noInternet, serverUnreachable }

@Riverpod(keepAlive: true)
class ConnectionStatus extends _$ConnectionStatus {
  @override
  ConnectionStateType build() {
    return ConnectionStateType.online; 
  }

  void setNoInternet() => state = ConnectionStateType.noInternet;
  void setServerUnreachable() => state = ConnectionStateType.serverUnreachable;
  void setOnline() => state = ConnectionStateType.online;
}