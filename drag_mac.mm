#include "drag.h"

#ifdef __APPLE__
#import <Cocoa/Cocoa.h>

// Electron's getNativeWindowHandle returns a Buffer containing the NSWindow*.
// We can call -performWindowDragWithEvent: if we can synthesize/obtain an NSEvent.
// Since we are invoked from a mousedown handler on the renderer side typically,
// the actual NSEvent already occurred. We can trigger drag based on current mouse
// position by creating a leftMouseDragged event and calling performWindowDragWithEvent.

static NSEvent* CreateDragEvent(NSWindow* window) {
  // Use window-local mouse location for the synthetic event
  NSPoint local = [window mouseLocationOutsideOfEventStream];
  NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
  NSEvent* event = [NSEvent mouseEventWithType:NSEventTypeLeftMouseDown
                                       location:local
                                  modifierFlags:0
                                      timestamp:now
                                   windowNumber:window.windowNumber
                                        context:nil
                                    eventNumber:0
                                     clickCount:1
                                       pressure:1.0];
  return event;
}

Napi::Value StartDrag(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();
  if (info.Length() < 1 || !info[0].IsBuffer()) {
    Napi::TypeError::New(env, "Expected buffer as first argument").ThrowAsJavaScriptException();
    return env.Null();
  }

  auto buf = info[0].As<Napi::Buffer<char>>();
  // NSWindow* is pointer-sized
  if (buf.Length() < sizeof(void*)) {
    Napi::TypeError::New(env, "Invalid native handle buffer").ThrowAsJavaScriptException();
    return env.Null();
  }

  // Electron may return either NSWindow* or NSView* depending on version.
  // Read as Objective-C id and resolve window accordingly.
  id obj = *reinterpret_cast<id*>(buf.Data());
  if (!obj) {
    Napi::TypeError::New(env, "Null native pointer").ThrowAsJavaScriptException();
    return env.Null();
  }
  NSWindow* window = nil;
  if ([obj isKindOfClass:[NSWindow class]]) {
    window = (NSWindow*)obj;
  } else if ([obj isKindOfClass:[NSView class]]) {
    window = [(NSView*)obj window];
  }
  if (!window) {
    Napi::TypeError::New(env, "Could not resolve NSWindow from handle").ThrowAsJavaScriptException();
    return env.Null();
  }

  dispatch_async(dispatch_get_main_queue(), ^{
    @autoreleasepool {
      if ([window respondsToSelector:@selector(performWindowDragWithEvent:)]) {
        NSEvent* ev = CreateDragEvent(window);
        [window performWindowDragWithEvent:ev];
      } else {
        // Fallback: begin a standard window drag via performDrag
        // Not typically needed on modern macOS.
      }
    }
  });

  return env.Null();
}
#endif
