cmake_minimum_required(VERSION 3.14)
project(ngrok_flutter LANGUAGES C)

set(RUST_RELEASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../rust/target/release")

# Define our plugin library
add_library(ngrok_flutter SHARED
  "${CMAKE_CURRENT_SOURCE_DIR}/ngrok_flutter.c"
)

# Link against the compiled Rust library
if (WIN32)
  target_link_libraries(ngrok_flutter PRIVATE "${RUST_RELEASE_DIR}/ngrok_bridge.dll.lib")
elseif (APPLE)
  target_link_libraries(ngrok_flutter PRIVATE "${RUST_RELEASE_DIR}/libngrok_bridge.dylib")
else()
  target_link_libraries(ngrok_flutter PRIVATE "${RUST_RELEASE_DIR}/libngrok_bridge.so")
endif()

target_include_directories(ngrok_flutter PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}"
)

# Export symbols
target_compile_definitions(ngrok_flutter PRIVATE DART_SHARED_LIB)