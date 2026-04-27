// 全局变量
let points = [];
let isRunning = false;
let isPaused = false;

// DOM元素
const elements = {
  // 模式选择
  modeSingle: document.querySelector('input[name="mode"][value="single"]'),
  modeMulti: document.querySelector('input[name="mode"][value="multi"]'),
  
  // 坐标输入
  xInput: document.getElementById('x-input'),
  yInput: document.getElementById('y-input'),
  pickButton: document.getElementById('pick-button'),
  
  // 点位操作
  addPointButton: document.getElementById('add-point-button'),
  editPointButton: document.getElementById('edit-point-button'),
  deletePointButton: document.getElementById('delete-point-button'),
  clearPointsButton: document.getElementById('clear-points-button'),
  pointList: document.getElementById('point-list'),
  
  // 时间设置
  intervalInput: document.getElementById('interval-input'),
  clickCountInput: document.getElementById('click-count-input'),
  infiniteCheckbox: document.getElementById('infinite-checkbox'),
  
  // 鼠标按键
  buttonLeft: document.querySelector('input[name="button"][value="left"]'),
  buttonRight: document.querySelector('input[name="button"][value="right"]'),
  
  // 控制按钮
  startButton: document.getElementById('start-button'),
  pauseButton: document.getElementById('pause-button'),
  stopButton: document.getElementById('stop-button'),
  
  // 状态
  statusIndicator: document.getElementById('status-indicator'),
  statusText: document.getElementById('status-text')
};

// 初始化事件监听
function initEventListeners() {
  // 坐标拾取
  elements.pickButton.addEventListener('click', pickCoordinate);
  
  // 点位操作
  elements.addPointButton.addEventListener('click', addPoint);
  elements.editPointButton.addEventListener('click', editPoint);
  elements.deletePointButton.addEventListener('click', deletePoint);
  elements.clearPointsButton.addEventListener('click', clearPoints);
  
  // 控制按钮
  elements.startButton.addEventListener('click', startClick);
  elements.pauseButton.addEventListener('click', togglePause);
  elements.stopButton.addEventListener('click', stopClick);
  
  // 点位列表点击
  elements.pointList.addEventListener('click', handlePointClick);
  
  // 全局快捷键
  document.addEventListener('keydown', handleKeydown);
  
  // 初始化IPC事件监听
  initIpcListeners();
}

// 初始化IPC事件监听
function initIpcListeners() {
  // 点击完成事件
  window.electronAPI.onClickFinished(() => {
    updateStatus('就绪');
    updateControlButtons(false);
    isRunning = false;
  });
  
  // 点击错误事件
  window.electronAPI.onClickError((event, error) => {
    updateStatus(`错误: ${error}`);
    updateControlButtons(false);
    isRunning = false;
  });
}

// 坐标拾取
async function pickCoordinate() {
  try {
    const position = await window.electronAPI.getMousePosition();
    elements.xInput.value = position.x;
    elements.yInput.value = position.y;
  } catch (error) {
    console.error('坐标拾取失败:', error);
  }
}

// 添加点位
function addPoint() {
  if (points.length >= 3) {
    alert('最多只能添加3个点位');
    return;
  }
  
  const x = parseInt(elements.xInput.value) || 0;
  const y = parseInt(elements.yInput.value) || 0;
  
  points.push({ x, y });
  updatePointList();
}

// 编辑点位
function editPoint() {
  const selectedIndex = getSelectedPointIndex();
  if (selectedIndex === -1) {
    alert('请先选择要编辑的点位');
    return;
  }
  
  const x = parseInt(elements.xInput.value) || 0;
  const y = parseInt(elements.yInput.value) || 0;
  
  points[selectedIndex] = { x, y };
  updatePointList();
  selectPoint(selectedIndex);
}

// 删除点位
function deletePoint() {
  const selectedIndex = getSelectedPointIndex();
  if (selectedIndex === -1) {
    alert('请先选择要删除的点位');
    return;
  }
  
  points.splice(selectedIndex, 1);
  updatePointList();
}

