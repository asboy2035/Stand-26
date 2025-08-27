//
//  ControlButtons.swift
//  SitStandTimer
//
//  Created by ash on 2/17/25.
//

import SwiftUI

struct ControlButtons: View {
    @ObservedObject var timerManager = TimerManager.shared
    @State var showTooltips: Bool = true
    let standardRect = RoundedRectangle(cornerRadius: 16)
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                timerManager.resetTimer()
            }) {
                Image(systemName: "arrow.clockwise")
                    .padding(.vertical, 6)
            }
            .clipShape(standardRect)
            .glassEffect(.regular, in: standardRect)
            .keyboardShortcut("r", modifiers: [])
            .help(
                showTooltips ?
                    "\(NSLocalizedString("resetLabel", comment: "Reset button tooltip")) ∙ R" :
                    ""
            )
            
            Button(action: {
                if timerManager.isRunning {
                    timerManager.pauseTimer()
                } else {
                    timerManager.resumeTimer()
                }
            }) {
                Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                    .scaleEffect(1.4)
                    .padding(14)
                    .padding(.horizontal, 2)
            }
            .clipShape(.capsule)
            .glassEffect()
            .keyboardShortcut(.space, modifiers: [])
            .help(
                showTooltips ?
                    "\(NSLocalizedString("playPauseLabel", comment: "Play/Pause button tooltip")) ∙ _"  :
                    ""
            )
            
            Button(action: {
                timerManager.switchInterval()
            }) {
                Image(systemName: "repeat")
                    .padding(.horizontal, -2)
                    .padding(.vertical, 7)
            }
            .clipShape(standardRect)
            .glassEffect(.regular, in: standardRect)
            .keyboardShortcut(.return, modifiers: [])
            .help(
                showTooltips ?
                    "\(NSLocalizedString("quickSwitchLabel", comment: "Quick Switch button tooltip")) ∙ ⏎" :
                    ""
            )
        }
        .imageScale(.large)
        .buttonStyle(.borderedProminent)
    }
}
