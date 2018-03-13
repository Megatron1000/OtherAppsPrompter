//    MIT License
//
//    Copyright (c) 2018 Mark Bridges
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Cocoa

protocol OtherAppsViewControllerDelegate: class {
    func otherAppsViewController(otherAppsViewController: OtherAppsViewController, didSelectApp app: App)
    func otherAppsViewController(otherAppsViewController: OtherAppsViewController, didCloseWithState dismissState: OtherAppsViewController.DismissState)
}

class OtherAppsViewController: NSViewController {
    
    enum DismissState {
        case dontShowAgain
        case canShowAgain
    }

    @IBOutlet private var titleTextField: NSTextField?
    @IBOutlet private var descriptionTextField: NSTextField?
    @IBOutlet private var showMeAgainButton: NSButton!
    @IBOutlet private var collectionView: NSCollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    var appName: String?
    var apps = [App]()
    weak var delegate: OtherAppsViewControllerDelegate?
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        titleTextField?.stringValue = "Thanks for using " + (appName ?? "")
        view.window?.delegate = self
    }
    
}


extension OtherAppsViewController: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        
        let state: SignUpState
        let suppressed = (suppressionButton?.state == .on)
        
        if let email = emailAddressTextField?.stringValue, email.isEmpty == false {
            state = .didSignUp(email: email)
        } else {
            state = .dismissed(suppressedFuturePrompts: suppressed)
        }
        
        delegate?.signUpPromptViewController(signUpPromptViewController: self, didFinishedWithState: state)
    }
}
