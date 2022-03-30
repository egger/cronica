//
//  DetailsView.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI

struct DetailsView: View {
    var title: String
    var id: Int
    var type: MediaType
    @StateObject private var viewModel: DetailsViewModel
    @ObservedObject private var settings: SettingsStore = SettingsStore()
    @State private var isAboutPresented: Bool = false
    @State private var isSharePresented: Bool = false
    @State private var isNotificationAvailable: Bool = false
    @State private var isNotificationScheduled: Bool = false
    @State private var isInWatchlist: Bool = false
    @State private var seasonSelection: String = ""
    init(title: String, id: Int, type: MediaType) {
        _viewModel = StateObject(wrappedValue: DetailsViewModel())
        self.title = title
        self.id = id
        self.type = type
    }
    var body: some View {
        ScrollView {
            VStack {
                if let content = viewModel.content {
                    //MARK: Hero Image
                    AsyncImage(url: content.cardImageLarge,
                               transaction: Transaction(animation: .easeInOut)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .transition(.opacity)
                        } else if phase.error != nil {
                            ZStack {
                                Rectangle().fill(.secondary)
                                Text(content.itemTitle)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            ZStack {
                                Rectangle().fill(.thickMaterial)
                                ProgressView(content.itemTitle)
                            }
                        }
                    }
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .cornerRadius(DrawingConstants.imageRadius)
                    .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                            radius: DrawingConstants.shadowRadius)
                    .padding([.top, .bottom])
                    .accessibilityLabel("Hero image of \(content.itemTitle).")
                    //MARK: Quick glance info
                    if !content.itemInfo.isEmpty {
                        Text(content.itemInfo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .onAppear {
                                if !content.isReleased { isNotificationAvailable.toggle() }
                            }
                    }
                    //MARK: Watchlist button
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred(intensity: 1.0)
                        if !isInWatchlist {
                            if content.itemCanNotify {
                                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                                    if settings.authorizationStatus == .denied {
                                        viewModel.addItem(notify: false)
                                    } else {
                                        scheduleNotification()
                                        viewModel.addItem(notify: true)
                                    }
                                }
                            } else {
                                viewModel.addItem(notify: false)
                            }
                            withAnimation {
                                isInWatchlist.toggle()
                            }
                        } else {
                            viewModel.removeItem()
                            withAnimation {
                                isInWatchlist.toggle()
                            }
                        }
                    } label: {
                        withAnimation {
                            Label(!isInWatchlist ? "Add to watchlist" : "Remove from watchlist",
                                  systemImage: !isInWatchlist ? "plus.square" : "minus.square")
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(!isInWatchlist ? .blue : .red)
                    .controlSize(.large)
                    //MARK: About view
                    GroupBox {
                        Text(content.itemAbout)
                            .padding([.top], 2)
                            .textSelection(.enabled)
                            .lineLimit(4)
                    } label: {
                        Label("About", systemImage: "film")
                    }
                    .padding()
                    .onTapGesture {
                        isAboutPresented.toggle()
                    }
                    .sheet(isPresented: $isAboutPresented) {
                        NavigationView {
                            ScrollView {
                                Text(content.itemAbout).padding()
                            }
                            .navigationTitle(content.itemTitle)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        isAboutPresented.toggle()
                                    }
                                }
                            }
                        }
                    }
                    //MARK: Season view
                    if content.seasonsNumber > 0 {
                        
                    }
                    //MARK: Cast view
                    if content.credits != nil {
                        CastListView(credits: content.credits!)
                    }
                    //MARK: Information view
                    InformationView(item: content)
                    //MARK: Recommendation view
                    if content.recommendations != nil {
                        ContentListView(style: StyleType.poster,
                                        type: content.itemContentMedia,
                                        title: "Recommendations",
                                        items: content.recommendations!.results)
                    }
                    AttributionView().padding([.top, .bottom])
                }
            }
            .sheet(isPresented: $isSharePresented, content: { ActivityViewController(itemsToShare: [title]) })
            .overlay(overlayView)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem {
                    HStack {
                        Button( action: {
                            scheduleNotification()
                        }, label: {
                            withAnimation {
                                Image(systemName: isNotificationScheduled ? "bell.fill" : "bell")
                            }
                        })
                        .help("Notify when released.")
                        .opacity(isNotificationAvailable ? 1 : 0)
                        Button(action: {
                            isSharePresented.toggle()
                        }, label: {
                            Image(systemName: "square.and.arrow.up")
                        })
                    }
                }
            }
            
        }
        .task {
            load()
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch viewModel.phase {
        case .empty:
            ProgressView()
        case .failure(let error):
            RetryView(text: error.localizedDescription, retryAction: {
                Task {
                    await viewModel.load(id: self.id, type: self.type)
                }
            })
        default:
            EmptyView()
        }
    }
    
    private func scheduleNotification() { 
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                withAnimation {
                    isNotificationScheduled = true
                }
                viewModel.scheduleNotification()
            }
            if settings.authorizationStatus == .notDetermined {
                NotificationManager.shared.requestAuthorization { granted in
                    if granted == true {
                        withAnimation {
                            isNotificationScheduled = true
                        }
                        viewModel.scheduleNotification()
                    }
                }
            }
        }
    }
    @Sendable
    private func load() {
        Task {
            await self.viewModel.load(id: self.id, type: self.type)
            isInWatchlist = viewModel.context.isItemInList(id: self.id)
            if isInWatchlist {
                isNotificationScheduled = viewModel.context.isNotificationScheduled(id: self.id)
            }
        }
    }
}

struct ContentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(title: Content.previewContent.itemTitle,
                    id: Content.previewContent.id,
                    type: MediaType.movie)
    }
}

private struct DrawingConstants {
    static let shadowOpacity: Double = 0.2
    static let shadowRadius: CGFloat = 5
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 210
    static let imageRadius: CGFloat = 8
}
