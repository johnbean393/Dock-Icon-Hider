//
//  Dock_Icon_HiderApp.swift
//  Dock Icon Hider
//
//  Created by Bean John on 22/5/2024.
//

import SwiftUI

@main
struct Dock_Icon_HiderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
				.padding(.bottom, 3)
        }
		.windowResizability(.contentSize)
		.windowStyle(.hiddenTitleBar)
    }
}
