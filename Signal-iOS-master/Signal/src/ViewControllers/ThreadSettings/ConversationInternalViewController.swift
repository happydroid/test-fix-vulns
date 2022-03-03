//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation
import SignalServiceKit

@objc
public class ConversationInternalViewController: OWSTableViewController2 {

    private let thread: TSThread

    init(thread: TSThread) {
        self.thread = thread

        super.init()
    }

    // MARK: -

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = "Internal"

        updateTableContents()
    }

    private func updateTableContents() {
        AssertIsOnMainThread()

        let contents = OWSTableContents()
        let thread = self.thread

        let infoSection = OWSTableSection()
        self.databaseStorage.read { transaction in
            let section = infoSection
            let isThreadInProfileWhitelist = Self.profileManager.isThread(inProfileWhitelist: thread,
                                                                          transaction: transaction)
            section.add(.label(withText: String(format: "Whitelisted: %@",
                                                isThreadInProfileWhitelist ? "Yes" : "No")))

            if let contactThread = thread as? TSContactThread {
                let address = contactThread.contactAddress

                section.add(.copyableItem(label: "UUID",
                                          value: address.uuid?.uuidString,
                                          accessibilityIdentifier: "uuid"))

                section.add(.copyableItem(label: "Phone Number",
                                          value: address.phoneNumber,
                                          accessibilityIdentifier: "phoneNumber"))

                let profileKey = profileManager.profileKeyData(for: address, transaction: transaction)
                section.add(.copyableItem(label: "Profile Key",
                                          value: profileKey?.hexadecimalString,
                                          accessibilityIdentifier: "profile_key"))

                let identityKey = identityManager.recipientIdentity(for: address,
                                                                    transaction: transaction)?.identityKey
                section.add(.copyableItem(label: "Identity Key",
                                          value: identityKey?.hexadecimalString,
                                          accessibilityIdentifier: "identity_key"))

                var capabilities = [String]()
                if GroupManager.doesUserHaveGroupsV2Capability(address: address,
                                                               transaction: transaction) {
                    capabilities.append("gv2")
                }
                if GroupManager.doesUserHaveGroupsV2MigrationCapability(address: address,
                                                                        transaction: transaction) {
                    capabilities.append("migration")
                }
                if GroupManager.doesUserHaveAnnouncementOnlyGroupsCapability(address: address,
                                                                             transaction: transaction) {
                    capabilities.append("announcementGroup")
                }
                if GroupManager.doesUserHaveSenderKeyCapability(address: address,
                                                                transaction: transaction) {
                    capabilities.append("senderKey")
                }
                section.add(.label(withText: String(format: "Capabilities: %@",
                                                    capabilities.joined(separator: ", "))))

                let arePaymentsEnabled = paymentsHelper.arePaymentsEnabled(for: address,
                                                                     transaction: transaction)
                section.add(.label(withText: String(format: "Payments Enabled: %@",
                                                    arePaymentsEnabled ? "Yes" : "No")))

            } else if let groupThread = thread as? TSGroupThread {
                section.add(.copyableItem(label: "Group id",
                                          value: groupThread.groupId.hexadecimalString,
                                          accessibilityIdentifier: "group_id"))
            } else {
                owsFailDebug("Invalid thread.")
            }

            section.add(.copyableItem(label: "thread.uniqueId",
                                      value: thread.uniqueId,
                                      accessibilityIdentifier: "thread.uniqueId"))
        }
        contents.addSection(infoSection)

        if let contactThread = thread as? TSContactThread {
            let address = contactThread.contactAddress
            let actionSection = OWSTableSection()
            let section = actionSection

            section.add(.actionItem(withText: "Fetch Profile") {
                ProfileFetcherJob.fetchProfile(address: address, ignoreThrottling: true)
            })

            contents.addSection(actionSection)
        }

        self.contents = contents
    }

    // MARK: - Helpers

    public override func themeDidChange() {
        super.themeDidChange()
        updateTableContents()
    }
}
