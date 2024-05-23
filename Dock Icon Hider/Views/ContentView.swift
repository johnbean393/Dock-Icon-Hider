//
//  ContentView.swift
//  Dock Icon Hider
//
//  Created by Bean John on 22/5/2024.
//

import SwiftUI

struct ContentView: View {
	
	@State private var showingAlert = false
	@State private var errorMsg: String? = nil
	@State private var showResignSheet: Bool = false
	
    var body: some View {
		HStack(spacing: 12) {
			VStack(spacing: 12) {
				Image(systemName: "wand.and.stars.inverse")
					.symbolRenderingMode(.palette)
					.foregroundStyle(Color.black, Color.yellow)
					.font(.system(size: 100))
					.frame(width: 200, height: 200)
					.background(Circle().fill(Color.white))
					.onTapGesture {
						do {
							try IconHider.shared.toggleHide()
						} catch {
							errorMsg = "\(error)"
							showingAlert = true
						}
					}
				Text("**Toggle Hide**")
			}
			VStack(spacing: 12) {
				Image(systemName: "eraser.line.dashed.fill")
					.symbolRenderingMode(.palette)
					.foregroundStyle(Color.blue, Color.red)
					.font(.system(size: 100))
					.frame(width: 200, height: 200)
					.background(Circle().fill(Color.white))
					.onTapGesture {
						do {
							try IconHider.shared.deleteProperty()
						} catch {
							errorMsg = "\(error)"
							showingAlert = true
						}
					}
				Text("**Remove Hide Preference**")
			}
			VStack(spacing: 12) {
				Image(systemName: "signature")
					.foregroundStyle(Color.blue)
					.font(.system(size: 100))
					.frame(width: 200, height: 200)
					.background(Circle().fill(Color.white))
					.onTapGesture {
						showResignSheet.toggle()
					}
				Text("**Re-sign App**")
			}
		}
		.padding()
		.alert("Error", isPresented: $showingAlert) {
			Button(role: .destructive) {
				// Handle the deletion.
			} label: {
				Text("OK")
			}
			.keyboardShortcut(.defaultAction)
		} message: {
			Text(errorMsg ?? "")
		}
		.sheet(isPresented: $showResignSheet) {
			ResignView(showingAlert: $showingAlert, errorMsg: $errorMsg, showResignSheet: $showResignSheet)
		}
		
    }
	
}

#Preview {
    ContentView()
}
