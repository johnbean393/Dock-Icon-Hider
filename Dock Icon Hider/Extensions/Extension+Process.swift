//
//  Extension+Process.swift
//  Dock Icon Hider
//
//  Created by Bean John on 23/5/2024.
//

import Foundation

extension Process {
	
	func run(_ executableURL: URL, arguments: [String]? = nil) throws -> String {
		self.executableURL = executableURL
		self.arguments = arguments
		
		let pipe = Pipe()
		standardOutput = pipe
		standardError = pipe
		
		try run()
		waitUntilExit()
		
		guard terminationStatus == EXIT_SUCCESS else {
			let error = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
			throw (error?.trimmingCharacters(in: .newlines) ?? "")
		}
		
		let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
		return output?.trimmingCharacters(in: .newlines) ?? ""
	}
}
