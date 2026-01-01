//
//  WelcomeWindow.swift
//  SitStandTimer
//
//  Created by ash on 1/19/25.
//

import DynamicNotchKit
import LaunchAtLogin
import SwiftUI

// -MARK: Welcome controller
class WelcomeWindowController: NSObject {
  private var window: NSWindow?
  static let shared = WelcomeWindowController()

  override private init() {
    super.init()
  }

  func close() {
    window?.close()
  }

  func showWelcomeView() {
    if window == nil {
      let welcomeView = WelcomeView()
      let hostingController = NSHostingController(rootView: welcomeView)

      let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
        styleMask: [.fullSizeContentView, .closable, .miniaturizable, .titled],
        backing: .buffered,
        defer: false
      )

      window.center()
      window.contentViewController = hostingController
      window.isReleasedWhenClosed = false
      window.isMovableByWindowBackground = true
      window.toolbarStyle = .unifiedCompact
      window.titlebarAppearsTransparent = true

      self.window = window
    }

    window?.makeKeyAndOrderFront(nil)
  }
}

// -MARK: Welcome View
struct WelcomeView: View {
  @ObservedObject private var timerManager = TimerManager.shared
  @AppStorage("showWelcome") var showWelcome: Bool = true
  @State private var currentSlideIndex = 0

  // Define slides
  private var slides: [Slide] = [
    Slide(
      titleKey: "keepTrackTitle",
      descriptionKey: "keepTrackDescription",
      view: AnyView(TimerDemoView())
    ),
    Slide(
      titleKey: "intervalsTitle",
      descriptionKey: "intervalsDescription",
      view: AnyView(IntervalsDemoView())
    ),
    Slide(
      titleKey: "notificationsTitle",
      descriptionKey: "notificationsDescription",
      view: AnyView(NotificationsDemoView())
    ),
  ]

  var body: some View {
    VStack {
      Text("welcome")
        .font(.headline)
        .foregroundStyle(.secondary)

      if currentSlideIndex < slides.count {
        // Slideshow content
        VStack {
          Spacer()
          slides[currentSlideIndex].view
            .frame(height: 200)
          Spacer()

          Text(NSLocalizedString(
            slides[currentSlideIndex].titleKey,
            tableName: "WelcomeLocalizations",
            comment: "Slide description"
          )
          )
          .font(.title)

          Text(NSLocalizedString(
            slides[currentSlideIndex].descriptionKey,
            tableName: "WelcomeLocalizations",
            comment: "Slide description"
          )
          )
          .foregroundStyle(.secondary)
          .padding(.bottom)

          HStack {
            Button(action: {
              if currentSlideIndex > 0 {
                currentSlideIndex -= 1
              }
            }) {
              Image(systemName: "arrow.left")
                .modifier(ButtonLabelStyle())
            }
            .modifier(StandardButtonStyle())

            Spacer()

            Button(action: {
              if currentSlideIndex < slides.count - 1 {
                currentSlideIndex += 1
              } else {
                // End of slideshow, show main content
                currentSlideIndex = slides.count
              }
            }) {
              Image(systemName: currentSlideIndex == slides.count - 1 ? "checkmark" : "arrow.right")
                .modifier(ButtonLabelStyle())
            }
            .modifier(StandardButtonStyle())
          }
          .frame(height: 35)
        }
        .multilineTextAlignment(.center)

        // -MARK: After slides
      } else {
        // After slideshow, show original content
        VStack {
          AppIconView()

          VStack(spacing: 2) {
            Text("welcomeTitle")
              .font(.title)
            Text("\(NSLocalizedString("appName", comment: "app name")) \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0")")
              .foregroundStyle(.secondary)

            Text("welcomeContent")
              .multilineTextAlignment(.center)
              .padding(.vertical)
          }

          Spacer()

          LaunchAtLogin.Toggle("\(NSLocalizedString("launchAtLoginLabel", comment: "Launch at login label"))")

          HStack {
            Button(action: {
              if currentSlideIndex > 0 {
                currentSlideIndex -= 1
              }
            }) {
              Image(systemName: "arrow.left")
                .modifier(ButtonLabelStyle())
            }
            .modifier(StandardButtonStyle())
            .frame(width: 55)

            Button(action: {
              WelcomeWindowController.shared.close()
            }) {
              Text("doneLabel")
                .modifier(ButtonLabelStyle())
            }
            .modifier(StandardButtonStyle())

            if showWelcome {
              Button(action: {
                showWelcome = false
                WelcomeWindowController.shared.close()
              }) {
                Text("dontShowAgainLabel")
                  .modifier(ButtonLabelStyle())
              }
              .modifier(StandardButtonStyle())
            }
          }
          .padding(.top)
        }
      }
    }
    .padding(20)
    .background(
      VisualEffectView(
        material: .menu,
        blendingMode: .behindWindow
      )
      .ignoresSafeArea()
    )
    .frame(width: 400, height: 400)
    .toolbar { EmptyToolbarItem() }
  }
}

