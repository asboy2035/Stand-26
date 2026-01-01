//
//  StandApp.swift
//  Stand
//

import SwiftUI

@main
struct StandApp: App {
  @ObservedObject private var timerManager: TimerManager = .shared
  // Use AppDelegate
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    Group {
      MenuBarExtra("appName", systemImage: timerManager.currentInterval.systemImage) {
        MenuBarPopoverContent()
      }
      .menuBarExtraStyle(.window)
      .commands {
        CommandGroup(replacing: .appInfo) {
          Button(action: {
            AboutWindowController.shared.showAboutView()
          }) {
            Label("aboutMenuLabel", systemImage: "info.circle")
          }
        }
        CommandGroup(replacing: .appSettings) {
          Button(action: {
            SettingsWindowController.shared.showSettingsView()
          }) {
            Label("Settings...", systemImage: "gear")
          }
          .keyboardShortcut(",", modifiers: .command) // ⌘,
        }
      }
    }
  }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, NSApplicationDelegate {
  var window: NSWindow?
  var settingsWindow: NSWindow?
  var fullScreenManager = FullScreenManager()
  @ObservedObject var timerManager = TimerManager.shared
  @AppStorage("showWelcome") private var showWelcome: Bool = true

  override init() {
    super.init()
  }

  func applicationDidFinishLaunching(_: Notification) {
    setupMainWindow()
    setupSettingsWindow()
  }

  private func setupMainWindow() {
    let mainContent = GlassEffectContainer {
      ContentView()
    }

    let mainWindow = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
      styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
      backing: .buffered,
      defer: false
    )
    mainWindow.titlebarAppearsTransparent = true
    mainWindow.isOpaque = false
    mainWindow.backgroundColor = .clear
    mainWindow.center()
    mainWindow.setFrameAutosaveName("Main Window")

    mainWindow.contentViewController = NSHostingController(rootView: mainContent)
    mainWindow.makeKeyAndOrderFront(nil)
    window = mainWindow
  }

  private func setupSettingsWindow() {
    let settingsView = SettingsView()
    let settingsWindow = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
      styleMask: [.titled, .closable],
      backing: .buffered,
      defer: false
    )
    settingsWindow.center()
    settingsWindow.setFrameAutosaveName("Settings Window")
    settingsWindow.contentView = NSHostingView(rootView: settingsView)
    settingsWindow.title = "Settings"
    self.settingsWindow = settingsWindow
  }

  private func formatTime(_ time: TimeInterval) -> String {
    let minutes = Int(time) / 60
    let seconds = Int(time) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
}

// MARK: - MenuBarPopoverContent

struct MenuBarPopoverContent: View {
  @ObservedObject var timerManager = TimerManager.shared
  @AppStorage("sittingTime") private var sittingTime: Double = 30
  @AppStorage("standingTime") private var standingTime: Double = 10

  private func formatTime(_ time: TimeInterval) -> String {
    let minutes = Int(time) / 60
    let seconds = Int(time) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }

  var body: some View {
    VStack {
      Spacer()
      Text(timerManager.currentInterval.localizedString)
        .font(.title)
        .foregroundStyle(.secondary)
      Text(formatTime(timerManager.remainingTime))
        .font(.system(.title2, design: .monospaced))
      Spacer()

      HStack(spacing: 16) { // Minimal Controls
        Button(action: {
          self.timerManager.resetTimer()
        }) {
          Image(systemName: "arrow.clockwise")
        }

        Button(action: {
          if self.timerManager.isRunning {
            self.timerManager.pauseTimer()
          } else {
            self.timerManager.resumeTimer()
          }
        }) {
          Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
        }

        Button(action: {
          self.timerManager.switchInterval()
        }) {
          Image(systemName: "repeat")
        }
      }
      .foregroundStyle(.foreground)
      .imageScale(.large)
      .buttonStyle(.borderless)

      Spacer()

      Button(action: { NSApplication.shared.terminate(nil) }) {
        Label("quitApp", systemImage: "power")
          .modifier(ButtonLabelStyle())
      }
      .modifier(StandardButtonStyle())
      .modifier(DiagonalOverlayModifier())
    }
    .frame(width: 150, height: 150)
    .padding()
    .background(timerManager.currentInterval.color.opacity(0.2))
  }
}

class FullScreenManager: ObservableObject {
  @Published var isFullScreen: Bool = false
}
