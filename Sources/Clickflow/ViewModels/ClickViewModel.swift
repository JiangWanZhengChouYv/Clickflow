import Foundation
import SwiftUI
import Combine

@MainActor
class ClickViewModel: ObservableObject {
    @Published var clickMode: ClickMode = .single
    @Published var points: [ClickPoint] = []
    @Published var selectedPointIndex: Int? = nil
    @Published var interval: Double = 100
    @Published var clickCount: Int = 100
    @Published var isInfiniteLoop: Bool = false
    @Published var mouseButton: MouseButton = .left
    @Published var runStatus: RunStatus = .ready
    
    @Published var tempX: Double = 0
    @Published var tempY: Double = 0
    @Published var isPicking: Bool = false

    private let mouseService = MouseControlService.shared
    private let crosshairService = CrosshairOverlayService.shared
    private var clickTask: Task<Void, Never>?
    private var currentClickIndex: Int = 0
    
    var selectedPoint: ClickPoint? {
        guard let index = selectedPointIndex, index < points.count else { return nil }
        return points[index]
    }
    
    func addPoint() {
        let point = ClickPoint(x: tempX, y: tempY)
        points.append(point)
        selectedPointIndex = points.count - 1
    }
    
    func updatePoint() {
        guard let index = selectedPointIndex, index < points.count else { return }
        points[index].x = tempX
        points[index].y = tempY
    }
    
    func deletePoint() {
        guard let index = selectedPointIndex, index < points.count else { return }
        points.remove(at: index)
        if points.isEmpty {
            selectedPointIndex = nil
        } else if index >= points.count {
            selectedPointIndex = points.count - 1
        }
    }
    
    func clearPoints() {
        points.removeAll()
        selectedPointIndex = nil
        tempX = 0
        tempY = 0
    }
    
    func selectPoint(at index: Int) {
        guard index < points.count else { return }
        selectedPointIndex = index
        tempX = points[index].x
        tempY = points[index].y
    }
    
    func start() {
        guard runStatus == .ready else { return }
        
        if clickMode == .single {
            guard points.isEmpty == false || (tempX != 0 || tempY != 0) else { return }
        } else {
            guard !points.isEmpty else { return }
        }
        
        runStatus = .running
        currentClickIndex = 0
        clickTask = Task {
            await runClickLoop()
        }
    }
    
    func pause() {
        guard runStatus == .running else { return }
        runStatus = .paused
    }
    
    func resume() {
        guard runStatus == .paused else { return }
        runStatus = .running
    }
    
    func stop() {
        runStatus = .ready
        clickTask?.cancel()
        clickTask = nil
        currentClickIndex = 0
    }
    
    func pickCoordinates() {
        guard !isPicking else { return }
        isPicking = true

        crosshairService.showCrosshair { [weak self] point in
            DispatchQueue.main.async {
                self?.isPicking = false
                if let point = point {
                    self?.tempX = Double(point.x)
                    self?.tempY = Double(point.y)
                }
            }
        }
    }
    
    private func runClickLoop() async {
        var clicksPerformed = 0
        
        while !Task.isCancelled {
            if runStatus == .ready {
                break
            }
            
            if runStatus == .paused {
                do {
                    try await Task.sleep(nanoseconds: 50_000_000)
                } catch {
                    break
                }
                continue
            }
            
            if !isInfiniteLoop && clicksPerformed >= clickCount {
                break
            }
            
            var targetPoint: ClickPoint? = nil
            
            switch clickMode {
            case .single:
                if let firstPoint = points.first {
                    targetPoint = firstPoint
                } else {
                    targetPoint = ClickPoint(x: tempX, y: tempY)
                }
            case .multi:
                guard !points.isEmpty else { break }
                targetPoint = points[currentClickIndex % points.count]
                currentClickIndex += 1
            }
            
            guard let point = targetPoint else { break }
            
            mouseService.click(at: point.x, point.y, button: mouseButton)
            clicksPerformed += 1
            
            do {
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000))
            } catch {
                break
            }
        }
        
        if runStatus != .ready {
            runStatus = .ready
        }
    }
}
