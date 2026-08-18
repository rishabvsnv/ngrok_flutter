#ifndef NGROK_FLUTTER_H_
#define NGROK_FLUTTER_H_

#if defined(_WIN32)
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

FFI_PLUGIN_EXPORT char* ngrok_start_tunnel(const char* authtoken, const char* target_addr);
FFI_PLUGIN_EXPORT void ngrok_free_string(char* s);

#ifdef __cplusplus
}
#endif

#endif // NGROK_FLUTTER_H_