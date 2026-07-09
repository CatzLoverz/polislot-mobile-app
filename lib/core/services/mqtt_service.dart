import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mqtt_service.g.dart';

/// Status koneksi MQTT — digunakan sebagai state notifier agar UI reaktif.
enum MqttConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

@Riverpod(keepAlive: true)
class MqttService extends _$MqttService {
  MqttServerClient? _client;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();
  bool _disposed = false;
  Timer? _reconnectTimer;

  /// Stream pesan MQTT yang diterima (untuk didengarkan oleh controller).
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  @override
  MqttConnectionStatus build() {
    _disposed = false;
    Future.microtask(() => _connect());
    ref.onDispose(() {
      _disposed = true;
      _reconnectTimer?.cancel();
      _client?.disconnect();
      if (!_messageController.isClosed) {
        _messageController.close();
      }
    });
    return MqttConnectionStatus.disconnected;
  }

  /// Melakukan koneksi ke MQTT broker via WebSocket Secure (WSS).
  /// Menggunakan MqttServerClient dengan useWebSocket = true untuk platform mobile (Android/iOS).
  Future<void> _connect() async {
    if (_disposed) return;
    if (state == MqttConnectionStatus.connecting ||
        state == MqttConnectionStatus.connected) {
      return;
    }

    final host = dotenv.env['MQTT_HOST'] ?? '';
    final portStr = dotenv.env['MQTT_PORT'] ?? '443';
    final username = dotenv.env['MQTT_USERNAME'] ?? '';
    final password = dotenv.env['MQTT_PASSWORD'] ?? '';
    final scheme = dotenv.env['MQTT_SCHEME'] ?? 'wss';

    if (host.isEmpty) {
      debugPrint('[MQTT] MQTT_HOST kosong, koneksi dibatalkan.');
      return;
    }

    final port = int.tryParse(portStr) ?? 443;
    final clientId =
        'polislot_mobile_${DateTime.now().millisecondsSinceEpoch}';

    // MqttServerClient untuk Android/iOS dengan WebSocket (ws:// atau wss://)
    final wsUrl = '$scheme://$host/mqtt';
    _client = MqttServerClient.withPort(wsUrl, clientId, port)
      ..useWebSocket = true
      ..logging(on: kDebugMode)
      ..keepAlivePeriod = 30
      ..websocketProtocols = MqttClientConstants.protocolsSingleDefault
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..onSubscribed = _onSubscribed
      ..autoReconnect = false; // Dikelola manual agar listener dapat di-attach ulang


    // Build pesan koneksi dengan auth — HARUS di-chain (bukan dipanggil terpisah)
    MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    if (username.isNotEmpty && password.isNotEmpty) {
      connMess = connMess.authenticateAs(username, password);
    }

    _client!.connectionMessage = connMess;

    // Update state ke connecting (memicu rebuild UI indikator status)
    state = MqttConnectionStatus.connecting;

    try {
      debugPrint('[MQTT] Menghubungkan ke $wsUrl:$port ...');
      await _client!.connect();
    } on NoConnectionException catch (e) {
      debugPrint('[MQTT] NoConnectionException: $e');
      state = MqttConnectionStatus.error;
      _scheduleReconnect();
      return;
    } catch (e) {
      debugPrint('[MQTT] Exception saat koneksi: $e');
      state = MqttConnectionStatus.error;
      _scheduleReconnect();
      return;
    }

    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      debugPrint('[MQTT] Berhasil terhubung!');
      state = MqttConnectionStatus.connected;
      _subscribeAndListen();
    } else {
      debugPrint(
          '[MQTT] Gagal terhubung. Status: ${_client?.connectionStatus}');
      state = MqttConnectionStatus.error;
      _client?.disconnect();
      _scheduleReconnect();
    }
  }

  /// Subscribe ke topic wildcard dan mulai mendengarkan pesan masuk.
  void _subscribeAndListen() {
    if (_client == null) return;

    const topic = 'frontend/parking_area/#';
    _client!.subscribe(topic, MqttQos.atLeastOnce);
    debugPrint('[MQTT] Berlangganan ke topic: $topic');

    _client!.updates?.listen(
      (List<MqttReceivedMessage<MqttMessage?>>? incoming) {
        if (incoming == null || incoming.isEmpty) return;

        for (final msg in incoming) {
          final recMess = msg.payload as MqttPublishMessage;
          final payloadStr = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message,
          );

          debugPrint('[MQTT] Pesan dari "${msg.topic}": $payloadStr');

          try {
            final decoded = jsonDecode(payloadStr);
            if (decoded is Map<String, dynamic>) {
              // Sertakan topic agar controller dapat memfilter berdasarkan area
              decoded['_topic'] = msg.topic;
              if (!_messageController.isClosed) {
                _messageController.add(Map<String, dynamic>.from(decoded));
              }
            }
          } catch (e) {
            debugPrint('[MQTT] Gagal decode payload JSON: $e');
          }
        }
      },
      onError: (e) {
        debugPrint('[MQTT] Error pada stream updates: $e');
      },
    );
  }

  /// Menjadwalkan reconnect setelah delay tertentu.
  void _scheduleReconnect({Duration delay = const Duration(seconds: 5)}) {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (!_disposed) {
        debugPrint('[MQTT] Mencoba reconnect...');
        state = MqttConnectionStatus.disconnected;
        _connect();
      }
    });
  }

  void _onConnected() {
    debugPrint('[MQTT] _onConnected callback dipanggil.');
  }

  void _onDisconnected() {
    debugPrint('[MQTT] Terputus dari broker MQTT.');
    if (!_disposed) {
      state = MqttConnectionStatus.disconnected;
      _scheduleReconnect(delay: const Duration(seconds: 5));
    }
  }

  void _onSubscribed(String topic) {
    debugPrint('[MQTT] Berlangganan ke: $topic');
  }

  /// Memaksa koneksi ulang secara manual (dipanggil saat app kembali ke foreground).
  Future<void> reconnect() async {
    _reconnectTimer?.cancel();
    _client?.disconnect();
    state = MqttConnectionStatus.disconnected;
    await _connect();
  }
}
