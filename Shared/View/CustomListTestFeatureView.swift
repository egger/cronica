//
//  CustomListTestFeatureView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 08/02/23.
//

import SwiftUI

struct CustomListTestFeatureView: View {
    @State private var listName = ""
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("List name", text: $listName)
                } header: {
                    Text("New List")
                }
                
                Section {
                    
                } header: {
                    Text("All Lists")
                }
            }
        }
    }
}

struct CustomListTestFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        CustomListTestFeatureView()
    }
}
