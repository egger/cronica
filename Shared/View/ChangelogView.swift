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
                                          image: "sparkles.tv", color: .orange)
                        .padding(.vertical)
                        ChangelogItemView(title: "featureTwoTitle",
                                          description: "featureTwoDescription",
                                          image: "film.stack", color: .red)
                        .padding(.vertical)
                        ChangelogItemView(title: "featureThreeTitle",
                                          description: "featureThreeDescription",
                                          image: "gearshape", color: .blue)
                        .padding(.vertical)
                    }
                }
                .padding(.horizontal)
                Spacer()
                VStack {
                    HStack {
                        Button {
                            showChangelog = false
                        } label: {
                            Text("Continue")
                                .frame(minWidth: 100)
                        }
                        .controlSize(.large)
                        .buttonStyle(.borderedProminent)
                        .tint(SettingsStore.shared.appTheme.color.gradient)
                        .padding(.horizontal)
                        
                        Button {
                            showTipJar.toggle()
                        } label: {
                            Text("tipJar")
                                .frame(minWidth: 100)
                        }
                        .controlSize(.large)
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
                .padding()
            }
            .navigationTitle("changelogViewTitle")
            .foregroundColor(showTipJar ? .secondary : nil)
            .sheet(isPresented: $showTipJar) {
                NavigationStack {
                    TipJarSetting()
                        .navigationTitle("tipJar")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem {
                                Button("Done") {
                                    showTipJar = false
                                }
                            }
                        }
                }
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
            }
        }
    }
}

struct ChangelogView_Previews: PreviewProvider {
    @State private static var show = false
    static var previews: some View {
        ChangelogView(showChangelog: $show)
    }
}

private struct ChangelogItemView: View {
    let title: String
    let description: String
    let image: String
    let color: Color
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40, alignment: .center)
                .foregroundColor(color)
            VStack(alignment: .leading) {
                Text(LocalizedStringKey(title))
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(LocalizedStringKey(description))
                    .font(.callout)
            }
            .padding(.leading, 12)
            Spacer()
        }
        .padding(.horizontal)
    }
}
