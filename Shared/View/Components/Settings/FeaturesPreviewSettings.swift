//
//  FeaturesPreviewSettings.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 19/11/22.
//

import SwiftUI

struct FeaturesPreviewSettings: View {
    @AppStorage("newBackgroundStyle") private var newBackgroundStyle = false
    var body: some View {
        Form {
            Section {
                Toggle("Translucent Background", isOn: $newBackgroundStyle)
            } header: {
                Text("Appearance")
            }
        }
        .navigationTitle("Experimental Features")
        .onChange(of: newBackgroundStyle) { newValue in
            CronicaTelemetry.shared.handleMessage("FeaturesPreview",
                                                  for: "newBackgroundStyle = \(newBackgroundStyle.description)")
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
}

struct FeaturesPreviewSettings_Previews: PreviewProvider {
    static var previews: some View {
        FeaturesPreviewSettings()
    }
}
