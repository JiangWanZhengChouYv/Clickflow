const { app, BrowserWindow, ipcMain } = require('electron')
const path = require('path')
const { spawn } = require('child_process')
const fs = require('fs')

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
  const pythonScriptPath = path.join(__dirname, 'src', 'electron_mouse_controller.py')
  
  // 执行鼠标点击（带回退方案）
  const performClick = (targetX, targetY, targetButton) => {
    return new Promise((resolve) => {
      // 先尝试 Python 脚本
      const pythonProcess = spawn('python3', [pythonScriptPath, 'click', targetX.toString(), targetY.toString(), targetButton])
      
      let pythonSuccess = false
      
      pythonProcess.on('close', (code) => {
        if (code === 0) {
          pythonSuccess = true
          resolve()
        }
      })
      
      pythonProcess.on('error', (err) => {
        console.log('Python 脚本执行失败，使用回退方案:', err)
        if (!pythonSuccess) {
          // 简单的日志回退方案
          console.log(`[模拟点击] 位置: (${targetX}, ${targetY}), 按钮: ${targetButton}`)
          resolve()
        }
      })
      
      // 超时回退
      setTimeout(() => {
        if (!pythonSuccess) {
          console.log(`[模拟点击] 位置: (${targetX}, ${targetY}), 按钮: ${targetButton}`)
          pythonSuccess = true
          resolve()
        }
      }, 100)
    })
  }
  
  // 点击循环
  const clickInterval = setInterval(async () => {
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
      
      await performClick(targetX, targetY, button)
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
  const pythonScriptPath = path.join(__dirname, 'src', 'electron_mouse_controller.py')
  const pythonProcess = spawn('python3', [pythonScriptPath, 'get_position'])
  
  let output = ''
  let success = false
  
  pythonProcess.stdout.on('data', (data) => {
    output += data.toString()
  })
  
  pythonProcess.on('close', (code) => {
    if (code === 0) {
      try {
        const pos = JSON.parse(output)
        event.reply('mouse-position', pos)
        success = true
      } catch (error) {
        // 如果解析失败，使用 Electron 的默认 API
        const { screen } = require('electron')
        const mousePos = screen.getCursorScreenPoint()
        event.reply('mouse-position', mousePos)
      }
    } else {
      // 如果 Python 脚本失败，使用 Electron 的默认 API
      const { screen } = require('electron')
      const mousePos = screen.getCursorScreenPoint()
      event.reply('mouse-position', mousePos)
    }
  })
  
  // 超时回退
  setTimeout(() => {
    if (!success) {
      const { screen } = require('electron')
      const mousePos = screen.getCursorScreenPoint()
      event.reply('mouse-position', mousePos)
    }
  }, 100)
})
