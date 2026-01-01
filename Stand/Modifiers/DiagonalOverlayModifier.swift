//
//  DiagonalOverlayModifier.swift
//  Stand
//
//  Created by ash on 8/27/25.
//

import SwiftUI

struct DiagonalOverlayModifier: ViewModifier {
  let highOpacity: Double = 0.2
  let lowOpacity: Double = 0.1

  func body(content: Content) -> some View {
    content
      .overlay(
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .strokeBorder(
            AngularGradient(
              gradient: Gradient(colors: [
                .primary.opacity(lowOpacity), // transparent at top-right/bottom-left
                .primary.opacity(highOpacity), // opaque at top-left
                .primary.opacity(lowOpacity), // transparent at bottom-left
                .primary.opacity(highOpacity), // opaque at bottom-right
                .primary.opacity(lowOpacity), // smooth out towards beginning
              ]),
              center: .center,
              startAngle: .degrees(45),
              endAngle: .degrees(405)
            ),
            lineWidth: 1
          )
      )
  }
}
