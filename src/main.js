import { app, BrowserWindow, Menu, ipcMain } from 'electron'
import { resolve } from 'path'

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
      nodeIntegration: true,
      contextIsolation: false,
      preload: resolve(__dirname, 'preload.js')
    }
  })

  // 加载渲染进程
  mainWindow.loadFile(resolve(__dirname, 'renderer/index.html'))

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
  
  // 导入robotjs库
  const robot = require('robotjs')
  
  let count = 0
  let currentPointIndex = 0
  let running = true
  
  // 点击循环
  const clickInterval = setInterval(() => {
    if (!running) {
      clearInterval(clickInterval)
      return
    }
    
    try {
      if (isMultiMode && points && points.length > 0) {
        const point = points[currentPointIndex]
        robot.moveMouse(point.x, point.y)
        robot.mouseClick(button)
        currentPointIndex = (currentPointIndex + 1) % points.length
      } else {
        robot.moveMouse(x, y)
        robot.mouseClick(button)
      }
      
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
  const robot = require('robotjs')
  const mousePos = robot.getMousePos()
  event.reply('mouse-position', mousePos)
})