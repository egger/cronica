//
//  ChangelogView.swift
//  Cronica
//
//  Created by Alexandre Madeira on 15/03/23.
//

import SwiftUI

struct ChangelogView: View {
    @Binding var showChangelog: Bool
    @State private var showTipJar = false
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                VStack {
                    ScrollView {
                        changelogItem(
                            title: "featureOneTitle",
                            description: "featureOneDescription",
                            image: "sparkles.tv",
                            color: .orange
                        ).padding(.vertical)
                        
                        changelogItem(
                            title: "featureTwoTitle",
                            description: "featureTwoDescription",
                            image: "film.stack",
                            color: .red
                        ).padding(.vertical)
                        
                        changelogItem(
                            title: "featureThreeTitle",
                            description: "featureThreeDescription",
                            image: "gearshape",
                            color: .blue
                        ).padding(.vertical)
                    }
                }
                .padding(.horizontal)
                Spacer()
                VStack {
                    if SettingsStore.shared.hasPurchasedTipJar {
                        Button {
                            showChangelog = false
                        } label: {
                            Text("Continue")
                                .frame(minWidth: 200)
                        }
#if os(iOS) || os(macOS)
                        .controlSize(.large)
#endif
                        .buttonStyle(.borderedProminent)
                        .tint(SettingsStore.shared.appTheme.color.gradient)
                        .padding(.horizontal)
                    } else {
                        defaultButtons
                    }
                    
                }
                .padding()
            }
            .navigationTitle("changelogViewTitle")
            .foregroundColor(showTipJar ? .secondary : nil)
            .sheet(isPresented: $showTipJar) {
                NavigationStack {
                    TipJarSetting()
                        .navigationTitle("tipJar")
#if os(iOS)
                        .navigationBarTitleDisplayMode(.inline)
#endif
                        .toolbar {
                            ToolbarItem {
                                Button("Done") {
                                    withAnimation { showTipJar = false }
                                }
                            }
                        }
                }
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
#if os(macOS)
                .frame(minWidth: 400, idealWidth: 600, maxWidth: nil, minHeight: 500, idealHeight: 500, maxHeight: nil, alignment: .center)
#endif
            }
        }
    }
    
    private func changelogItem(title: String, description: String, image: String, color: Color) -> some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40, alignment: .center)
                .foregroundColor(showTipJar ? .secondary : color)
            VStack(alignment: .leading) {
                Text(LocalizedStringKey(title))
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(LocalizedStringKey(description))
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 12)
            Spacer()
        }
        .padding(.horizontal)
    }
    
    var defaultButtons: some View {
        VStack {
            HStack {
                Button {
                    showChangelog = false
                } label: {
                    Text("Continue")
                        .frame(minWidth: 100)
                }
#if os(iOS) || os(macOS)
                .controlSize(.large)
#endif
                .buttonStyle(.borderedProminent)
                .tint(SettingsStore.shared.appTheme.color.gradient)
                .padding(.horizontal)
                
                Button {
                    withAnimation {
                        showTipJar.toggle()
                    }
                } label: {
                    Text("tipJar")
                        .frame(minWidth: 100)
                }
#if os(iOS) || os(macOS)
                .controlSize(.large)
#endif
                .buttonStyle(.bordered)
                .fixedSize()
                .padding(.trailing)
            }
            
            Text("tipJarDescription")
                .frame(minWidth: 100)
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.top, 4)
                .padding(.horizontal)
        }
    }
}

#Preview {
    ChangelogView(showChangelog: .constant(false))
}
