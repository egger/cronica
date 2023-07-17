//
//  StoreKitManager.swift
//  Story
//
//  Created by Alexandre Madeira on 05/01/23.
//

import StoreKit
import SwiftUI

@MainActor
class StoreKitManager: ObservableObject {
    @Published var storeProducts = [Product]()
    @Published var purchasedTipJar = [Product]()
    @Published var hasUserPurchased = false
    var hasLoadedProducts = false
    private let productDict: [String:String]
    var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        if let plistPath = Bundle.main.path(forResource: "ProductList", ofType: "plist"),
           let plist = FileManager.default.contents(atPath: plistPath) {
            productDict = (try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String:String]) ?? [:]
        } else {
            productDict = [:]
        }
        updateListenerTask = listenForTransaction()
        Task {
            await requestProducts()
            await updateConsumerUpdateStatus()
            hasLoadedProducts = true
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    @MainActor
    private func requestProducts() async {
        do {
            storeProducts = try await Product.products(for: productDict.values)
        } catch {
            let message = "Can't request products, error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "StoreKitManager.requestProducts()")
        }
    }
    
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateConsumerUpdateStatus()
            await transaction.finish()
            await MainActor.run {
                SettingsStore.shared.hasPurchasedTipJar = true
                withAnimation { self.hasUserPurchased = true }
            }
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    func isPurchased(_ product: Product) async throws -> Bool {
        if purchasedTipJar.contains(product) {
            SettingsStore.shared.hasPurchasedTipJar = true
        }
        return purchasedTipJar.contains(product)
    }
    
    func listenForTransaction() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updateConsumerUpdateStatus()
                    await transaction.finish()
                } catch {
                    CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                          for: "StoreKitManager.listenForTransaction()")
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, _):
            throw StoreKitError.unknown
        case .verified(let signedType):
            return signedType
        }
    }
    
    private func updateConsumerUpdateStatus() async {
        var purchasedTipJar = [Product]()
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if let jar = storeProducts.first(where: { $0.id == transaction.productID }) {
                    purchasedTipJar.append(jar)
                }
            } catch {
                CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                      for: "StoreKitManager.updateConsumerUpdateStatus.failed")
            }
        }
        self.purchasedTipJar = purchasedTipJar
    }
}
