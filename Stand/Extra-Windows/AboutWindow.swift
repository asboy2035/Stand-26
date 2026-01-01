//
//  AboutWindow.swift
//  SitStandTimer
//
//  Created by ash on 1/18/25.
//

import SwiftUI

// -MARK: AboutWindowController
class AboutWindowController: NSObject {
  private var window: NSWindow?
  @ObservedObject private var timerManager = TimerManager.shared

  static let shared = AboutWindowController()

  override private init() {
    super.init()
  }

  func showAboutView() {
    if window == nil {
      let aboutView = AboutView()
      let hostingController = NSHostingController(rootView: aboutView)

      let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 600, height: 450),
        styleMask: [.titled, .closable, .fullSizeContentView, .resizable, .miniaturizable],
        backing: .buffered,
        defer: false
      )

      window.center()
      window.contentViewController = hostingController
      window.isReleasedWhenClosed = false
      window.titlebarAppearsTransparent = true
      window.isMovableByWindowBackground = true

      self.window = window
    }

    window?.makeKeyAndOrderFront(nil)
  }
}

// -MARK: AboutView
struct AboutView: View {
  @ObservedObject private var timerManager = TimerManager.shared

  private var appVersion: String {
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      return version
    }
    return "Unknown"
  }

  var body: some View {
    NavigationSplitView {
      List {
        AboutSection()
      }
      .listStyle(.sidebar)
      .frame(width: 200)
    } detail: {
      AboutContentView(appVersion: appVersion)
    }
    .frame(minWidth: 600, minHeight: 400)
    .background(
      VisualEffectView(
        material: .headerView,
        blendingMode: .behindWindow
      ).ignoresSafeArea()
    )
    .toolbar {
      ToolbarItem(placement: .automatic) {
        Button(action: {
          if let url = URL(string: "https://asboy2035.com/apps/stand") {
            NSWorkspace.shared.open(url)
          }
        }) {
          Label("websiteLabel", systemImage: "globe")
        }
      }
    }
    .navigationSubtitle("appName")
  }
}

// -MARK: Credits
struct CreditsView: View {
  struct Dependency {
    let name: String
    let url: String
    let license: String
    let systemImage: String
  }

  let dependencies: [Dependency] = [
    Dependency(
      name: "SwiftUI",
      url: "https://developer.apple.com/xcode/swiftui/",
      license: "Apple License",
      systemImage: "swift"
    ),
    Dependency(
      name: "Luminare",
      url: "https://github.com/MrKai77/Luminare",
      license: "BSD 3-Clause License",
      systemImage: "macwindow.and.cursorarrow"
    ),
    Dependency(
      name: "DynamicNotchKit",
      url: "https://github.com/MrKai77/DynamicNotchKit",
      license: "MIT License",
      systemImage: "macbook.gen2"
    ),
    Dependency(
      name: "LaunchAtLogin",
      url: "https://github.com/sindresorhus/LaunchAtLogin-Modern",
      license: "MIT License",
      systemImage: "bolt.fill"
    ),
    Dependency(
      name: "MarkdownUI",
      url: "https://github.com/gonzalezreal/swift-markdown-ui",
      license: "MIT License",
      systemImage: "richtext.page"
    ),
  ]

  var body: some View {
    VStack {
      VStack {
        Section {
          ForEach(dependencies, id: \.name) { dependency in
            Button(action: {
              if let url = URL(string: dependency.url) {
                NSWorkspace.shared.open(url)
              }
            }) {
              HStack {
                Image(systemName: dependency.systemImage)
                  .frame(width: 35)

                VStack(alignment: .leading) {
                  Text(dependency.name)
                  Text(dependency.license)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                Spacer()
              }
              .modifier(ButtonLabelStyle())
            }
            .modifier(StandardButtonStyle())
          }
        }
        Spacer()
      }
      .padding()
    }
    .background(
      VisualEffectView(
        material: .headerView,
        blendingMode: .behindWindow
      ).ignoresSafeArea()
    )
    .navigationTitle("creditsLabel")
  }
}

// -MARK: About Content
struct AboutContentView: View {
  @State private var isLatestVersion: Bool = true
  @ObservedObject private var timerManager = TimerManager.shared
  var appVersion: String

  var body: some View {
    VStack {
      Image(nsImage: NSApplication.shared.applicationIconImage)
        .resizable()
        .scaledToFit()
        .frame(width: 75, height: 75)

      Text("appName")
        .font(.title)
      Text(appVersion)
        .foregroundStyle(.secondary)

      Spacer()
      Button(action: {
        checkForUpdates()
      }) {
        Label(
          isLatestVersion ? "noUpdatesLabel" : "updateLabel",
          systemImage: "arrow.triangle.2.circlepath"
        )
      }
      .disabled(isLatestVersion)
      .modifier(StandardButtonStyle())
      .frame(width: 150, height: 35)
      Text("thanksText")
      Text("madeWithLove")
    }
    .padding()
    .background(
      VisualEffectView(
        material: .headerView,
        blendingMode: .behindWindow
      ).ignoresSafeArea()
    )
    .onAppear {
      checkForUpdates()
      print(appVersion)
    }
    .toolbar {
      ToolbarItem(placement: .automatic) {
        Button(action: {
          WelcomeWindowController.shared.showWelcomeView()
        }) {
          Label("welcome", systemImage: "figure.wave")
        }
      }
    }
    .navigationTitle("aboutLabel")
  }

  private func checkForUpdates() {
    guard let url = URL(
      string: "https://api.github.com/repos/asboy2035/Stand-26/releases/latest"
    ) else {
      print("Invalid URL")
      return
    }

    let task = URLSession.shared.dataTask(with: url) { data, _, error in
      guard let data = data, error == nil else {
        print("Error fetching data from GitHub: \(error?.localizedDescription ?? "Unknown error")")
        return
      }

      if let releaseData = try? JSONDecoder().decode(GitHubRelease.self, from: data) {
        let latestVersion = releaseData.tag_name
        DispatchQueue.main.async {
          // Compare the latest version from GitHub with the app's version
          if latestVersion > appVersion {
            isLatestVersion = false
            UpdateWindowController.shared.showUpdateView()
          }
          #if DEBUG
            UpdateWindowController.shared.showUpdateView()
            // Always show update in debug builds
          #endif
        }
      }
    }

    task.resume()
  }
}

// -MARK: Misc
struct GitHubRelease: Codable {
  var tag_name: String
}

#Preview {
  AboutView()
}
