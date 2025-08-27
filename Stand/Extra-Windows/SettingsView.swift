//
//  SettingsView.swift
//  SitStandTimer
//
//  Created by ash on 2/8/25.
//

import LaunchAtLogin
import SwiftUI

class SettingsWindowController: NSObject {
    private var window: NSWindow?

    static let shared = SettingsWindowController()
    
    private override init() {
        super.init()
    }

    func showSettingsView() {
        if window == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1000, height: 450),
                styleMask: [.titled, .closable, .fullSizeContentView, .resizable],
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

struct SettingsView: View {
    var body: some View {
        NavigationSplitView {
            List {
                GeneralSection()
                AboutSection()
#if DEBUG
                MoreSection()
#endif
            }
            .frame(minWidth: 200)
        } detail: {
            GeneralSettingsView()
        }
        .frame(minWidth: 750, minHeight: 500)
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
        .background(
            VisualEffectView(
                material: .headerView,
                blendingMode: .behindWindow
            ).ignoresSafeArea()
        )
        .navigationSubtitle("Settings")
    }
}

// -MARK: General settings
struct GeneralSettingsView: View {
    @AppStorage("startTimerAtLaunch") private var startTimerAtLaunch = false
    @AppStorage("showWidgetAtLaunch") private var showWidgetAtLaunch = false
    @State var launchAtLogin = LaunchAtLogin.isEnabled
    
    var body: some View {
        Form {
            Section("appOptionsLabel") {
                Toggle("launchAtLoginLabel", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        LaunchAtLogin.isEnabled = newValue
                    }
            }

            Section("atLaunchOptionsLabel") {
                Toggle("startTimerAtLaunchLabel", isOn: $startTimerAtLaunch)
                Toggle("showWidgetAtLaunchLabel", isOn: $showWidgetAtLaunch)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .navigationTitle("generalSettings")
    }
}

struct NotificationsSettingsView: View {
    @ObservedObject var timerManager = TimerManager.shared
    @AppStorage("notificationType") private var notificationType: NotificationType = .banner
    @AppStorage("showOccasionalReminders") private var showOccasionalReminders = true
    let availableSounds = ["Funk", "Ping", "Tink", "Glass", "Basso"]
    
    var body: some View {
        Form {
            Section("notificationsSettings") {
                // Sound Picker
                Picker("alertSoundSettingLabel", selection: $timerManager.selectedSound) {
                    ForEach(availableSounds, id: \.self) { sound in
                        Text(sound).tag(sound)
                    }
                }
                .onChange(of: timerManager.selectedSound) { _ in
                    timerManager.playSound()
                }
                
                // Notification Type Picker
                HStack {
                    Text("Notification Type")
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Button(action: {
                            notificationType = .banner
                        }) {
                            Label("Banner", systemImage: "bell.badge.fill")
                        }
                        
                        Divider()
                            .padding(.horizontal)
                        
                        Button(action: {
                            notificationType = .hud
                        }) {
                            Label("HUD", systemImage: "square.fill")
                        }
                    }
                    .buttonStyle(.borderless)
                    .onChange(of: notificationType) { newValue in
                        timerManager.notificationType = newValue
                        var settedNoti = AdaptableNotificationType(
                            style: newValue,
                            title: NSLocalizedString("Notification style set!", comment: "Title for notification style set notification"),
                            description: NSLocalizedString("Notifications will now be in this style.", comment: "Description for notification style set notification"),
                            image: "heart.fill",
                            iconColor: .accentColor
                        )
                        settedNoti.show(for: 2)
                    }
                }
                
                Toggle("showOccasionalRemindersLabel", isOn: $showOccasionalReminders)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .navigationTitle("notificationsSettings")
    }
}

// -MARK: Experiments
struct ExperimentsSettingsView: View {
    @AppStorage("usingNewColors") private var usingNewColors: Bool = false
    
    var body: some View {
        Form {
            Section("experimentsLabel") {
                Toggle("usingNewColors", isOn: $usingNewColors)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .navigationTitle("experimentsLabel")
    }
}
