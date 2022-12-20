//
//  AcknowledgementsSettings.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

struct AcknowledgementsSettings: View {
    var body: some View {
        Form {
            Button {
                
            } label: {
                Text("acknowledgmentsDeveloper")
            }
            Button {
                
            } label: {
                Text("acknowledgmentsAppIcon")
            }
            Button {
                
            } label: {
                Text("acknowledgmentsContentProvider")
            }
            Button {
                
            } label: {
                Text("acknowledgmentsSDWebImage")
            }
        }
        .navigationTitle("acknowledgmentsTitle")
    }
}

struct AcknowledgementsSettings_Previews: PreviewProvider {
    static var previews: some View {
        AcknowledgementsSettings()
    }
}
