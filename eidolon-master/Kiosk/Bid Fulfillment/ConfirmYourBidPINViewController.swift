import UIKit
import Moya
import RxSwift
import Action

class ConfirmYourBidPINViewController: UIViewController {

    fileprivate var _pin = Variable("")

    @IBOutlet var keypadContainer: KeypadContainerView!
    @IBOutlet var pinTextField: TextField!
    @IBOutlet var confirmButton: Button!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    lazy var pin: Observable<String> = { self.keypadContainer.stringValue }()
    lazy var networkModel: AdminCCBypassNetworkModelType = AdminCCBypassNetworkModel()

    var provider: Networking!

    // TODO: These all need to be changed.
    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> ConfirmYourBidPINViewController {
        return storyboard.viewController(withID: .ConfirmYourBidPIN) as! ConfirmYourBidPINViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pin
            .bind(to: _pin)
            .disposed(by: rx.disposeBag)

        pin
            .bind(to: pinTextField.rx.text)
            .disposed(by: rx.disposeBag)

        pin
            .mapToOptional()
            .bind(to: fulfillmentNav().bidDetails.bidderPIN)
            .disposed(by: rx.disposeBag)
        
        let pinExists = pin.map { $0.isNotEmpty }

        let bidDetails = fulfillmentNav().bidDetails
        let provider = self.provider

        bidDetailsPreviewView.bidDetails = bidDetails
        /// verify if we can connect with number & pin

        confirmButton.rx.action = CocoaAction(enabledIf: pinExists) { [weak self] _ in
            guard let me = self else { return .empty() }

            var loggedInProvider: AuthorizedNetworking!

            return bidDetails.authenticatedNetworking(provider: provider!)
                .do(onNext: { provider in
                    loggedInProvider = provider
                })
                .flatMap { provider -> Observable<AuthorizedNetworking> in
                    return provider
                        .request(ArtsyAuthenticatedAPI.me)
                        .filterSuccessfulStatusCodes()
                        .mapReplace(with: provider)
                }
                .flatMap { provider -> Observable<AuthorizedNetworking> in
                    return me
                        .fulfillmentNav()
                        .updateUserCredentials(loggedInProvider: loggedInProvider)
                        .mapReplace(with: provider)
                }
                .flatMap { provider -> Observable<Void> in
                    return me
                        .networkModel
                        .checkForAdminCCBypass(bidDetails.auctionID, authorizedNetworking: provider)
                        .flatMap { result -> Observable<Void> in

                            switch result {
                            case .skipCCRequirement:
                                // We should bypass the CC requirement and move directly onto placing the bid.
                                me.performSegue(.PINConfirmedhasCard)
                                return .empty()
                            case .requireCC:
                                // We must check for a CC, and collect one if necessary.
                                return me
                                    .checkForCreditCard(loggedInProvider: provider)
                                    .do(onNext: me.got)
                                    .map(void)
                            }
                        }
                }
                .do(onError: { error in
                    if let response = (error as? MoyaError)?.response {
                        let responseBody = NSString(data: response.data, encoding: String.Encoding.utf8.rawValue)
                        print("Error authenticating(\(response.statusCode)): \(String(describing: responseBody))")
                    }

                    me.showAuthenticationError()
                })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue == .ArtsyUserviaPINHasNotRegisteredCard {
            let viewController = segue.destination as! RegisterViewController
            viewController.provider = provider
        } else if segue == .PINConfirmedhasCard {
            let viewController = segue.destination as! LoadingViewController
            viewController.provider = provider
        }
    }

    @IBAction func forgotPINTapped(_ sender: AnyObject) {
        let auctionID = fulfillmentNav().auctionID ?? ""
        let number = fulfillmentNav().bidDetails.newUser.phoneNumber.value ?? ""
        let endpoint: ArtsyAPI = ArtsyAPI.bidderDetailsNotification(auctionID: auctionID, identifier: number)

        let alertController = UIAlertController(title: "Forgot PIN", message: "We have sent your bidder details to your device.", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Back", style: .cancel) { (_) in }
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true) {}

        provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .subscribe(onNext: { _ in

                // Necessary to subscribe to the actual observable. This should be in a CocoaAction of the button, instead.
                logger.log("Sent forgot PIN request")
            })
            .disposed(by: rx.disposeBag)
    }

    func showAuthenticationError() {
        confirmButton.flashError("Wrong PIN")
        pinTextField.flashForError()
        keypadContainer.resetAction.execute(Void())
    }

    func checkForCreditCard(loggedInProvider: AuthorizedNetworking) -> Observable<[Card]> {
        let endpoint = ArtsyAuthenticatedAPI.myCreditCards
        return loggedInProvider.request(endpoint).filterSuccessfulStatusCodes().mapJSON().mapTo(arrayOf: Card.self)
    }

    func got(cards: [Card]) {
        // If the cards list doesn't exist, or its .empty, then perform the segue to collect one.
        // Otherwise, proceed directly to the loading view controller to place the bid.
        if cards.isEmpty {
            performSegue(.ArtsyUserviaPINHasNotRegisteredCard)
        } else {
            performSegue(.PINConfirmedhasCard)
        }
    }
}

private extension ConfirmYourBidPINViewController {
    @IBAction func dev_loggedInTapped(_ sender: AnyObject) {
        self.performSegue(.PINConfirmedhasCard)
    }
}
