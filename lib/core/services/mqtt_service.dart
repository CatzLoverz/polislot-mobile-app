import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mqtt_service.g.dart';

@Riverpod(keepAlive: true)
class MqttService extends _$MqttService {
  MqttServerClient? _client;
  final StreamController<Map<String, dynamic>> _messageController = StreamController.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  @override
  void build() {
    Future.microtask(() => connect());
    ref.onDispose(() {
      _client?.disconnect();
      _messageController.close();
    });
  }

  Future<void> connect() async {
    if (_client != null && _client!.connectionStatus!.state == MqttConnectionState.connected) {
      return;
    }

    final host = dotenv.env['MQTT_HOST'] ?? '';
    final portStr = dotenv.env['MQTT_WSS_PORT'] ?? '9001';
    final username = dotenv.env['MQTT_USERNAME'] ?? '';
    final password = dotenv.env['MQTT_PASSWORD'] ?? '';

    if (host.isEmpty) {
      debugPrint('MQTT_HOST is empty, skipping connection');
      return;
    }

    final port = int.tryParse(portStr) ?? 9001;
    final clientId = 'polislot_mobile_${DateTime.now().millisecondsSinceEpoch}';

    // WSS Connection
    _client = MqttServerClient.withPort('wss://$host', clientId, port);
    _client!.useWebSocket = true;
    _client!.secure = true;
    _client!.logging(on: kDebugMode);
    _client!.keepAlivePeriod = 30;
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.onSubscribed = _onSubscribed;
    _client!.autoReconnect = true;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    
    if (username.isNotEmpty && password.isNotEmpty) {
      connMess.authenticateAs(username, password);
    }
    
    _client!.connectionMessage = connMess;

    try {
      debugPrint('Connecting to MQTT broker at wss://$host:$port...');
      await _client!.connect();
    } on NoConnectionException catch (e) {
      debugPrint('MQTT Client connection exception: $e');
      _client!.disconnect();
    } catch (e) {
      debugPrint('MQTT Client generic exception: $e');
      _client!.disconnect();
    }

    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint('MQTT Client successfully connected!');
      
      // Subscribe to all frontend parking areas
      const topic = 'frontend/parking_area/#';
      _client!.subscribe(topic, MqttQos.atLeastOnce);

      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        if (c == null || c.isEmpty) return;
        final recMess = c[0].payload as MqttPublishMessage;
        final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        try {
          final payload = jsonDecode(pt);
          payload['_topic'] = c[0].topic; // Include topic so listeners can filter
          _messageController.add(payload);
        } catch (e) {
          debugPrint('Error decoding MQTT message payload: $e');
        }
      });
    } else {
      debugPrint('ERROR: MQTT client connection failed - status is ${_client!.connectionStatus}');
      _client!.disconnect();
    }
  }

  void _onConnected() {
    debugPrint('MQTT Client _onConnected callback');
  }

  void _onDisconnected() {
    debugPrint('MQTT Client _onDisconnected callback');
  }

  void _onSubscribed(String topic) {
    debugPrint('MQTT Client Subscribed to topic: $topic');
  }
}
