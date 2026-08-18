#ifndef NGROK_FLUTTER_H_
#define NGROK_FLUTTER_H_

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

// Starts an ngrok HTTP tunnel forwarding to `local_port`.
// Returns an allocated C-string containing the public URL (or NULL on failure).
FFI_PLUGIN_EXPORT char* ngrok_start_tunnel(const char* authtoken, int local_port);

// Frees the memory allocated for the URL string returned by `ngrok_start_tunnel`.
FFI_PLUGIN_EXPORT void ngrok_free_string(char* s);

#ifdef __cplusplus
}
#endif

#endif // NGROK_FLUTTER_H_