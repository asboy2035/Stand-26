//
//  ButtonLabelStyle.swift
//  SitStandTimer
//
//  Created by ash on 8/26/25.
//

import SwiftUI

struct ButtonLabelStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(6)
            .frame(maxWidth: .infinity)
    }
}
