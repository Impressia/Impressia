//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import Foundation
import StoreKit

@MainActor
final class TipsStore: ObservableObject {

    /// Products are registered in AppStore connect (and for development in InAppPurchaseStoreKitConfiguration.storekit file).
    @Published private(set) var items = [Product]()
    
    /// Status of the purchase.
    @Published private(set) var status: ActionStatus? {
        didSet{
            switch status {
            case .failed:
                self.hasError = true
            default:
                self.hasError = false
            }
        }
    }

    /// True when error during purchase occures.
    @Published var hasError = false
    
    /// Error during purchase.
    var error: PurchaseError? {
        switch status {
        case .failed(let error):
            return error
        default:
            return nil
        }
    }
    
    /// Listener responsible for waiting for new events from AppStore (when transaction didn't finish during the purchase).
    private var transactionListener: Task<Void, Error>?
    
    init() {
        transactionListener = configureTransactionListener()
        Task { [weak self] in
            await self?.retrieve()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    /// Purchase new product.
    public func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            try await self.handlePurchase(from: result)
        } catch {
            self.status = .failed(.system(error))
            ErrorService.shared.handle(error, message: "Purchase failed.", showToastr: false)
        }
    }
    
    /// Reset status of the purchase/action.
    public func reset() {
        self.status = nil
    }
    
    /// Handle purchase result.
    private func handlePurchase(from result: Product.PurchaseResult) async throws {
        switch result {
        case .success(let verificationResult):
            let transaction = try self.checkVerified(verificationResult)

            self.status = .successful
            await transaction.finish()
        case .userCancelled:
            print("User click cancel before their transaction started.")
        case .pending:
            print("User needs to complete some action on their account before their complete the purchase.")
        default:
            break
        }
    }
    
    /// We have to verify if transaction ends successfuly.
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let signedType):
            return signedType
        }
    }
    
    /// Configure listener of interrupted transactions.
    private func configureTransactionListener() -> Task<Void, Error> {
        Task.detached(priority: .background) { @MainActor [weak self] in
            do {
                for await result in Transaction.updates {
                    let transaction = try self?.checkVerified(result)
                    self?.status = .successful
                    await transaction?.finish()
                }
            } catch {
                self?.status = .failed(.system(error))
                ErrorService.shared.handle(error, message: "Cannot configure transaction listener.", showToastr: false)
            }
        }
    }
    
    /// Retrieve products from Apple store.
    private func retrieve() async {
        do {
            let products = try await Product.products(for: ProductIdentifiers.allCases.map({ $0.rawValue }))
                .sorted(by: { $0.price < $1.price })
            
            self.items = products
        } catch {
            self.status = .failed(.system(error))
            ErrorService.shared.handle(error, message: "Cannot download in-app products.", showToastr: false)
        }
    }
}

extension TipsStore {
    public enum ActionStatus: Equatable {
        case successful
        case failed(PurchaseError)
        
        public static func == (lhs: TipsStore.ActionStatus, rhs: TipsStore.ActionStatus) -> Bool {
            switch (lhs, rhs) {
            case (.successful, .successful):
                return true
            case (let .failed(lhsError), let .failed(rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
}
