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
    var body: some View {
        Form {
            Section {
                ForEach(viewModel.storeProducts) { item in
                    Button {
                        Task {
                            try await viewModel.purchase(item)
                        }
                    } label: {
                        TipJarItem(storeKit: viewModel, product: item)
                    }
                }
                Button("restorePurchases") {
                    Task {
                        try? await AppStore.sync()
                    }
                }
            } header: {
                Label("tipJarTitle", systemImage: "heart")
            } footer: {
                Text("tipJarFooter")
            }
        }
        .navigationTitle("tipJarTitle")
    }
}

private struct TipJarItem: View {
    @ObservedObject var storeKit: StoreKitManager
    @State private var isPurchased = false
    var product: Product
    var body: some View {
        HStack {
            InformationalToggle(title: product.displayName, subtitle: product.description)
            Spacer()
            if isPurchased {
                Image(systemName: "checkmark")
                    .fontWeight(.semibold)
            } else {
                Text(product.displayPrice)
                    .fontWeight(.semibold)
            }
        }
        .onChange(of: storeKit.purchasedTipJar) { newValue in
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
