//
//  ChallengeCard.swift
//  SitStandTimer
//
//  Created by ash on 1/22/25.
//

import SwiftUI

struct ChallengeCard: View {
  @State private var currentChallenge: Challenge = challenges.randomElement()!

  var body: some View {
    HStack {
      Image(systemName: currentChallenge.symbol)
        .imageScale(.large)
        .padding(.horizontal, 6)

      VStack(alignment: .leading) {
        Text(currentChallenge.title)
        Text(currentChallenge.description)
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Button(action: { // Reload
        currentChallenge = challenges.randomElement()!
      }) {
        Image(systemName: "arrow.clockwise")
          .frame(height: 25)
      }
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .frame(width: 35, height: 35)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 8)
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 20))
    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
  }
}

#Preview {
  ChallengeCard()
    .padding()
}
