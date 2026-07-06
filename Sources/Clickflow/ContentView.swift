import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: ClickViewModel
    
    var body: some View {
        Form {
            Section("模式选择") {
                Picker("点击模式", selection: $viewModel.clickMode) {
                    ForEach(ClickMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("点位配置") {
                HStack {
                    VStack(alignment: .leading) {
                        Text("X 坐标")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("X", value: $viewModel.tempX, format: .number)
                            .frame(width: 120)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Y 坐标")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Y", value: $viewModel.tempY, format: .number)
                            .frame(width: 120)
                    }
                    
                    Button(viewModel.isPicking ? "正在拾取..." : "拾取坐标") {
                        viewModel.pickCoordinates()
                    }
                    .disabled(viewModel.isPicking)
                }
                .padding(.vertical, 4)
                
                HStack(spacing: 8) {
                    Button("添加") {
                        viewModel.addPoint()
                    }
                    .disabled(viewModel.clickMode == .single)
                    
                    Button("更新") {
                        viewModel.updatePoint()
                    }
                    .disabled(viewModel.selectedPointIndex == nil || viewModel.clickMode == .single)
                    
                    Button("删除") {
                        viewModel.deletePoint()
                    }
                    .disabled(viewModel.selectedPointIndex == nil || viewModel.clickMode == .single)
                    
                    Button("清空") {
                        viewModel.clearPoints()
                    }
                    .disabled(viewModel.points.isEmpty || viewModel.clickMode == .single)
                }
                
                if viewModel.clickMode == .multi {
                    List(selection: $viewModel.selectedPointIndex) {
                        ForEach(Array(viewModel.points.enumerated()), id: \.element.id) { index, point in
                            HStack {
                                Text("\(index + 1).")
                                    .foregroundColor(.secondary)
                                    .frame(width: 30, alignment: .leading)
                                Text("X: \(Int(point.x)), Y: \(Int(point.y))")
                                Spacer()
                            }
                            .tag(index as Int?)
                        }
                    }
                    .frame(height: 150)
                    .onChange(of: viewModel.selectedPointIndex) { newValue in
                        if let index = newValue {
                            viewModel.selectPoint(at: index)
                        }
                    }
                }
            }
            
            Section("时间设置") {
                HStack {
                    Text("间隔时间")
                    Spacer()
                    TextField("毫秒", value: $viewModel.interval, format: .number)
                        .frame(width: 120)
                        .multilineTextAlignment(.trailing)
                    Text("ms")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("点击次数")
                    Spacer()
                    TextField("次数", value: $viewModel.clickCount, format: .number)
                        .frame(width: 120)
                        .multilineTextAlignment(.trailing)
                        .disabled(viewModel.isInfiniteLoop)
                }
                
                Toggle("无限循环", isOn: $viewModel.isInfiniteLoop)
            }
            
            Section("鼠标按键") {
                Picker("按键选择", selection: $viewModel.mouseButton) {
                    ForEach(MouseButton.allCases) { button in
                        Text(button.rawValue).tag(button)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("运行状态") {
                HStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 10, height: 10)
                    Text(viewModel.runStatus.rawValue)
                        .font(.subheadline)
                    Spacer()
                }
            }
            
            Section {
                HStack(spacing: 12) {
                    Button {
                        if viewModel.runStatus == .ready {
                            viewModel.start()
                        } else if viewModel.runStatus == .running {
                            viewModel.pause()
                        } else if viewModel.runStatus == .paused {
                            viewModel.resume()
                        }
                    } label: {
                        Text(buttonTitle)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button("停止") {
                        viewModel.stop()
                    }
                    .controlSize(.large)
                    .disabled(viewModel.runStatus == .ready)
                }
            }
            
            Section {
                HStack {
                    Spacer()
                    Image(systemName: "keyboard")
                        .foregroundColor(.secondary)
                    Text("全局快捷键:")
                        .foregroundColor(.secondary)
                    Text("⌘ + Shift + S")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 700)
    }
    
    private var statusColor: Color {
        switch viewModel.runStatus {
        case .ready:
            return .gray
        case .running:
            return .green
        case .paused:
            return .orange
        }
    }
    
    private var buttonTitle: String {
        switch viewModel.runStatus {
        case .ready:
            return "开始"
        case .running:
            return "暂停"
        case .paused:
            return "继续"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
