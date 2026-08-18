import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'ngrok_flutter_bindings_generated.dart';

class NgrokFlutter {
  static final DynamicLibrary _dylib = () {
    if (Platform.isWindows) {
      try {
        return DynamicLibrary.open('ngrok_bridge.dll');
      } catch (_) {
        return DynamicLibrary.open(
          '${Directory.current.path}/../rust/target/release/ngrok_bridge.dll',
        );
      }
    } else if (Platform.isMacOS || Platform.isIOS) {
      return DynamicLibrary.process();
    } else {
      return DynamicLibrary.open('libngrok_bridge.so');
    }
  }();

  static final NgrokFlutterBindings _bindings = NgrokFlutterBindings(_dylib);

  /// Synchronous low-level FFI call
  static String _startTunnelSync(Map<String, String> params) {
    final authtoken = params['authtoken']!;
    final target = params['target']!;

    final tokenNative = authtoken.toNativeUtf8();
    final targetNative = target.toNativeUtf8();
    try {
      final urlPtr = _bindings.ngrok_start_tunnel(
        tokenNative.cast<Char>(),
        targetNative.cast<Char>(),
      );

      if (urlPtr == nullptr) {
        throw Exception(
          'Failed to initialize Ngrok tunnel. Verify your authtoken, local server status, and internet connection.',
        );
      }

      final url = urlPtr.cast<Utf8>().toDartString();
      _bindings.ngrok_free_string(urlPtr);
      return url;
    } finally {
      malloc.free(tokenNative);
      malloc.free(targetNative);
    }
  }

  /// Starts an HTTP tunnel forwarding to [target] (e.g. `8080`, `127.0.0.1:8080`, or `192.168.1.51:8080`).
  /// Runs on a background isolate to keep UI smooth.
  static Future<String> startTunnel({
    required String authtoken,
    required String target,
  }) async {
    return compute(_startTunnelSync, {
      'authtoken': authtoken,
      'target': target,
    });
  }

  /// Stops the active Ngrok tunnel.
  static Future<bool> stopTunnel() async {
    return compute((_) => _bindings.ngrok_stop_tunnel(), null);
  }
}
