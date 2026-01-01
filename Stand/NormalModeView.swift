//
//  NormalModeView.swift
//  Stand
//
//  Created by ash on 1/18/25.
//

import LaunchAtLogin
import SwiftUI

// -MARK: Sidebar
struct SidebarView: View {
  @ObservedObject private var timerManager = TimerManager.shared
  let availableSounds = ["Funk", "Ping", "Tink", "Glass", "Basso"]
  @AppStorage("showOccasionalReminders") private var showOccasionalReminders = true

  private var sittingTime: Double {
    timerManager.sittingTime
  }

  private var standingTime: Double {
    timerManager.standingTime
  }

  // Helper Bindings for minutes
  private var sittingTimeMinutes: Binding<Double> {
    Binding<Double>(
      get: { timerManager.sittingTime / 60 },
      set: { timerManager.sittingTime = $0 * 60 }
    )
  }

  private var standingTimeMinutes: Binding<Double> {
    Binding<Double>(
      get: { timerManager.standingTime / 60 },
      set: { timerManager.standingTime = $0 * 60 }
    )
  }

  var body: some View {
    List {
      VStack {
        Button(action: {
          timerManager.toggleFloatingWindow()
        }) {
          Label("toggleWidgetLabel", systemImage: "widget.small")
            .modifier(ButtonLabelStyle())
        }
        .modifier(StandardButtonStyle())
      }

      Group {
        Section(header: Text("intervalsLabel")) {
          HStack {
            Label("sittingTimeLabel", systemImage: IntervalType.sitting.systemImage)
            Spacer()

            HStack(spacing: 2) {
              Text(
                String(
                  (sittingTime / 60)
                    .rounded(.toNearestOrAwayFromZero)
                ).replacingOccurrences(of: ".0", with: "")
              )
              Text("minutesAbbr")
            }
            .foregroundStyle(.secondary)
          }
          Slider(
            value: sittingTimeMinutes,
            in: 1 ... 60
          )
          HStack {
            Label("standingTimeLabel", systemImage: IntervalType.standing.systemImage)
            Spacer()

            HStack(spacing: 2) {
              Text(
                String(
                  (standingTime / 60)
                    .rounded(.toNearestOrAwayFromZero)
                ).replacingOccurrences(of: ".0", with: "")
              )
              Text("minutesAbbr")
            }
            .foregroundStyle(.secondary)
          }
          Slider(
            value: standingTimeMinutes,
            in: 1 ... 60
          )
        }
      }

      Button(action: {
        SettingsWindowController.shared.showSettingsView()
      }) {
        Label("Settings...", systemImage: "gear")
      }
      .buttonStyle(.borderless)

      #if DEBUG
        Section("DEBUG") { // Debug tools
          Toggle("showOccasionalRemindersLabel", isOn: $showOccasionalReminders)
            .toggleStyle(.switch)
        }

        VStack {
          Button(action: {
            AboutWindowController.shared.showAboutView()
            UpdateWindowController.shared.showUpdateView()
            WelcomeWindowController.shared.showWelcomeView()
            SettingsWindowController.shared.showSettingsView()
          }) {
            Label("Show all windows", systemImage: "macwindow.on.rectangle")
          }

          Button(action: {
            var testNotification = AdaptableNotificationType(
              style: timerManager.notificationType,
              title: "Test Reminder",
              description: "This is a debug reminder test.",
              image: "bell",
              iconColor: .blue
            )
            testNotification.show(for: 3)
          }) {
            Label("Test Notification", systemImage: "bell.fill")
          }
        }
      #endif
    }
    .listStyle(.sidebar)
    .scrollContentBackground(.hidden)
    .frame(minWidth: 225)
  }
}

// -MARK: Detail (timer)
struct DetailView: View {
  @ObservedObject private var timerManager = TimerManager.shared
  @State private var currentChallenge: Challenge = challenges.randomElement()!
  @State var showStats = false

  var body: some View {
    VStack(spacing: 20) {
      HStack(spacing: 15) {
        Image(systemName: timerManager.currentInterval.systemImage)
          .font(.largeTitle)
        Text(timerManager.currentInterval.localizedString)
          .font(.title)
      }
      .foregroundStyle(.secondary)

      Text(timeString(from: timerManager.remainingTime))
        .animation(
          .easeInOut(duration: 0.1),
          value: timerManager.remainingTime
        )
        .font(.system(size: 48, design: .monospaced))

      ControlButtons()
      ChallengeCard()
        .padding(.horizontal)
        .padding(.top, 20)
    }
    .frame(minWidth: 375, idealWidth: nil, maxWidth: .infinity, minHeight: 400, idealHeight: nil, maxHeight: .infinity)
    .navigationTitle(NSLocalizedString("appName", comment: "App name for main content title"))
    .navigationSubtitle("26")
    .sheet(isPresented: $showStats) {
      StatsView(showStats: $showStats)
    }
    .toolbar {
      ToolbarItem(placement: .automatic) {
        Button(action: { showStats.toggle() }) {
          Label("showStatsLabel", systemImage: "chart.bar")
        }
      }
      if timerManager.isPaused {
        ToolbarItem(placement: .automatic) {
          Button(action: {
            if timerManager.isPauseNotchVisible {
              timerManager.handlePauseNotch(action: .hide)
            } else {
              timerManager.handlePauseNotch(action: .show)
            }
          }) {
            Label(
              timerManager.isPauseNotchVisible ?
                "hideNotchLabel" :
                "showNotchLabel",
              systemImage: timerManager.isPauseNotchVisible ?
                "bell.badge.slash.fill" :
                "bell.badge.fill"
            )
          }
        }
      }
    }
  }

  private func timeString(from timeInterval: TimeInterval) -> String {
    let minutes = Int(timeInterval) / 60
    let seconds = Int(timeInterval) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
}
