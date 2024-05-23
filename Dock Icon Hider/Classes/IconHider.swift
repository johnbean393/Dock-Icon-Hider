//
//  IconHider.swift
//  Dock Icon Hider
//
//  Created by Bean John on 22/5/2024.
//

import Foundation
import AppKit
import ExtensionKit
import PListKit

class IconHider {
	
	static let shared: IconHider = IconHider()
	
	enum IconHiderError: Error {
		case cannotChangeSelf
		case noPermissions
		case plistNotFound
		case reSignFailed
	}
	
	func toggleHide() throws {
		// Select app
		let selectedApp: URL = selectApp()
		// Close if running
		try checkRunning(selectedApp)
		// Get plist path
		let infoUrl: URL = try getPlistUrl(selectedApp)
		// Change plist
		try changePlist(infoUrl)
	}
	
	func deleteProperty() throws {
		// Select app
		let selectedApp: URL = selectApp()
		// Close if running
		try checkRunning(selectedApp)
		// Get plist path
		let infoUrl: URL = try getPlistUrl(selectedApp)
		// Reset plist
		try resetPlist(infoUrl)
	}
	
	func resignApp(_ email: String) throws {
		// Select app
		let selectedApp: URL = selectApp()
		// Close if running
		try checkRunning(selectedApp)
		// Re-sign bundle
		let commandStr: String = "codesign --force --verbose=4 --sign \"\(email)\" \"\(selectedApp.posixPath())\""
		let process: Process = Process()
		do {
			let result: String = try process.run(URL(fileURLWithPath: "/bin/zsh"), arguments: ["-c", commandStr])
			if !result.contains("signed app bundle with Mach-O") {
				throw IconHiderError.reSignFailed
			}
		} catch {
			throw IconHiderError.reSignFailed
		}
	}
	
	func selectApp() -> URL {
		var selectedApp: URL? = nil
		// Show panel until app is selected
		repeat {
			let openPanel: NSOpenPanel = NSOpenPanel()
			openPanel.canChooseFiles = true
			openPanel.allowsMultipleSelection = false
			openPanel.canChooseDirectories = false
			openPanel.canCreateDirectories = false
			openPanel.title = "Choose an app"
			if openPanel.runModal() == .OK {
				selectedApp = openPanel.url
			}
			if selectedApp != nil {
				if selectedApp!.pathExtension != "app"  {
					selectedApp = nil
				}
			}
		} while selectedApp == nil
		return selectedApp!
	}
	
	func checkRunning(_ url: URL) throws {
		// Check if app is self
		if url.lastPathComponent == "Dock Icon Hider.app" {
			throw IconHiderError.cannotChangeSelf
		}
		// Quit app if running
		let runningApps: [NSRunningApplication] = NSWorkspace.shared.runningApplications
		runningApps.forEach { app in
			if app.bundleURL != nil {
				if app.bundleURL!  == url {
					let _ = app.terminate()
				}
			}
		}
	}
	
	func getPlistUrl(_ url: URL) throws -> URL {
		// Find plist location
		var infoUrl: URL = url.appendingPathComponent("Resources").appendingPathComponent("Info.plist")
		if !infoUrl.fileExists() {
			let dirItems: [URL] = try! url.listDirectory()
			if !dirItems.filter({ $0.lastPathComponent == "Info.plist" }).isEmpty {
				infoUrl = dirItems
					.filter({ $0.lastPathComponent == "Info.plist" })
					.sorted(by: { $0.absoluteString.count <= $1.absoluteString.count })
					.first!
			} else {
				throw IconHiderError.plistNotFound
			}
		}
		return infoUrl
	}
	
	func changePlist(_ infoUrl: URL) throws {
		// Toggle "Application is Agent"
		let plist: PList = try! PList<PListDictionary>(url: infoUrl)
		let currValue: Bool = plist.root.bool(key: "LSUIElement").value ?? false
		plist.root.bool(key: "LSUIElement").value = !currValue
		do {
			try plist.save(toFileAtURL: infoUrl)
		} catch {
			throw IconHiderError.noPermissions
		}
	}
	
	func resetPlist(_ infoUrl: URL) throws {
		// Remove "Application is Agent" key
		print(infoUrl.absoluteString)
		let plist: PList = try! PList<PListDictionary>(url: infoUrl)
		plist.root.bool(key: "LSUIElement").value = nil
		do {
			try plist.save(toFileAtURL: infoUrl)
		} catch {
			throw IconHiderError.noPermissions
		}
	}
	
}
