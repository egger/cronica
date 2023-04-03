//
//  FeatureRoadmap.swift
//  Story
//
//  Created by Alexandre Madeira on 28/02/23.
//
#if os(iOS) || os(macOS)
import SwiftUI
import Roadmap

struct FeatureRoadmap: View {
#if os(macOS)
    let configuration = RoadmapConfiguration(roadmapJSONURL: URL(string: "https://simplejsoncms.com/api/06l23o23ey9")!)
#else
    let configuration = RoadmapConfiguration(roadmapJSONURL: URL(string: "https://simplejsoncms.com/api/06l23o23ey9")!, style: RoadmapTemplate.clean, allowSearching: true)
#endif
    var body: some View {
        VStack {
            RoadmapView(configuration: configuration, header: {
                headerView
            })
        }
        .navigationTitle("featureRoadmap")
        .toolbar {
#if os(iOS)
            NavigationLink(destination: FeedbackSettingsView()) {
                Label("settingsFeedbackTitle", systemImage: "plus.circle")
            }
#endif
        }
    }
    
    private var headerView: some View {
#if os(macOS)
        VStack(alignment: .leading) {
            Text("featureRoadmapHeader")
                .fontWeight(.bold)
                .padding(.bottom, 2)
            Text("featureRoadmapSubtitle")
                .font(.callout)
        }
        .padding()
#else
        CenterHorizontalView {
            VStack(alignment: .leading) {
                Text("featureRoadmapHeader")
                    .fontWeight(.semibold)
                    .padding(.bottom, 2)
                Text("featureRoadmapSubtitle")
                    .font(.callout)
            }
            .padding(.horizontal, 4)
            .padding([.top, .bottom])
        }
#if os(iOS)
        .background(Color(uiColor: .secondarySystemBackground))
#endif
        .clipShape(RoundedRectangle(cornerRadius: 16))
#endif
    }
}

struct FeatureRoadmap_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FeatureRoadmap()
                .preferredColorScheme(.light)
        }
    }
}

extension RoadmapTemplate {
#if os(iOS)
    static let clean = RoadmapStyle(icon: Image(systemName: "chevron.up"),
                                    titleFont: .system(.headline, weight: .semibold),
                                    numberFont: .system(.body, weight: .semibold),
                                    statusFont: .caption,
                                    cornerRadius: 16,
                                    cellColor: Color(uiColor: .tertiarySystemGroupedBackground),
                                    selectedColor: .white,
                                    tint: SettingsStore.shared.appTheme.color)
#endif
}
#endif
