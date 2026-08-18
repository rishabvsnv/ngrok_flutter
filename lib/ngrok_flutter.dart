library;

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'ngrok_flutter_bindings_generated.dart';

/// Headless controller for starting and managing Ngrok tunnels.
class NgrokFlutter {
  NgrokFlutter._();

  static final DynamicLibrary _dylib = () {
    if (Platform.isAndroid || Platform.isLinux) {
      return DynamicLibrary.open('libngrok_bridge.so');
    } else if (Platform.isWindows) {
      try {
        return DynamicLibrary.open('ngrok_bridge.dll');
      } catch (_) {
        return DynamicLibrary.open(
          '${Directory.current.path}/../rust/target/release/ngrok_bridge.dll',
        );
      }
    } else if (Platform.isMacOS || Platform.isIOS) {
      return DynamicLibrary.process();
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }();

  static final NgrokFlutterBindings _bindings = NgrokFlutterBindings(_dylib);

  /// Synchronous FFI bridge handler executed inside background isolate
  static String _startTunnelWorker(Map<String, String> params) {
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
          'Ngrok tunnel creation failed. Check authtoken validity, internet connection, and target port.',
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

  /// Starts an HTTP tunnel forwarding to [target] (e.g. `"8080"` or `"127.0.0.1:8080"`).
  ///
  /// Runs on a dedicated background isolate to avoid UI thread blocking.
  /// Returns the assigned public Ngrok URL (e.g. `https://xxxx.ngrok-free.app`).
  static Future<String> startTunnel({
    required String authtoken,
    required String target,
  }) async {
    return compute(_startTunnelWorker, {
      'authtoken': authtoken,
      'target': target,
    });
  }

  /// Stops and tears down the active Ngrok tunnel.
  static Future<bool> stopTunnel() async {
    return compute((_) => _bindings.ngrok_stop_tunnel(), null);
  }
}
