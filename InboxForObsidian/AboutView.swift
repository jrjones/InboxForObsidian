//
//  AboutView.swift
//  InboxForObsidian
//
//  Created by Joseph R. Jones on 4/6/25.
//

import SwiftUI

extension Bundle {
    var appName: String {
        object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown App"
    }

    var appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0"
    }

    var buildNumber: String {
        object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                #if os(macOS)
                Image(nsImage: NSApp.applicationIconImage)
                #elseif os(iOS)
                Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                #endif
                
                Text(Bundle.main.appName)
                    .font(.title2)
                    .bold()
                
                Text("Version \(Bundle.main.appVersion) (\(Bundle.main.buildNumber))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                Text("Inbox for Obsidian by JRJ\nA minimal capture utility for Markdown notes. https://github.com/jrjones/InboxForObsidian")
                    .multilineTextAlignment(.center)
                    .font(.body)

                Button("OK") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .padding(.top, 12)
            }
            .padding()
            .frame(width: 320)
        }
    }
}