// 清空点位
function clearPoints() {
  points = [];
  updatePointList();
}

// 更新点位列表
function updatePointList() {
  elements.pointList.innerHTML = '';
  
  points.forEach((point, index) => {
    const li = document.createElement('li');
    li.textContent = `点位 ${index + 1}: (${point.x}, ${point.y})`;
    li.dataset.index = index;
    elements.pointList.appendChild(li);
  });
}

// 处理点位点击
function handlePointClick(e) {
  if (e.target.tagName === 'LI') {
    const index = parseInt(e.target.dataset.index);
    selectPoint(index);
  }
}

// 选择点位
function selectPoint(index) {
  // 移除所有选中状态
  Array.from(elements.pointList.children).forEach(li => {
    li.classList.remove('selected');
  });
  
  // 选中当前点位
  const selectedLi = elements.pointList.children[index];
  if (selectedLi) {
    selectedLi.classList.add('selected');
    
    // 更新输入框
    const point = points[index];
    elements.xInput.value = point.x;
    elements.yInput.value = point.y;
  }
}

// 获取选中的点位索引
function getSelectedPointIndex() {
  const selectedLi = elements.pointList.querySelector('.selected');
  return selectedLi ? parseInt(selectedLi.dataset.index) : -1;
}

// 开始点击
function startClick() {
  const isMultiMode = elements.modeMulti.checked;
  
  if (isMultiMode && points.length === 0) {
    alert('多点模式下请先添加至少1个点位');
    return;
  }
  
  const x = parseInt(elements.xInput.value) || 0;
  const y = parseInt(elements.yInput.value) || 0;
  const interval = parseInt(elements.intervalInput.value) || 100;
  const clickCount = parseInt(elements.clickCountInput.value) || 100;
  const infinite = elements.infiniteCheckbox.checked;
  const button = elements.buttonLeft.checked ? 'left' : 'right';
  
  // 发送点击请求到主进程
  window.electronAPI.startClick({
    x, y, button, interval, clickCount, infinite,
    points: isMultiMode ? points : [],
    isMultiMode
  });
  
  updateStatus('运行中');
  updateControlButtons(true);
  isRunning = true;
  isPaused = false;
}

// 暂停/继续
function togglePause() {
  if (isPaused) {
    // 继续
    updateStatus('运行中');
    elements.pauseButton.textContent = '暂停';
    isPaused = false;
  } else {
    // 暂停
    updateStatus('暂停');
    elements.pauseButton.textContent = '继续';
    isPaused = true;
  }
}

// 停止点击
function stopClick() {
  window.electronAPI.stopClick();
  updateStatus('就绪');
  updateControlButtons(false);
  isRunning = false;
  isPaused = false;
}

// 更新状态
function updateStatus(status) {
  elements.statusText.textContent = status;
  
  // 移除所有状态类
  elements.statusIndicator.classList.remove('ready', 'running', 'paused');
  
  // 添加对应状态类
  if (status === '就绪') {
    elements.statusIndicator.classList.add('ready');
  } else if (status === '运行中') {
    elements.statusIndicator.classList.add('running');
  } else if (status === '暂停') {
    elements.statusIndicator.classList.add('paused');
  }
}

// 更新控制按钮状态
function updateControlButtons(isRunning) {
  elements.startButton.disabled = isRunning;
  elements.pauseButton.disabled = !isRunning;
  elements.stopButton.disabled = !isRunning;
  
  if (isRunning) {
    elements.pauseButton.textContent = '暂停';
  }
}

// 处理键盘事件
function handleKeydown(e) {
  // Cmd + Shift + S
  if (e.metaKey && e.shiftKey && e.key === 's') {
    e.preventDefault();
    if (isRunning) {
      stopClick();
    } else {
      startClick();
    }
  }
}

// 初始化应用
function initApp() {
  initEventListeners();
  updateStatus('就绪');
  updateControlButtons(false);
  updatePointList();
}

// 启动应用
window.addEventListener('DOMContentLoaded', initApp);