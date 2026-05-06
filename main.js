const { app, BrowserWindow, ipcMain, screen } = require('electron')
const path = require('path')
const { spawn } = require('child_process')


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

  mainWindow.loadFile(path.join(__dirname, 'src/renderer/index.html'))
  if (process.env.NODE_ENV === 'development') {
    mainWindow.webContents.openDevTools()
  }

  mainWindow.on('closed', () => {
    mainWindow = null
  })
}


app.whenReady().then(() => {
  createWindow()

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow()
    }
  })
})


app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})


// ========== 鼠标控制功能（Python pynput） ==========

const pythonScript = path.join(__dirname, 'mouse_control.py')

function runPython(args) {
  return new Promise((resolve, reject) => {
    const proc = spawn('python3', [pythonScript, ...args])
    let stdout = ''
    let stderr = ''

    proc.stdout.on('data', (data) => {
      stdout += data.toString()
    })

    proc.stderr.on('data', (data) => {
      stderr += data.toString()
    })

    proc.on('close', (code) => {
      if (code === 0) {
        resolve(stdout.trim())
      } else {
        reject(new Error(stderr || `Python exited with code ${code}`))
      }
    })

    proc.on('error', (err) => {
      reject(err)
    })
  })
}

async function performClick(x, y, button) {
  try {
    await runPython(['click', x.toString(), y.toString(), button])
  } catch (e) {
    console.error('Click failed:', e.message)
  }
}


// ========== 鼠标点击事件处理 ==========


ipcMain.on('mouse-click', (event, data) => {
  const { x, y, button, interval, clickCount, infinite, points, isMultiMode } = data
  
  let count = 0
  let currentPointIndex = 0
  let running = true

  async function clickLoop() {
    while (running) {
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
        console.log(`Clicked at (${targetX}, ${targetY}) with ${button} button`)
        
        count++
        
        if (!infinite && count >= clickCount) {
          event.reply('click-finished')
          break
        }
        
        await new Promise(resolve => setTimeout(resolve, interval))
      } catch (error) {
        console.error('Click error:', error)
        event.reply('click-error', error.message)
        break
      }
    }
  }

  clickLoop()

  ipcMain.once('stop-click', () => {
    running = false
  })
})


// ========== 鼠标坐标获取 ==========


ipcMain.on('get-mouse-position', (event) => {
  // 使用 Electron 的 screen API 获取鼠标位置（最简单、最可靠）
  const mousePoint = screen.getCursorScreenPoint()
  event.reply('mouse-position', mousePoint)
})
