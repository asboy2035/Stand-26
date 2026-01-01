//
//  SettingsSections.swift
//  SitStandTimer
//
//  Created by ash on 8/27/25.
//

import SwiftUI

struct GeneralSection: View {
  var body: some View {
    Section("generalSettings") {
      NavigationLink(destination: GeneralSettingsView()) {
        Label("generalSettings", systemImage: "gear")
      }

      NavigationLink(destination: NotificationsSettingsView()) {
        Label("notificationsSettings", systemImage: "bell.fill")
      }
    }
  }
}

struct AboutSection: View {
  private var appVersion: String {
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      return version
    }
    return "Unknown"
  }

  var body: some View {
    Section("aboutLabel") {
      NavigationLink(destination: AboutContentView(appVersion: appVersion)) {
        Label("aboutLabel", systemImage: "info.circle")
      }

      NavigationLink(destination: CreditsView()) {
        Label("creditsLabel", systemImage: "shippingbox.fill")
      }
    }
  }
}

struct MoreSection: View {
  var body: some View {
    Section("moreLabel") {
      NavigationLink(destination: ExperimentsSettingsView()) {
        Label("experimentsLabel", systemImage: "testtube.2")
      }
    }
  }
}
