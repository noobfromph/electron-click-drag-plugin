#include "drag.h"

Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set("startDrag", Napi::Function::New(env, StartDrag));
  return exports;
}

NODE_API_MODULE(drag, Init)