struct Slide {
  let titleKey: String
  let descriptionKey: String
  let view: AnyView
}

// -MARK: App Icon
struct AppIconView: View {
  var body: some View {
    Image(nsImage: NSApplication.shared.applicationIconImage)
      .resizable()
      .scaledToFit()
      .frame(width: 100, height: 100)
  }
}

// -MARK: Timer demo
struct TimerDemoView: View {
  var body: some View {
    Text("9:41")
      .font(.system(size: 36, design: .monospaced))
  }
}

// -MARK: Intervals demo
struct IntervalsDemoView: View {
  var body: some View {
    HStack {
      VStack {
        Image(systemName: "figure.seated.side.right")
        Text("sittingLabel")
      }
      .padding()
      .frame(width: 125)
      .background(.indigo.opacity(0.2))
      .cornerRadius(12)

      VStack {
        Image(systemName: "figure")
        Text("standingLabel")
      }
      .padding()
      .frame(width: 125)
      .background(.yellow.opacity(0.2))
      .cornerRadius(12)
    }
  }
}

// -MARK: Notifications select
struct NotificationsDemoView: View {
  @ObservedObject var timerManager = TimerManager.shared
  @AppStorage("notificationType") var notificationType: NotificationType = .banner
  @AppStorage("showOccasionalReminders") private var showOccasionalReminders = true

  var body: some View {
    VStack {
      Text("chooseNotiStyle")
        .font(.title3)

      HStack(spacing: 4) {
        Button(action: {
          notificationType = .banner
        }) {
          Label("Banner", systemImage: "bell.badge.fill")
            .modifier(ButtonLabelStyle())
        }
        .modifier(StandardButtonStyle())

        Button(action: {
          notificationType = .hud
        }) {
          Label("HUD", systemImage: "square.fill")
            .modifier(ButtonLabelStyle())
        }
        .modifier(StandardButtonStyle())
      }

      Text("canChangeLater")
        .font(.caption)
        .foregroundStyle(.secondary)

      Toggle("showOccasionalRemindersLabel", isOn: $showOccasionalReminders)
        .toggleStyle(.switch)
    }
    .onAppear {
      let HUDNoti = HUD(
        title: NSLocalizedString("HUD", comment: "HUD Notification style title"),
        description: NSLocalizedString("thisIsHUD", comment: "Description for HUD notification"),
        systemImage: "heart.fill",
        imageColor: .accentColor
      )
      HUDNoti.show(for: 3)

      let NotchNoti = DynamicNotchInfo(
        icon: Image(systemName: "heart.fill"),
        title: NSLocalizedString("Banner", comment: "Banner notification style title"),
        description: NSLocalizedString("thisIsBanner", comment: "Description for Banner notification"),
        iconColor: .accentColor,
        textColor: .primary,
        style: .floating
      )
      NotchNoti.show(for: 3)
    }
    .onChange(of: notificationType) { newValue in
      timerManager.notificationType = newValue
      var settedNoti = AdaptableNotificationType(
        style: notificationType,
        title: NSLocalizedString("Notification style set!", comment: "Title for notification style set notification"),
        description: NSLocalizedString("Notifications will now be in this style.", comment: "Description for notification style set notification"),
        image: "heart.fill",
        iconColor: .accentColor
      )
      settedNoti.show(for: 2)
    }
    .padding()
    .overlay(RoundedRectangle(cornerRadius: 18).stroke(.tertiary.opacity(0.5), lineWidth: 1))
  }
}

// -MARK: Misc
#Preview {
  WelcomeView()
}
