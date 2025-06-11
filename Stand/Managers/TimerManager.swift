//
//  TimerManager.swift
//  SitStandTimer
//
//  Recreated by ash on 1/4/25.
//

import Foundation
import DynamicNotchKit
import SwiftUI
import LaunchAtLogin

enum IntervalType {
    case sitting
    case standing
    
    var localizedString: String {
        switch self {
        case .sitting: return NSLocalizedString("sittingLabel", comment: "")
        case .standing: return NSLocalizedString("standingLabel", comment: "")
        }
    }
    
    var infinitiveLocalizedString: String {
        switch self {
        case .sitting: return NSLocalizedString("sitLabel", comment: "")
        case .standing: return NSLocalizedString("standLabel", comment: "")
        }
    }
    
    var systemImage: String {
        switch self {
        case .sitting: return "figure.seated.side.left"
        case .standing: return "figure.stand"
        }
    }
    
    var color: Color {
        let usingNewColors = UserDefaults.standard.bool(forKey: "usingNewColors")
        
        switch self {
        case .sitting:
            return .indigo
        case .standing:
            return usingNewColors ? .mint : .yellow
        }
    }
    
    var appIconName: String {
        switch self {
        case .sitting: return "Sitting-26"
        case .standing: return "Standing-26"
        }
    }
}

class TimerManager: ObservableObject {
    var headless: Bool = false
    @Published var currentInterval: IntervalType = .sitting
    @Published var remainingTime: TimeInterval = 0
    @Published var isRunning: Bool = false
    @Published var isPauseNotchVisible: Bool = false
    @Published var isPaused: Bool = false
    @Published var _notificationType: NotificationType = .banner
    @Published var selectedSound: String = "Funk" {
        didSet {
            UserDefaults.standard.set(selectedSound, forKey: "selectedAlertSound")
        }
    }
    @Published var timeHistory: TimeHistory
    
    private var timer: Timer?
    private var historyTimer: Timer?
    private var reminderManager: RandomReminderManager?
    private var sittingTime: TimeInterval = 30 * 60
    private var standingTime: TimeInterval = 10 * 60
    private var lastHistoryUpdateTime: Date = Date()
    private var startTime: Date?
    private var pauseNotch: AdaptableNotificationType?
    
