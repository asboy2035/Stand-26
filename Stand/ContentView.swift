//
//  ContentView.swift
//  SitStandTimer
//
//  Created by ash on 12/10/24.
//

import SwiftUI
import DynamicNotchKit
import Luminare

struct ContentView: View {
    @EnvironmentObject private var timerManager: TimerManager
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
                    .environmentObject(timerManager)
            } else {
                NormalModeView(sittingTime: $sittingTime, standingTime: $standingTime)
                    .environmentObject(timerManager)
            }
        }
        .onAppear() {
            if showWelcome {
                WelcomeWindowController.shared.showWelcomeView(timerManager: timerManager)
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
        
        .onReceive (
            NotificationCenter.default.publisher(for: NSWindow.willExitFullScreenNotification)
        ) { _ in
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
               isFullScreen = false
           }
        }
    }
}
