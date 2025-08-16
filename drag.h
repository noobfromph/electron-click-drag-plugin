#pragma once
#include <napi.h>

// Starts an OS-level window drag for the given native handle/identifier.
// Windows: expects a Buffer containing HWND bytes from getNativeWindowHandle().
// Linux (X11): expects a Number window id (from first 4 bytes of the Buffer).
// macOS: expects a Buffer with NSWindow* from getNativeWindowHandle().
Napi::Value StartDrag(const Napi::CallbackInfo& info);

// Module initialization common to all platforms
Napi::Object Init(Napi::Env env, Napi::Object exports);
