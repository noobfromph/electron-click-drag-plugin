# electron-click-drag-plugin
A native Node.js addon that enables elements to be both draggable and clickable in Electron / Overwolf Electron.
Useful when -webkit-app-region: drag disables click events, but you still want OS-level window dragging.

## 📦 Installation
Install the prebuilt binary from npm (recommended):

```bash
npm install electron-click-drag-plugin
```
## 🛠 Build from source
If you prefer or need to compile yourself (e.g., for a different Electron version):

```bash
npm install node-addon-api electron --save
npx node-gyp configure
npx node-gyp build
```
This will compile the native addon into ./build/Release/drag.node.

### 🚀 Usage
In your Electron preload or main process:

```js
const { app, BrowserWindow, ipcMain } = require('electron');
const dragAddon = require('electron-click-drag-plugin'); // Loads the native addon

app.whenReady().then(() => {
  const win = new BrowserWindow({
    width: 800,
    height: 800,
    frame: false, // Important: no OS window frame
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false, // only for test/dev
      devTools: true
    },
  });

  win.loadFile('index.html');
  win.webContents.openDevTools();

  ipcMain.on('start-drag', () => {
    try {
      const hwndBuffer = win.getNativeWindowHandle();
      // Linux: extract X11 Window ID from the buffer (first 4 bytes, little-endian)
      // macOS/Windows: pass Buffer directly
      const windowId = process.platform === 'linux'
        ? hwndBuffer.readUInt32LE(0)
        : hwndBuffer;

      dragAddon.startDrag(windowId);
    } catch (error) {
      console.error(error);
    }
  });
});
```
### ✅ Tested On
Windows 10 / 11, Linux (Fedora), macOS (15.6 M1)

Standard Electron (>= v22)

### 📜 License
MIT