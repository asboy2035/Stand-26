//
//  Stats.swift
//  SitStandTimer
//
//  Created by ash on 3/22/25.
//

import SwiftUI

// -MARK: Stats
struct StatsView: View {
  @ObservedObject private var timerManager = TimerManager.shared
  @Binding var showStats: Bool

  private func formatTime(minutes: Int) -> String {
    let hours = minutes / 60
    let remainingMinutes = minutes % 60
    return "\(hours)h \(remainingMinutes)m"
  }

  var body: some View {
    VStack {
      VStack {
        VStack(spacing: 4) {
          HStack {
            Image(systemName: "clock.fill")
              .frame(width: 20, height: 20)
            Text(NSLocalizedString("totalLabel", comment: "Total label"))
          }
          .foregroundStyle(
            LinearGradient(
              gradient: Gradient(colors: [IntervalType.sitting.color, IntervalType.standing.color]),
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          Text(
            formatTime(minutes:
              timerManager.timeHistory.standingMinutes +
                timerManager.timeHistory.sittingMinutes
            )
          )
          .font(.system(.title, design: .monospaced))
        }
        .modifier(ButtonLabelStyle())
        .padding()
        .modifier(StandardButtonStyle())

        HStack {
          StatsInfoCard(interval: .sitting, minutes: timerManager.timeHistory.sittingMinutes)
          StatsInfoCard(interval: .standing, minutes: timerManager.timeHistory.standingMinutes)
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button(action: {
          showStats = false
        }) {
          Label("closeLabel", systemImage: "xmark")
            .padding(.vertical, 4)
        }
        .clipShape(.capsule)
      }
    }
    .padding()
    .frame(width: 350)
  }
}

struct StatsInfoCard: View {
  let interval: IntervalType
  @State var minutes: Int

  private func formatTime(minutes: Int) -> String {
    let hours = minutes / 60
    let remainingMinutes = minutes % 60
    return "\(hours)h \(remainingMinutes)m"
  }

  var body: some View {
    VStack(spacing: 4) {
      HStack {
        Image(systemName: interval.systemImage)
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)
        Text(interval.localizedString)
      }
      .foregroundStyle(interval.color)

      Text(formatTime(minutes: minutes))
        .font(.system(.title, design: .monospaced))
    }
    .modifier(ButtonLabelStyle())
    .padding()
    .modifier(StandardButtonStyle())
  }
}

#Preview {
  @Previewable @State var showStats = true

  StatsView(showStats: $showStats)
}
