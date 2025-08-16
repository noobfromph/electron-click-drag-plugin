{
  "targets": [
    {
      "target_name": "drag",
      "sources": [
        "drag_common.cc",
        "drag_win.cc",
        "drag_linux.cc"
      ],
      "include_dirs": [
        "<!(node -p \"require('node-addon-api').include_dir\")",
        "<!(node -p \"require('node-addon-api').include\")"
      ],
      "defines": [ "NAPI_DISABLE_CPP_EXCEPTIONS" ],
      "cflags_cc!": [ "-fno-exceptions" ],
      "conditions": [
        [ "OS=='win'", {
          "libraries": [ "user32.lib" ]
        }],
        [ "OS=='mac'", {
          "sources": [ "drag_mac.mm" ],
          "xcode_settings": {
            "OTHER_CPLUSPLUSFLAGS": [ "-ObjC++" ]
          },
          "link_settings": {
            "libraries": [ "-framework", "Cocoa" ]
          }
        }]
      ]
    }
  ]
}
