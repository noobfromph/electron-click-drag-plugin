const path = require('path');
const os = require('os');

const platform = os.platform();
const arch = os.arch();

// Prefer prebuilt binaries when available; fallback to local build
const prebuilt = {
  'win32-x64': 'build/Release/win32-x64/drag.node',
  'linux-x64': 'build/Release/linux-x64/drag.node',
  'darwin-x64': 'build/Release/darwin-x64/drag.node',
  'darwin-arm64': 'build/Release/darwin-arm64/drag.node',
};

const key = `${platform}-${arch}`;
let binaryPath = prebuilt[key] ? path.join(__dirname, prebuilt[key]) : null;

try {
  module.exports = require(binaryPath || path.join(__dirname, 'build/Release/drag.node'));
} catch (e) {
  // Fallback to generic build path if prebuilt missing
  module.exports = require(path.join(__dirname, 'build/Release/drag.node'));
}
