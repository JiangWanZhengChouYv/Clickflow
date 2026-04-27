const { app, BrowserWindow, ipcMain } = require('electron')
const path = require('path')

// 确保应用是单实例运行
const gotTheLock = app.requestSingleInstanceLock()
if (!gotTheLock) {
  app.quit()
}

let mainWindow

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 500,
    height: 750,
    minWidth: 450,
    minHeight: 700,
    title: 'Clickflow',
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    }
  })

  // 加载渲染进程
  mainWindow.loadFile(path.join(__dirname, 'src/renderer/index.html'))

  // 开发环境下打开开发者工具
  if (process.env.NODE_ENV === 'development') {
    mainWindow.webContents.openDevTools()
  }

  // 窗口关闭事件
  mainWindow.on('closed', () => {
    mainWindow = null
  })
}

// 应用准备就绪时创建窗口
app.whenReady().then(() => {
  createWindow()

  // macOS下，点击 dock 图标重新创建窗口
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow()
    }
  })
})

// 关闭所有窗口时退出应用（Windows和Linux）
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

// 处理鼠标点击事件
ipcMain.on('mouse-click', (event, data) => {
  const { x, y, button, interval, clickCount, infinite, points, isMultiMode } = data
  
  let count = 0
  let currentPointIndex = 0
  let running = true
  
  // 模拟点击循环（实际项目中需要使用系统API实现）
  const clickInterval = setInterval(() => {
    if (!running) {
      clearInterval(clickInterval)
      return
    }
    
    try {
      let targetX = x
      let targetY = y
      
      if (isMultiMode && points && points.length > 0) {
        const point = points[currentPointIndex]
        targetX = point.x
        targetY = point.y
        currentPointIndex = (currentPointIndex + 1) % points.length
      }
      
      console.log(`点击位置: (${targetX}, ${targetY})，按钮: ${button}`)
      
      count++
      
      if (!infinite && count >= clickCount) {
        clearInterval(clickInterval)
        event.reply('click-finished')
      }
    } catch (error) {
      console.error('点击出错:', error)
      clearInterval(clickInterval)
      event.reply('click-error', error.message)
    }
  }, interval)
  
  // 监听停止事件
  ipcMain.once('stop-click', () => {
    running = false
  })
})

// 处理坐标拾取事件
ipcMain.on('get-mouse-position', (event) => {
  // 使用Electron的屏幕API获取鼠标位置
  const { screen } = require('electron')
  const mousePos = screen.getCursorScreenPoint()
  event.reply('mouse-position', mousePos)
})