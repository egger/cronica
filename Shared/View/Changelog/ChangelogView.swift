//
//  ChangelogView.swift
//  Story
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
                        ChangelogItemView(title: "featureOneTitle",
                                          description: "featureOneDescription",
                                          image: "sparkles.tv", color: .orange, isDisplayingTipJar: $showTipJar)
                        .padding(.vertical)
                        ChangelogItemView(title: "featureTwoTitle",
                                          description: "featureTwoDescription",
                                          image: "film.stack", color: .red, isDisplayingTipJar: $showTipJar)
                        .padding(.vertical)
                        ChangelogItemView(title: "featureThreeTitle",
                                          description: "featureThreeDescription",
                                          image: "gearshape", color: .blue, isDisplayingTipJar: $showTipJar)
                        .padding(.vertical)
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
            }
        }
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

struct ChangelogView_Previews: PreviewProvider {
    static var previews: some View {
        ChangelogView(showChangelog: .constant(false))
    }
}
