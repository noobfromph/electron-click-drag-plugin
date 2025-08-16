#include "drag.h"

#if !defined(_WIN32) && !defined(__APPLE__)
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <unistd.h>

Napi::Value StartDrag(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();

  if (info.Length() < 1) {
    Napi::TypeError::New(env, "Expected window id as first argument").ThrowAsJavaScriptException();
    return env.Null();
  }

  Display* display = XOpenDisplay(NULL);
  if (!display) {
    Napi::TypeError::New(env, "Cannot open X display").ThrowAsJavaScriptException();
    return env.Null();
  }

  Window window = (Window)info[0].As<Napi::Number>().Int64Value();

  Window root, child;
  int root_x, root_y, win_x, win_y;
  unsigned int mask;
  XQueryPointer(display, window, &root, &child, &root_x, &root_y, &win_x, &win_y, &mask);

  Atom moveAtom = XInternAtom(display, "_NET_WM_MOVERESIZE", False);
  if (moveAtom == None) {
    XCloseDisplay(display);
    Napi::TypeError::New(env, "Cannot find _NET_WM_MOVERESIZE atom").ThrowAsJavaScriptException();
    return env.Null();
  }

  XEvent xev = {0};
  xev.xclient.type = ClientMessage;
  xev.xclient.window = window;
  xev.xclient.message_type = moveAtom;
  xev.xclient.format = 32;
  xev.xclient.data.l[0] = root_x;
  xev.xclient.data.l[1] = root_y;
  xev.xclient.data.l[2] = 8; // _NET_WM_MOVERESIZE_MOVE
  xev.xclient.data.l[3] = 1; // button 1
  xev.xclient.data.l[4] = 0;

  XSendEvent(display, DefaultRootWindow(display), False,
             SubstructureRedirectMask | SubstructureNotifyMask, &xev);

  XFlush(display);
  XCloseDisplay(display);

  return env.Null();
}
#endif
