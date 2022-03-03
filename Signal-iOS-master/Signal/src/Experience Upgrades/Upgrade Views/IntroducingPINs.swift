//
//  Copyright (c) 2022 Open Whisper Systems. All rights reserved.
//

import Foundation
import SafariServices

class IntroducingPinsMegaphone: MegaphoneView {
    init(experienceUpgrade: ExperienceUpgrade, fromViewController: UIViewController) {
        super.init(experienceUpgrade: experienceUpgrade)

        titleText = NSLocalizedString("PINS_MEGAPHONE_TITLE", comment: "Title for PIN megaphone when user doesn't have a PIN")
        bodyText = NSLocalizedString("PINS_MEGAPHONE_BODY", comment: "Body for PIN megaphone when user doesn't have a PIN")
        imageName = "PIN_megaphone"

        let primaryButtonTitle = NSLocalizedString("PINS_MEGAPHONE_ACTION", comment: "Action text for PIN megaphone when user doesn't have a PIN")

        let primaryButton = MegaphoneView.Button(title: primaryButtonTitle) { [weak self] in
            let vc = PinSetupViewController.creating { _, error in
                if let error = error {
                    Logger.error("failed to create pin: \(error)")
                } else {
                    // success
                    self?.markAsComplete()
                }
                fromViewController.navigationController?.popToViewController(fromViewController, animated: true) {
                    fromViewController.navigationController?.setNavigationBarHidden(false, animated: false)
                    self?.dismiss(animated: false)
                    self?.presentToast(
                        text: NSLocalizedString("PINS_MEGAPHONE_TOAST", comment: "Toast indicating that a PIN has been created."),
                        fromViewController: fromViewController
                    )
                }
            }

            fromViewController.navigationController?.pushViewController(vc, animated: true)
        }

        let secondaryButton = snoozeButton(fromViewController: fromViewController) {
            let daysRemaining = ExperienceUpgradeManager.splashStartDay - experienceUpgrade.daysSinceFirstViewed
            assert(daysRemaining > 0)

            let toastFormat = NSLocalizedString("PINS_MEGAPHONE_SNOOZE_TOAST_FORMAT",
                                    comment: "Toast indication that the user will be reminded later to setup their PIN. Embeds {{time until mandatory}}")

            return String(format: toastFormat, daysRemaining)
        }

        setButtons(primary: primaryButton, secondary: secondaryButton)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
