//
//  FloatingWindow.swift
//  SitStandTimer
//
//  Created by ash on 1/23/25.
//

import AppKit
import SwiftUI

class FloatingWindow: NSPanel {
  init(contentView: NSView) {
    super.init(
      contentRect: NSRect(x: 200, y: 250, width: 150, height: 150),
      styleMask: [.closable, .utilityWindow, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )

    isOpaque = false
    backgroundColor = .clear
    isMovableByWindowBackground = true
    level = .floating
    collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    self.contentView = contentView
    isReleasedWhenClosed = false
    title = "\(NSLocalizedString("appName", comment: "App name in widget title"))"
  }
}

struct FloatingWindowView: View {
  @ObservedObject var timerManager = TimerManager.shared

  var body: some View {
    VStack {
      HStack {
        Button(action: { timerManager.toggleFloatingWindow() }) {
          Image(systemName: "xmark.circle.fill")
        }
        Spacer()
        VStack {
          RoundedRectangle(cornerRadius: 4)
            .frame(width: 20, height: 3)
            .foregroundStyle(.tertiary)
        }
        Spacer()

        Button(action: { NSApplication.shared.terminate(nil) }) {
          Image(systemName: "power.circle.fill")
        }
      }
      .foregroundStyle(.tertiary)
      .buttonStyle(.borderless)

      Spacer()

      VStack(spacing: 2) {
        Text(timerManager.currentInterval.localizedString)
          .font(.system(size: 14))
          .foregroundStyle(.secondary)

        Text(timerManager.remainingTimeString)
          .font(.system(size: 32, weight: .light, design: .monospaced))
      }

      Spacer()
      ControlButtons(showTooltips: false)
    }
    .padding(12)
    .frame(width: 175, height: 175)
    .background(timerManager.currentInterval.color.opacity(0.2))
    .background(
      VisualEffectView(
        material: .hudWindow,
        blendingMode: .behindWindow
      ).ignoresSafeArea()
    )
    .mask(RoundedRectangle(cornerRadius: 22))
  }
}

private extension TimerManager {
  var remainingTimeString: String {
    let minutes = Int(remainingTime) / 60
    let seconds = Int(remainingTime) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
}

#Preview {
  FloatingWindowView()
}
