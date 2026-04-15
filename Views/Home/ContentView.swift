//
//  ContentView.swift
//  Captain Swift
//
//  Created by Omar Gmd on 2026-04-11.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            // Shown on iPad when no chapter is selected yet
            VStack(spacing: 16) {
                Image("mascot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                Text("Select a chapter to start reading")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
    }
}
