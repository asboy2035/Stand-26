//
//  UpdateView.swift
//  Stand
//
//  Created by ash on 1/22/25.
//

import MarkdownUI
import SwiftUI

struct UpdateView: View {
  @State private var updateTag: String = ""
  @State private var updateBody: String = ""
  @State private var updateURL: String = ""

  var body: some View {
    VStack {
      Image(nsImage: NSApplication.shared.applicationIconImage)
        .resizable()
        .scaledToFit()
        .frame(width: 75, height: 75)

      if !updateTag.isEmpty {
        Text("\(NSLocalizedString("updateAvailableTitle", comment: "")): \(updateTag)!")
          .font(.title)
          .padding(.bottom, 5)
      }

      if !updateBody.isEmpty {
        ScrollView {
          Markdown(updateBody)
            .padding()
        }
      }

      VStack {
        Text("updateAvailableContent")
          .font(.caption)
          .foregroundStyle(.secondary)
        HStack {
          if !updateURL.isEmpty {
            Button(action: {
              if let url = URL(string: updateURL) {
                NSWorkspace.shared.open(url)
              }
            }) {
              Label("GitHub", systemImage: "link")
                .modifier(ButtonLabelStyle())
            }
            .modifier(StandardButtonStyle())
          } else {
            Text("loadingUpdate")
          }

          Button(action: {
            if let url = URL(string: "macappstore://") {
              NSWorkspace.shared.open(url)
            }
          }) {
            Label("App Store", systemImage: "applelogo")
              .modifier(ButtonLabelStyle())
          }
          .modifier(StandardButtonStyle())
        }
      }
    }
    .padding(20)
    .frame(width: 400, height: 400)
    .background(
      VisualEffectView(
        material: .menu,
        blendingMode: .behindWindow
      ).ignoresSafeArea()
    )
    .onAppear {
      self.getUpdateData()
    }
    .toolbar { EmptyToolbarItem() }
  }

  private func getUpdateData() {
    guard let url = URL(string: "https://api.github.com/repos/asboy2035/Stand/releases/latest") else {
      print("Invalid URL")
      return
    }

    let task = URLSession.shared.dataTask(with: url) { data, _, error in
      guard let data = data, error == nil else {
        print("Error fetching data from GitHub: \(error?.localizedDescription ?? "Unknown error")")
        return
      }

      if let updateData = try? JSONDecoder().decode(GitHubReleaseData.self, from: data) {
        DispatchQueue.main.async {
          self.updateTag = updateData.tag_name
          self.updateBody = updateData.body
          self.updateURL = updateData.html_url
        }
      } else {
        print("Failed to decode update data")
      }
    }

    task.resume()
  }
}

class UpdateWindowController: NSObject {
  private var window: NSWindow?

  static let shared = UpdateWindowController()

  override private init() {
    super.init()
  }

  func showUpdateView() {
    if window == nil {
      let updateView = UpdateView()
      let hostingController = NSHostingController(rootView: updateView)

      let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
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

#Preview {
  UpdateView()
}

struct GitHubReleaseData: Codable {
  var tag_name: String
  var body: String
  var html_url: String
}