    init(headless: Bool = false) {
        self.headless = headless
        self.timeHistory = TimeHistory.load()

        // Load sitting and standing time from UserDefaults or set to default values if not found
        sittingTime = UserDefaults.standard.double(forKey: "sittingTime") // Loaded from UserDefaults
        standingTime = UserDefaults.standard.double(forKey: "standingTime") // Loaded from UserDefaults
        if let savedType = UserDefaults.standard.string(forKey: "notificationType"),
           let type = NotificationType(rawValue: savedType) {
            _notificationType = type
        }
    
        if sittingTime == 0 {
            sittingTime = 45 * 60 // Default sitting time of 45 minutes in seconds
        }

        if standingTime == 0 {
            standingTime = 30 * 60 // Default standing time of 30 minutes in seconds
        }

        remainingTime = UserDefaults.standard.double(forKey: "remainingTime")

        if remainingTime == 0 {
            remainingTime = sittingTime // Default remaining time to sitting time if nothing is set
        }

        currentInterval = UserDefaults.standard.bool(forKey: "isStanding") ? .standing : .sitting

        if !headless {
            reminderManager = RandomReminderManager(timerManager: self)
            
            if LaunchAtLogin.isEnabled {
                if UserDefaults.standard.bool(forKey: "startTimerAtLaunch") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        self?.resumeTimer()
                    }
                }
                
                if UserDefaults.standard.bool(forKey: "showWidgetAtLaunch") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        if self?.floatingWindowController == nil {
                            self?.toggleFloatingWindow()
                        }
                    }
                }
            }
        }
    }
    
    
    var notificationType: NotificationType {
        get {
            return _notificationType
        }
        set {
            // Update internal property
            _notificationType = newValue
            
            // Save to UserDefaults
            UserDefaults.standard.set(newValue.rawValue, forKey: "notificationType")
        }
    }
    
    private var floatingWindowController: NSWindowController? {
        willSet { floatingWindowController?.close() }
    }

    func toggleFloatingWindow() {
        if floatingWindowController == nil {
            let contentView = FloatingWindowView()
                .environmentObject(self)
            let hostingController = NSHostingController(rootView: contentView)
            let floatingWindow = FloatingWindow(contentView: hostingController.view)
            
            floatingWindowController = NSWindowController(window: floatingWindow)
            floatingWindowController?.showWindow(self)
        } else {
            floatingWindowController?.close()
            floatingWindowController = nil
        }
    }
    
    private func saveState() {
        UserDefaults.standard.set(currentInterval == .standing, forKey: "isStanding")
        UserDefaults.standard.set(remainingTime, forKey: "remainingTime")
        UserDefaults.standard.set(isRunning, forKey: "isRunning")
    }
    
    private var switchSound: NSSound? {
        return NSSound(named: selectedSound)
    }
    
    
    func getPauseNotch() -> AdaptableNotificationType {
        return AdaptableNotificationType(
            style: notificationType, // Always use the current notificationType
            title: NSLocalizedString("timerPausedTitle", comment: "timer paused title"),
            description: NSLocalizedString("timerPausedContent", comment: "timer paused content"),
            image: "pause.circle.fill",
            iconColor: .accentColor
        )
    }
    private func updatePauseNotch() {
        if pauseNotch == nil {
            // Create a new pauseNotch if it's not initialized
            pauseNotch = getPauseNotch()
        } else {
            // Update the style of the existing pauseNotch to reflect the current notificationType
            pauseNotch?.hide()
            pauseNotch?.style = notificationType
        }
    }
    enum NotchAction: String {
        case show, hide, auto
    }
    func handlePauseNotch(
        action: NotchAction = .auto
    ) {
        if !headless {
            updatePauseNotch()
            
            switch (action) {
            case .show:
                pauseNotch?.show()
                isPauseNotchVisible = true
            case .hide:
                pauseNotch?.hide()
                isPauseNotchVisible = false
            default:
                if (!isRunning) {
                    pauseNotch?.show()
                    isPauseNotchVisible = true
                } else {
                    pauseNotch?.hide()
                    isPauseNotchVisible = false
                }
            }
        }
    }
    
    func initializeWithStoredTimes(sitting: Double, standing: Double) {
        sittingTime = round(sitting) * 60
        standingTime = round(standing) * 60
        remainingTime = sittingTime
        currentInterval = .sitting // always init with sitting
    }

    func updateIntervalTime(type: IntervalType, time: Double) {
        let timeInSeconds = round(time) * 60 // Ensure it's an exact multiple of 60
        switch type {
        case .sitting:
            sittingTime = timeInSeconds
            if currentInterval == .sitting && !isRunning {
                remainingTime = timeInSeconds
            }
        case .standing:
            standingTime = timeInSeconds
            if currentInterval == .standing && !isRunning {
                remainingTime = timeInSeconds
            }
        }
    }
    
    private func updateTimeHistory() {
        guard isRunning else { return }
        
        let now = Date()
        let elapsedMinutes = Int(now.timeIntervalSince(lastHistoryUpdateTime) / 60)
        
        if elapsedMinutes > 0 {
            if currentInterval == .sitting {
                timeHistory.sittingMinutes += elapsedMinutes
            } else {
                timeHistory.standingMinutes += elapsedMinutes
            }
            timeHistory.save()
            lastHistoryUpdateTime = now
        }
    }
    
    private func setupHistoryTracker() {
        historyTimer?.invalidate()
        historyTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateTimeHistory()
        }
    }
    
    private func reloadNotifcationType() -> NotificationType {
        if let storedValue = UserDefaults.standard.string(forKey: "notificationType"),
           let storedType = NotificationType(rawValue: storedValue) {
            return storedType
        }
        return .banner
    }
    
    private var targetEndTime: Date?
    private func updateRemainingTime() {
        notificationType = reloadNotifcationType()
        guard let targetEndTime else { return }

        let newRemainingTime = targetEndTime.timeIntervalSinceNow
        let roundedTime = ceil(newRemainingTime) // Ensure it only decrements whole seconds

        if roundedTime != remainingTime {
            remainingTime = max(roundedTime, 0) // Prevent negative values
        }

        if remainingTime <= 0 {
            switchInterval()
        }
    }
    
    func resumeTimer() {
        saveState()
        guard !isRunning else { return }

        isRunning = true
        handlePauseNotch()
        isPaused = false
        lastHistoryUpdateTime = Date()

        startTime = Date()
        targetEndTime = Date().addingTimeInterval(remainingTime) // Set the exact end time

        setupHistoryTracker()

        timer?.invalidate() // Clear any previous timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateRemainingTime()
        }
    }
    
    func pauseTimer() {
        quietPauseTimer()
        handlePauseNotch()
    }
    
    func quietPauseTimer() {
        isRunning = false
        isPaused = true
        timer?.invalidate()
        timer = nil
        historyTimer?.invalidate()
        historyTimer = nil
        saveState()
    }
    
    func resetTimer() {
        saveState()
        quietPauseTimer()
        handlePauseNotch(action: .hide)
        isPaused = false
        currentInterval = .sitting
        remainingTime = sittingTime
    }
    
    func playSound() {
        switchSound?.play()
    }
    
    func switchInterval() {
        quietPauseTimer()
        currentInterval = currentInterval == .sitting ? .standing : .sitting
        remainingTime = currentInterval == .sitting ? sittingTime : standingTime
        switchSound?.play()
        
        resumeTimer()
        var notch = AdaptableNotificationType(
            style: notificationType,
            title: NSLocalizedString("timeToLabel", comment: "time to") + " " + currentInterval.infinitiveLocalizedString,
            description: NSLocalizedString("switchItUpContent", comment: "switch it up!"),
            image: currentInterval.systemImage,
            iconColor: currentInterval.color
        )
        notch.show(for: 3)
    }
}
