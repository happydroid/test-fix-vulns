import UIKit
import RxSwift
import RxOptional

class RegistrationEmailViewController: UIViewController, RegistrationSubController, UITextFieldDelegate {

    @IBOutlet var emailTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    var finished = PublishSubject<Void>()

    lazy var viewModel: GenericFormValidationViewModel = {
        let emailIsValid = self.emailTextField.rx.textInput.text.asObservable().replaceNilWith("").map(stringIsEmailAddress)
        return GenericFormValidationViewModel(isValid: emailIsValid, manualInvocation: self.emailTextField.rx_returnKey, finishedSubject: self.finished)
    }()


    fileprivate let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    lazy var bidDetails: BidDetails! = { self.navigationController!.fulfillmentNav().bidDetails }()

    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.text = bidDetails.newUser.email.value
        emailTextField.rx.textInput.text
            .asObservable()
            .takeUntil(viewWillDisappear)
            .bind(to: bidDetails.newUser.email)
            .disposed(by: rx.disposeBag)

        confirmButton.rx.action = viewModel.command

        emailTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        _viewWillDisappear.onNext(Void())
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        // Allow delete
        if (string.isEmpty) { return true }

        // the API doesn't accept spaces
        return string != " "
    }

    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> RegistrationEmailViewController {
        return storyboard.viewController(withID: .RegisterEmail) as! RegistrationEmailViewController
    }
}
