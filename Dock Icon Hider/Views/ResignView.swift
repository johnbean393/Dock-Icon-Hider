//
//  ResignView.swift
//  Dock Icon Hider
//
//  Created by Bean John on 22/5/2024.
//

import SwiftUI

struct ResignView: View {
	
	@Binding var showingAlert: Bool
	@Binding var errorMsg: String?
	
	@AppStorage("email") private var email: String = ""
	
	@Binding var showResignSheet: Bool
	
	var body: some View {
		VStack(alignment: .leading) {
			Text("**Modified apps ofter fail when they are modified, as the process invalidates the earlier code signing. You can attempt to re-sign the app by providing your Developer ID email.**")
				.font(.title)
				.lineLimit(nil)
			HStack {
				Text("Email: ")
				TextField("Email", text: $email)
					.textFieldStyle(.roundedBorder)
			}
			Link(
				"Don't have an Apple Developer Account?",
				destination: URL(string: "https://developer.apple.com/help/account/get-started/about-your-developer-account")!)
			Divider()
			HStack {
				Button("Start") {
					showResignSheet.toggle()
					do {
						try IconHider.shared.resignApp(email)
					} catch {
						errorMsg = "\(error)"
						showingAlert = true
					}
				}
				.keyboardShortcut(.defaultAction)
				Button("Cancel") {
					showResignSheet.toggle()
				}
			}
		}
		.frame(minWidth: 500, idealWidth: 500, maxWidth: 500)
		.fixedSize()
		.padding()
	}
}

//#Preview {
//    ResignView()
//}
