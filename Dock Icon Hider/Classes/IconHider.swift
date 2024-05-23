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
		case noPermissions
		case plistNotFound
		case reSignFailed
	}
	
	func toggleHide() throws {
		// Select app
		let selectedApp: URL = selectApp()
		// Close if running
		checkRunning(selectedApp)
		// Get plist path
		let infoUrl: URL = try getPlistUrl(selectedApp)
		// Change plist
		try changePlist(infoUrl)
	}
	
	func deleteProperty() throws {
		// Select app
		let selectedApp: URL = selectApp()
		// Close if running
		checkRunning(selectedApp)
		// Get plist path
		let infoUrl: URL = try getPlistUrl(selectedApp)
		// Reset plist
		try resetPlist(infoUrl)
	}
	
	func resignApp(_ email: String) throws {
		// Select app
		let selectedApp: URL = selectApp()
		// Close if running
		checkRunning(selectedApp)
		// Re-sign bundle
		let commandStr: String = "codesign --force --verbose=4 --sign \"\(email)\" \"\(selectedApp.posixPath())\""
		let process: Process = Process()
		let resultRaw = try! process.run(URL(fileURLWithPath: "/bin/zsh"), arguments: ["-c", commandStr])
		let result: String = "\(resultRaw)"
//		let result: String = CliTools.runCommand(command: commandStr)
		print("resultRaw: ", resultRaw)
		print(result.contains("signed app bundle with Mach-O"))
		if !result.contains("signed app bundle with Mach-O") {
			throw IconHiderError.reSignFailed
		}
	}
	
	func selectApp() -> URL {
		var selectedApp: URL? = nil
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
				if selectedApp!.pathExtension != "app" {
					selectedApp = nil
				}
			}
		} while selectedApp == nil
		return selectedApp!
	}
	
	func checkRunning(_ url: URL) {
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
