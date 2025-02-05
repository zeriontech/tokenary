// ∅ 2025 lil org

import Cocoa
import WalletCore

class ApproveViewController: NSViewController {
    
    @IBOutlet weak var buttonsStackView: NSStackView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet var metaTextView: NSTextView!
    @IBOutlet weak var okButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var peerNameLabel: NSTextField!
    @IBOutlet weak var peerLogoImageView: NSImageView! {
        didSet {
            peerLogoImageView.wantsLayer = true
            peerLogoImageView.layer?.backgroundColor = NSColor.systemGray.withAlphaComponent(0.5).cgColor
            peerLogoImageView.layer?.cornerRadius = 5
        }
    }
    
    private var subject: ApprovalSubject!
    private var approveTitle: String!
    private var meta: String!
    private var account: Account!
    private var completion: ((Bool) -> Void)!
    private var didCallCompletion = false
    private var peerMeta: PeerMeta?
    private var walletId: String!
    
    static func with(subject: ApprovalSubject, meta: String, account: Account, walletId: String, peerMeta: PeerMeta?, completion: @escaping (Bool) -> Void) -> ApproveViewController {
        let new = instantiate(ApproveViewController.self)
        new.walletId = walletId
        new.completion = completion
        new.subject = subject
        new.meta = meta
        new.account = account
        new.approveTitle = subject.title
        new.peerMeta = peerMeta
        return new
    }
    
    func setMeta(_ meta: String) {
        self.meta = meta
        updateDisplayedMeta()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        okButton.title = Strings.ok
        cancelButton.title = Strings.cancel
        
        titleLabel.stringValue = approveTitle
        updateDisplayedMeta()
        if let peer = peerMeta {
            peerNameLabel.stringValue = peer.name
            if let urlString = peer.iconURLString, let url = URL(string: urlString) {
                peerLogoImageView.kf.setImage(with: url) { [weak peerLogoImageView] result in
                    if case .success = result {
                        peerLogoImageView?.layer?.backgroundColor = NSColor.clear.cgColor
                        peerLogoImageView?.layer?.cornerRadius = 0
                    }
                }
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.delegate = self
        view.window?.makeFirstResponder(view)
    }
    
    func enableWaiting() {
        guard subject == .approveTransaction else { return }
        buttonsStackView.isHidden = true
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(nil)
        titleLabel.stringValue = Strings.sendingTransaction
    }
    
    private func updateDisplayedMeta() {
        let fullString = NSMutableAttributedString(attributedString: NSAttributedString.accountImageAttachment(account: account))
        fullString.insert(NSAttributedString(string: " ", attributes: [.font: NSFont.systemFont(ofSize: 5)]), at: 0)
        let addressString = NSAttributedString(string: " " + account.nameOrCroppedAddress(walletId: walletId) + "\n\n",
                                               attributes: [.font: NSFont.systemFont(ofSize: 13), .foregroundColor: NSColor.labelColor])
        let metaString = NSAttributedString(string: meta, attributes: [.font: NSFont.systemFont(ofSize: 13), .foregroundColor: NSColor.labelColor])
        fullString.append(addressString)
        fullString.append(metaString)
        metaTextView.textStorage?.setAttributedString(fullString)
    }
    
    private func callCompletion(result: Bool) {
        if !didCallCompletion {
            didCallCompletion = true
            completion(result)
        }
    }

    @IBAction func actionButtonTapped(_ sender: Any) {
        callCompletion(result: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: NSButton) {
        callCompletion(result: false)
    }
    
}

extension ApproveViewController: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        callCompletion(result: false)
    }
    
}
