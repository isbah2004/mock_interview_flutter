import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/api_constants.dart';

class WebSocketClient {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;

  Stream<Map<String, dynamic>> connect(String endpoint) {
    _controller = StreamController<Map<String, dynamic>>.broadcast();

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('${ApiConstants.wsBaseUrl}$endpoint'),
      );

      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message as String);
          _controller!.add(data);
        },
        onError: (error) {
          _controller!.addError(error);
        },
        onDone: () {
          _controller!.close();
        },
      );
    } catch (e) {
      _controller!.addError(e);
    }

    return _controller!.stream;
  }

  void send(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void close() {
    _channel?.sink.close();
    _controller?.close();
  }
}
