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
    @ObservedObject private var viewModel: DetailsViewModel
    @ObservedObject private var settings: SettingsStore = SettingsStore()
    @State private var isAboutPresented: Bool = false
    @State private var isSharePresented: Bool = false
    @State private var isNotificationAvailable: Bool = false
    @State private var isNotificationScheduled: Bool = false
    @State private var isInWatchlist: Bool = false
    @State private var seasonSelection: String = ""
    @State private var isLoading: Bool = true
    init(title: String, id: Int, type: MediaType) {
        _viewModel = ObservedObject(wrappedValue: DetailsViewModel())
        self.title = title
        self.id = id
        self.type = type
    }
    var body: some View {
        ScrollView {
            VStack {
                if let content = viewModel.content {
                    VStack {
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
                                    Rectangle().fill(.thickMaterial)
                                    ProgressView(content.itemTitle)
                                }
                            } else {
                                ZStack {
                                    Rectangle().fill(.thickMaterial)
                                    VStack {
                                        Text(title)
                                            .lineLimit(1)
                                            .padding(.bottom)
                                        Image(systemName: "film")
                                    }
                                    .padding()
                                    .foregroundColor(.secondary)
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
                                    if !content.isReleased && content.itemContentMedia != MediaType.tvShow { isNotificationAvailable.toggle() }
                                }
                        }
                        //MARK: Watchlist button
                        Button {
                            haptics()
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
                        .disabled(isLoading)
                        //MARK: About view
                        GroupBox {
                            Text(content.itemAbout)
                                .padding([.top], 2)
                                .textSelection(.enabled)
                                .lineLimit(4)
                        } label: {
                            Label("About", systemImage: "film")
                                .unredacted()
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
                            SeasonListView(title: "Seasons", id: self.id, items: content.seasons!)
                        }
                        //MARK: Cast view
                        if let cast = content.credits {
                            CastListView(credits: cast)
                        }
                        //MARK: Information view
                        InformationSectionView(item: content)
                        //MARK: Recommendation view
                        if let filmography = content.recommendations {
                            ContentListView(style: StyleType.poster,
                                            type: content.itemContentMedia,
                                            title: "Recommendations",
                                            subtitle: "You may like",
                                            image: "list.and.film",
                                            items: filmography.results)
                        }
                        //MARK: Attribution view
                        AttributionView().padding([.top, .bottom])
                            .unredacted()
                    }
                    .redacted(reason: isLoading ? .placeholder : [])
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
                            haptics()
                            scheduleNotification()
                        }, label: {
                            withAnimation {
                                Image(systemName: isNotificationScheduled ? "bell.fill" : "bell")
                            }
                        })
                        .help("Notify when released.")
                        .opacity(isNotificationAvailable ? 1 : 0)
                        .disabled(isLoading ? true : false)
                        Button(action: {
                            haptics()
                            isSharePresented.toggle()
                        }, label: {
                            Image(systemName: "square.and.arrow.up")
                        })
                        .disabled(isLoading ? true : false)
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
                viewModel.scheduleNotification()
                withAnimation {
                    isNotificationScheduled = viewModel.isNotificationEnabled
                }
            }
            if settings.authorizationStatus == .notDetermined {
                NotificationManager.shared.requestAuthorization { granted in
                    if granted == true {
                        viewModel.scheduleNotification()
                        withAnimation {
                            isNotificationScheduled = viewModel.isNotificationEnabled
                        }
                    }
                }
            }
        }
    }
    private func haptics() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred(intensity: 1.0)
    }
    @Sendable
    private func load() {
        Task {
            await self.viewModel.load(id: self.id, type: self.type)
            if viewModel.isLoaded {
                isInWatchlist = viewModel.context.isItemInList(id: self.id)
                if isInWatchlist {
                    isNotificationScheduled = viewModel.context.isNotificationScheduled(id: self.id)
                }
                isLoading = false
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
