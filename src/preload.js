const { contextBridge, ipcRenderer } = require('electron')

// 向渲染进程暴露IPC通信接口
contextBridge.exposeInMainWorld('electronAPI', {
  // 鼠标点击相关
  startClick: (data) => ipcRenderer.send('mouse-click', data),
  stopClick: () => ipcRenderer.send('stop-click'),
  onClickFinished: (callback) => ipcRenderer.on('click-finished', callback),
  onClickError: (callback) => ipcRenderer.on('click-error', callback),
  
  // 坐标拾取相关
  getMousePosition: () => {
    return new Promise((resolve) => {
      ipcRenderer.once('mouse-position', (event, position) => {
        resolve(position)
      })
      ipcRenderer.send('get-mouse-position')
    })
  }
})