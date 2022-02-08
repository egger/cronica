//
//  HomeView.swift
//  Story
//
//  Created by Alexandre Madeira on 16/01/22.
//

import SwiftUI

struct MovieView: View {
    @StateObject private var viewModel = MovieViewModel()
    static let tag: String? = "Movie"
    @State private var showingSheet: Bool = false
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(viewModel.sections) {
                        MovieListView(style: $0.style,
                                           title: $0.title,
                                           movies: $0.results) 
                    }
                }
                .task {
                    load()
                }
            }
            .navigationTitle("Movies")
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSheet.toggle()
                    } label: {
                        Image(systemName: "person")
                            .padding(.horizontal)
                            
                    }
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                }
            }
            .sheet(isPresented: $showingSheet) {
                NavigationView {
                    List {
                        NavigationLink(destination: EmptyView()) {
                            Label("Sign In", systemImage: "person")
                        }
                        NavigationLink(destination: EmptyView()) {
                            Label("Settings", systemImage: "gearshape")
                        }
                    }
                }
                .navigationTitle("Account")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingSheet.toggle()
                        }
                    }
                }
            }
            #endif
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
    
    @Sendable
    private func load() {
        Task {
            await viewModel.loadAllEndpoints()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        MovieView()
    }
}
