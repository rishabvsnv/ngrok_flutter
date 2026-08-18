import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'ngrok_flutter_bindings_generated.dart';

class NgrokFlutter {
  static final DynamicLibrary _dylib = () {
    if (Platform.isWindows) {
      try {
        return DynamicLibrary.open('ngrok_flutter.dll');
      } catch (_) {
        return DynamicLibrary.open('rust/target/release/ngrok_bridge.dll');
      }
    } else if (Platform.isMacOS || Platform.isIOS) {
      return DynamicLibrary.process();
    } else {
      return DynamicLibrary.open('libngrok_bridge.so');
    }
  }();

  static final NgrokFlutterBindings _bindings = NgrokFlutterBindings(_dylib);

  /// Starts an HTTP tunnel forwarding to [localPort] using your Ngrok [authtoken].
  /// Returns the public tunnel URL (e.g. `https://xxxx.ngrok-free.app`).
  static Future<String> startTunnel({
    required String authtoken,
    required int localPort,
  }) async {
    final tokenNative = authtoken.toNativeUtf8();
    try {
      final urlPtr = _bindings.ngrok_start_tunnel(
        tokenNative.cast<Char>(),
        localPort,
      );

      if (urlPtr == nullptr) {
        throw Exception(
          'Failed to initialize Ngrok tunnel. Please check your authtoken and network connection.',
        );
      }

      final url = urlPtr.cast<Utf8>().toDartString();
      _bindings.ngrok_free_string(urlPtr);
      return url;
    } finally {
      malloc.free(tokenNative);
    }
  }
}
