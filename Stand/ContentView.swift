//
//  ContentView.swift
//  Stand
//
//  Created by ash on 12/10/24.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject private var timerManager = TimerManager.shared
  @AppStorage("sittingTime") private var sittingTime: Double = 30
  @AppStorage("standingTime") private var standingTime: Double = 10
  @AppStorage("showWelcome") private var showWelcome: Bool = true
  @State private var isFullScreen = false
  @State private var currentTime = Date()

  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  var body: some View {
    HStack {
      if isFullScreen {
        IdleModeView(currentTime: currentTime)
      } else {
        NavigationSplitView {
          GlassEffectContainer {
            SidebarView()
          }
        } detail: {
          GlassEffectContainer {
            DetailView()
          }
        }
        .frame(minWidth: 750)
        .background(.ultraThickMaterial)
      }
    }
    .onAppear {
      if showWelcome {
        WelcomeWindowController.shared.showWelcomeView()
      }
    }

    .onReceive(timer) { input in
      currentTime = input
    }

    .onReceive(
      NotificationCenter.default.publisher(for: NSWindow.willEnterFullScreenNotification)
    ) { _ in
      isFullScreen = true
    }

    .onReceive(
      NotificationCenter.default.publisher(for: NSWindow.willExitFullScreenNotification)
    ) { _ in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        isFullScreen = false
      }
    }
    .onDisappear {
      NSApplication.shared.terminate(nil)
    }
  }
}
