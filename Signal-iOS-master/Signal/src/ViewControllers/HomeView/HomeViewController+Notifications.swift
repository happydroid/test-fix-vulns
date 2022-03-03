//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation

extension HomeViewController {

    public static let clearSearch = Notification.Name("clearSearch")

    @objc
    public func observeNotifications() {
        AssertIsOnMainThread()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(signalAccountsDidChange),
                                               name: .OWSContactsManagerSignalAccountsDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground),
                                               name: .OWSApplicationWillEnterForeground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: .OWSApplicationDidBecomeActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive),
                                               name: .OWSApplicationWillResignActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(registrationStateDidChange),
                                               name: .registrationStateDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(outageStateDidChange),
                                               name: OutageDetection.outageStateDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(localProfileDidChange),
                                               name: .localProfileDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(profileWhitelistDidChange),
                                               name: .profileWhitelistDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appExpiryDidChange),
                                               name: AppExpiry.AppExpiryDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(preferContactAvatarsPreferenceDidChange),
                                               name: SSKPreferences.preferContactAvatarsPreferenceDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(blockListDidChange),
                                               name: BlockingManager.blockListDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(uiContentSizeCategoryDidChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clearSearch),
                                               name: HomeViewController.clearSearch,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clearSearch),
                                               name: ReactionManager.localUserReacted,
                                               object: nil)

        databaseStorage.appendDatabaseChangeDelegate(self)
    }

    // MARK: -

    @objc
    private func preferContactAvatarsPreferenceDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        reloadTableDataAndResetCellContentCache()
    }

    @objc
    private func signalAccountsDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        // This is wasteful but this event is very rare.
        reloadTableDataAndResetCellContentCache()

        if !firstConversationCueView.isHidden {
            updateFirstConversationLabel()
        }
    }

    @objc
    private func registrationStateDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        updateReminderViews()
    }

    @objc
    private func outageStateDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        updateReminderViews()
    }

    @objc
    private func localProfileDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        updateBarButtonItems()
        showBadgeExpirationSheetIfNeeded()
    }

    @objc
    private func appExpiryDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        updateReminderViews()
    }

    @objc
    private func applicationWillEnterForeground(_ notification: NSNotification) {
        AssertIsOnMainThread()

        loadCoordinator.applicationWillEnterForeground()
    }

    @objc
    private func applicationDidBecomeActive(_ notification: NSNotification) {
        AssertIsOnMainThread()

        updateShouldBeUpdatingView()

        if !ExperienceUpgradeManager.presentNext(fromViewController: self) {
            presentGetStartedBannerIfNecessary()
        }
    }

    @objc
    private func applicationWillResignActive(_ notification: NSNotification) {
        AssertIsOnMainThread()

        updateShouldBeUpdatingView()
    }

    @objc
    private func profileWhitelistDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        // If profile whitelist just changed, we need to update the associated
        // thread to reflect the latest message request state.
        let address: SignalServiceAddress? = notification.userInfo?[kNSNotificationKey_ProfileAddress] as? SignalServiceAddress
        let groupId: Data? = notification.userInfo?[kNSNotificationKey_ProfileGroupId] as? Data

        let changedThreadId: String? = databaseStorage.read { transaction in
            if let address = address,
               address.isValid {
                return TSContactThread.getWithContactAddress(address, transaction: transaction)?.uniqueId
            } else if let groupId = groupId {
                return TSGroupThread.threadId(forGroupId: groupId, transaction: transaction)
            } else {
                return nil
            }
        }

        if let threadId = changedThreadId {
            self.loadCoordinator.scheduleLoad(updatedThreadIds: Set([threadId]))
        }
    }

    @objc
    private func blockListDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        // This is wasteful but this event is very rare.
        reloadTableDataAndResetCellContentCache()
    }

    @objc
    private func uiContentSizeCategoryDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        // This is expensive but this event is very rare.
        reloadTableDataAndResetCellContentCache()
    }

    @objc
    private func clearSearch(_ notification: NSNotification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            if let self = self {
                self.searchBar.delegate?.searchBarCancelButtonClicked?(self.searchBar)
            }
        }
    }
}

// MARK: - Notifications

extension HomeViewController: DatabaseChangeDelegate {

    public func databaseChangesDidUpdate(databaseChanges: DatabaseChanges) {
        AssertIsOnMainThread()

        BenchManager.startEvent(title: "uiDatabaseUpdate", eventId: "uiDatabaseUpdate")

        if databaseChanges.didUpdateModel(collection: TSPaymentModel.collection()) {
            updateUnreadPaymentNotificationsCountWithSneakyTransaction()
        }

        if !databaseChanges.threadUniqueIds.isEmpty {
            self.loadCoordinator.scheduleLoad(updatedThreadIds: databaseChanges.threadUniqueIds)
        }
    }

    public func databaseChangesDidUpdateExternally() {
        AssertIsOnMainThread()

        Logger.verbose("")

        // External database modifications can't be converted into incremental updates,
        // so rebuild everything.  This is expensive and usually isn't necessary, but
        // there's no alternative.
        self.loadCoordinator.scheduleHardReset()
    }

    public func databaseChangesDidReset() {
        AssertIsOnMainThread()

        // This should only happen if we need to recover from an error in the
        // database change observation pipeline.  This should never occur,
        // but when it does we need to rebuild everything.  This is expensive,
        // but there's no alternative.
        self.loadCoordinator.scheduleHardReset()
    }
}
