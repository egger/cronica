//
//  TipJarSetting.swift
//  Story
//
//  Created by Alexandre Madeira on 05/01/23.
//

import SwiftUI
import StoreKit

struct TipJarSetting: View {
    @StateObject private var viewModel = StoreKitManager()
    @State private var productsLoaded = false
    var body: some View {
        Form {
            Section {
                if viewModel.hasUserPurchased || SettingsStore.shared.hasPurchasedTipJar {
                    Text("thankYouTipJarMessage")
                } else {
                    if !productsLoaded { ProgressView() }
                    ForEach(viewModel.storeProducts) { item in
                        Button {
                            Task {
                                try await viewModel.purchase(item)
                            }
                        } label: {
                            TipJarItem(storeKit: viewModel, product: item)
                        }
#if os(macOS)
                        .buttonStyle(.plain)
#endif
                    }
                    Button("restorePurchases") {
                        Task {
                            try? await AppStore.sync()
                        }
                    }
                    .disabled(!productsLoaded)
                }
            } header: {
#if os(macOS)
                Label("tipJarTitle", systemImage: "heart")
#endif
            } footer: {
                if !SettingsStore.shared.hasPurchasedTipJar {
                    Text("tipJarFooter")
                }
            }
        }
        .navigationTitle("tipJarTitle")
        .onChange(of: viewModel.hasLoadedProducts) { hasLoaded in
            if hasLoaded {
                withAnimation { productsLoaded = true }
            }
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
}

private struct TipJarItem: View {
    @ObservedObject var storeKit: StoreKitManager
    @State private var isPurchased = false
    var product: Product
    var body: some View {
        HStack {
            InformationalLabel(title: product.displayName, subtitle: product.description)
            Spacer()
            if isPurchased {
                Image(systemName: "checkmark")
                    .fontWeight(.semibold)
            } else {
                Text(product.displayPrice)
                    .fontWeight(.semibold)
            }
        }
        .onChange(of: storeKit.purchasedTipJar) { _ in
            Task {
                isPurchased = (try? await storeKit.isPurchased(product)) ?? false
            }
        }
    }
}

struct TipJarSetting_Previews: PreviewProvider {
    static var previews: some View {
        TipJarSetting()
    }
}
