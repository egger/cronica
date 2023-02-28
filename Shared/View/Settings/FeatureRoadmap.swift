//
//  FeatureRoadmap.swift
//  Story
//
//  Created by Alexandre Madeira on 28/02/23.
//

import SwiftUI
import Roadmap

struct FeatureRoadmap: View {
    let configuration = RoadmapConfiguration(roadmapJSONURL: URL(string: "https://simplejsoncms.com/api/06l23o23ey9")!,
                                             style: RoadmapTemplate.clean)
    var body: some View {
        VStack {
            headerView
            RoadmapView(configuration: configuration)
        }
        .navigationTitle("featureRoadmap")
        .toolbar {
            NavigationLink(destination: FeedbackSettingsView()) {
                Label("settingsFeedbackTitle", systemImage: "plus.circle")
            }
        }
    }
    
    private var headerView: some View {
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
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 2)
        .padding()
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
    static let clean = RoadmapStyle(icon: Image(systemName: "arrow.up"),
                                    titleFont: .system(.headline, weight: .semibold),
                                    numberFont: .system(.body, weight: .semibold),
                                    statusFont: .caption,
                                    cornerRadius: 10,
                                    cellColor: Color(uiColor: .secondarySystemGroupedBackground),
                                    selectedColor: .white,
                                    tint: SettingsStore.shared.appTheme.color)
}
