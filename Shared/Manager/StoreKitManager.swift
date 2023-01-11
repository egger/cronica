//
//  StoreKitManager.swift
//  Story
//
//  Created by Alexandre Madeira on 05/01/23.
//

import StoreKit

class StoreKitManager: ObservableObject {
    @Published var storeProducts = [Product]()
    @Published var purchasedTipJar = [Product]()
    @Published var hasLoadedProducts = false
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
        }
        hasLoadedProducts = true
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    @MainActor
    private func requestProducts() async {
        do {
            storeProducts = try await Product.products(for: productDict.values)
        } catch {
            let message = """
Can't request products, error: \(error.localizedDescription)
"""
            CronicaTelemetry.shared.handleMessage(message,
                                                  for: "StoreKitManager.requestProducts()")
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateConsumerUpdateStatus()
            await transaction.finish()
            let message = "Transaction of \(transaction.productID) has successfully."
            CronicaTelemetry.shared.handleMessage(message, for: "StoreKitManager.purchase()")
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    func isPurchased(_ product: Product) async throws -> Bool {
        return purchasedTipJar.contains(product)
    }
    
    func listenForTransaction() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateConsumerUpdateStatus()
                    await transaction.finish()
                } catch {
                    print(error.localizedDescription)
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
    
    @MainActor
    private func updateConsumerUpdateStatus() async {
        var purchasedTipJar = [Product]()
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if let jar = storeProducts.first(where: { $0.id == transaction.productID }) {
                    purchasedTipJar.append(jar)
                }
            } catch {
                let message = "\(error.localizedDescription)"
                CronicaTelemetry.shared.handleMessage(message, for: "StoreKitManager.updateConsumerUpdateStatus()")
            }
        }
        self.purchasedTipJar = purchasedTipJar
    }
}
