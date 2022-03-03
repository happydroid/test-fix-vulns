//
//  Copyright (c) 2022 Open Whisper Systems. All rights reserved.
//

import Foundation
import SignalMessaging

public enum MessageRecipient: Equatable {
    case contact(_ address: SignalServiceAddress)
    case group(_ groupThreadId: String)
}

// MARK: -

public protocol ConversationItem {
    var messageRecipient: MessageRecipient { get }
    var title: String { get }
    var image: UIImage? { get }
    var isBlocked: Bool { get }
    var disappearingMessagesConfig: OWSDisappearingMessagesConfiguration? { get }

    func getExistingThread(transaction: SDSAnyReadTransaction) -> TSThread?
    func getOrCreateThread(transaction: SDSAnyWriteTransaction) -> TSThread?
}

// MARK: -

struct RecentConversationItem {
    enum ItemType {
        case contact(_ item: ContactConversationItem)
        case group(_ item: GroupConversationItem)
    }

    let backingItem: ItemType
    var unwrapped: ConversationItem {
        switch backingItem {
        case .contact(let contactItem):
            return contactItem
        case .group(let groupItem):
            return groupItem
        }
    }
}

// MARK: -

extension RecentConversationItem: ConversationItem {
    var messageRecipient: MessageRecipient {
        return unwrapped.messageRecipient
    }

    var title: String {
        return unwrapped.title
    }

    var image: UIImage? {
        return unwrapped.image
    }

    var isBlocked: Bool {
        return unwrapped.isBlocked
    }

    var disappearingMessagesConfig: OWSDisappearingMessagesConfiguration? {
        return unwrapped.disappearingMessagesConfig
    }

    func getExistingThread(transaction: SDSAnyReadTransaction) -> TSThread? {
        return unwrapped.getExistingThread(transaction: transaction)
    }

    func getOrCreateThread(transaction: SDSAnyWriteTransaction) -> TSThread? {
        return unwrapped.getOrCreateThread(transaction: transaction)
    }
}

// MARK: -

struct ContactConversationItem: Dependencies {
    let address: SignalServiceAddress
    let isBlocked: Bool
    let disappearingMessagesConfig: OWSDisappearingMessagesConfiguration?
    let contactName: String
    let comparableName: String
}

// MARK: -

extension ContactConversationItem: Comparable {
    public static func < (lhs: ContactConversationItem, rhs: ContactConversationItem) -> Bool {
        return lhs.comparableName < rhs.comparableName
    }
}

// MARK: -

extension ContactConversationItem: ConversationItem {

    var messageRecipient: MessageRecipient {
        .contact(address)
    }

    var title: String {
        guard !address.isLocalAddress else {
            return MessageStrings.noteToSelf
        }

        return contactName
    }

    var image: UIImage? {
        databaseStorage.read { transaction in
            self.contactsManagerImpl.avatarImage(forAddress: self.address,
                                                 shouldValidate: true,
                                                 transaction: transaction)
        }
    }

    func getExistingThread(transaction: SDSAnyReadTransaction) -> TSThread? {
        return TSContactThread.getWithContactAddress(address, transaction: transaction)
    }

    func getOrCreateThread(transaction: SDSAnyWriteTransaction) -> TSThread? {
        return TSContactThread.getOrCreateThread(withContactAddress: address, transaction: transaction)
    }
}

// MARK: -

struct GroupConversationItem: Dependencies {
    let groupThreadId: String
    let isBlocked: Bool
    let disappearingMessagesConfig: OWSDisappearingMessagesConfiguration?

    // We don't want to keep this in memory, because the group model
    // can be very large.
    var groupThread: TSGroupThread? {
        databaseStorage.read { transaction in
            return TSGroupThread.anyFetchGroupThread(uniqueId: groupThreadId, transaction: transaction)
        }
    }

    var groupModel: TSGroupModel? {
        groupThread?.groupModel
    }
}

// MARK: -

extension GroupConversationItem: ConversationItem {
    var messageRecipient: MessageRecipient {
        .group(groupThreadId)
    }

    var title: String {
        guard let groupThread = groupThread else { return TSGroupThread.defaultGroupName }
        return groupThread.groupNameOrDefault
    }

    var image: UIImage? {
        guard let groupThread = groupThread else { return nil }
        return databaseStorage.read { transaction in
            Self.avatarBuilder.avatarImage(forGroupThread: groupThread,
                                           diameterPoints: AvatarBuilder.standardAvatarSizePoints,
                                           transaction: transaction)
        }
    }

    func getExistingThread(transaction: SDSAnyReadTransaction) -> TSThread? {
        return TSGroupThread.anyFetchGroupThread(uniqueId: groupThreadId, transaction: transaction)
    }

    func getOrCreateThread(transaction: SDSAnyWriteTransaction) -> TSThread? {
        return getExistingThread(transaction: transaction)
    }
}
