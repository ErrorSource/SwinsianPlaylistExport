//
//  Playlist_ExportApp.swift
//  Playlist Export
//
//  Created by Georg Kemser on 18.11.21.
//

import SwiftUI

@main
struct Playlist_ExportApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1000, minHeight: 800)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillTerminate(_ notification: Notification) {
        print("App will terminate!")
    }
}
