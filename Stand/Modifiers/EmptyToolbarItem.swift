//
//  EmptyToolbarItem.swift
//  Stand
//
//  Created by ash on 1/1/26.
//

import SwiftUI

struct EmptyToolbarItem: ToolbarContent {
  var body: some ToolbarContent {
    ToolbarItem(placement: .automatic) {
      Color.clear
    }
    .hidden()
  }
}
