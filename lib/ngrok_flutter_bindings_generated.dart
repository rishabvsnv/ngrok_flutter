// AUTO GENERATED FILE, DO NOT EDIT.
// ignore_for_file: non_constant_identifier_names, unused_element, unused_field

import 'dart:ffi' as ffi;

class NgrokFlutterBindings {
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
  _lookup;

  NgrokFlutterBindings(ffi.DynamicLibrary dynamicLibrary)
    : _lookup = dynamicLibrary.lookup;

  NgrokFlutterBindings.fromLookup(
    ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName) lookup,
  ) : _lookup = lookup;

  ffi.Pointer<ffi.Char> ngrok_start_tunnel(
    ffi.Pointer<ffi.Char> authtoken,
    ffi.Pointer<ffi.Char> target_addr,
  ) {
    return _ngrok_start_tunnel(authtoken, target_addr);
  }

  late final _ngrok_start_tunnelPtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
            ffi.Pointer<ffi.Char>,
            ffi.Pointer<ffi.Char>,
          )
        >
      >('ngrok_start_tunnel');
  late final _ngrok_start_tunnel = _ngrok_start_tunnelPtr
      .asFunction<
        ffi.Pointer<ffi.Char> Function(
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>,
        )
      >();

  void ngrok_free_string(ffi.Pointer<ffi.Char> s) {
    return _ngrok_free_string(s);
  }

  late final _ngrok_free_stringPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>>(
        'ngrok_free_string',
      );
  late final _ngrok_free_string = _ngrok_free_stringPtr
      .asFunction<void Function(ffi.Pointer<ffi.Char>)>();

  bool ngrok_stop_tunnel() {
    return _ngrok_stop_tunnel();
  }

  late final _ngrok_stop_tunnelPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function()>>('ngrok_stop_tunnel');
  late final _ngrok_stop_tunnel = _ngrok_stop_tunnelPtr
      .asFunction<bool Function()>();
}
