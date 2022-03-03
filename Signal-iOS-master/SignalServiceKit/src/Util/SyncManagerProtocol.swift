//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation

@objc
public protocol SyncManagerProtocol: SyncManagerProtocolObjc, SyncManagerProtocolSwift {}

// MARK: -

@objc
public protocol SyncManagerProtocolObjc {
    func sendConfigurationSyncMessage()

    typealias Completion = () -> Void

    func syncLocalContact() -> AnyPromise
    func syncAllContacts() -> AnyPromise
    func syncContacts(forSignalAccounts signalAccounts: [SignalAccount]) -> AnyPromise
    func syncGroups(transaction: SDSAnyWriteTransaction, completion: @escaping Completion)

    func processIncomingConfigurationSyncMessage(_ syncMessage: SSKProtoSyncMessageConfiguration, transaction: SDSAnyWriteTransaction)
    func processIncomingContactsSyncMessage(_ syncMessage: SSKProtoSyncMessageContacts, transaction: SDSAnyWriteTransaction)
    func processIncomingGroupsSyncMessage(_ syncMessage: SSKProtoSyncMessageGroups, transaction: SDSAnyWriteTransaction)
    func processIncomingFetchLatestSyncMessage(_ syncMessage: SSKProtoSyncMessageFetchLatest, transaction: SDSAnyWriteTransaction)

    func sendFetchLatestProfileSyncMessage()
    func sendFetchLatestStorageManifestSyncMessage()
    func sendFetchLatestSubscriptionStatusSyncMessage()
}

// MARK: -

@objc
public protocol SyncManagerProtocolSwift {
    func sendKeysSyncMessage()

    func sendAllSyncRequestMessages() -> AnyPromise
    func sendAllSyncRequestMessages(timeout: TimeInterval) -> AnyPromise

    func processIncomingKeysSyncMessage(_ syncMessage: SSKProtoSyncMessageKeys, transaction: SDSAnyWriteTransaction)
    func sendKeysSyncRequestMessage(transaction: SDSAnyWriteTransaction)

    func processIncomingMessageRequestResponseSyncMessage(
        _ syncMessage: SSKProtoSyncMessageMessageRequestResponse,
        transaction: SDSAnyWriteTransaction
    )
    func sendMessageRequestResponseSyncMessage(thread: TSThread, responseType: OWSSyncMessageRequestResponseType)
    func sendMessageRequestResponseSyncMessage(thread: TSThread, responseType: OWSSyncMessageRequestResponseType, transaction: SDSAnyWriteTransaction)
}
