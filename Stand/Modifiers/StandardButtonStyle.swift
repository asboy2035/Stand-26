//
//  ButtonStyle.swift
//  SitStandTimer
//
//  Created by ash on 8/26/25.
//

import SwiftUI

struct StandardButtonStyle: ViewModifier {
    let isProminent: Bool = false
    
    func body(content: Content) -> some View {
        if isProminent {
            content
                .buttonStyle(BorderedProminentButtonStyle())
                .tint(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14))
        } else {
            content
                .buttonStyle(BorderedButtonStyle())
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14))
        }
    }
}
