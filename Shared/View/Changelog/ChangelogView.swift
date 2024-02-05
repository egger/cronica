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
                            title: NSLocalizedString("featureOneTitle", comment: ""),
                            description: NSLocalizedString("featureOneDescription", comment: ""),
                            image: "sparkles.tv",
                            color: .orange
                        ).padding(.vertical)
                        
                        changelogItem(
                            title: NSLocalizedString("featureTwoTitle", comment: ""),
                            description: NSLocalizedString("featureTwoDescription", comment: ""),
                            image: "film.stack",
                            color: .red
                        ).padding(.vertical)
                        
                        changelogItem(
                            title: NSLocalizedString("featureThreeTitle", comment: ""),
                            description: NSLocalizedString("featureThreeDescription", comment: ""),
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
            .navigationTitle("Changelog")
            .foregroundColor(showTipJar ? .secondary : nil)
            .sheet(isPresented: $showTipJar) {
                NavigationStack {
                    TipJarSetting()
                        .navigationTitle("Tip Jar")
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
                    Text("Tip Jar")
                        .frame(minWidth: 100)
                }
#if os(iOS) || os(macOS)
                .controlSize(.large)
#endif
                .buttonStyle(.bordered)
                .fixedSize()
                .padding(.trailing)
            }
            
            Text("If you love the app, consider supporting through Tip Jar.")
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
