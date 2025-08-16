const { app, BrowserWindow, ipcMain } = require('electron');

// Load the addon via package entry (handles platform paths)
const dragAddon = require('..');

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

  win.loadFile('renderer.html');

  win.webContents.openDevTools();

  ipcMain.on('start-drag', (event) => {
    const hwndBuffer = win.getNativeWindowHandle();
    // Linux: extract window id; macOS/Windows: pass the buffer
    const windowId = process.platform === 'linux' ? hwndBuffer.readUInt32LE(0) : hwndBuffer;
    dragAddon.startDrag(windowId);
  });
});
