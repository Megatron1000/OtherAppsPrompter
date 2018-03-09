//
//  ViewController.swift
//  OtherAppsPrompter
//
//  Created by Mark Bridges on 28/09/2017.
//  Copyright © 2017 Mark Bridges. All rights reserved.
//

import Cocoa

protocol SignUpPromptViewControllerDelegate: class {
    func signUpPromptViewController(signUpPromptViewController: SignUpPromptViewController, didFinishedWithState state: SignUpPromptViewController.SignUpState)
}

class SignUpPromptViewController: NSViewController {
    
    enum SignUpState {
        case didSignUp(email: String)
        case dismissed(suppressedFuturePrompts: Bool)
    }

    @IBOutlet private var titleTextField: NSTextField?
    @IBOutlet private var emailAddressTextField: NSTextField?
    @IBOutlet private var suppressionButton: NSButton?
    
    var appName: String?
    
    weak var delegate: SignUpPromptViewControllerDelegate?
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        titleTextField?.stringValue = "Welcome to " + (appName ?? "")
        view.window?.delegate = self
    }
    
    @IBAction private func twitterPressed(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://twitter.com/MarkBridgesApps")!)
    }
    
    @IBAction private func continuePressed(_ sender: Any) {
        self.view.window?.close()
    }
}

extension SignUpPromptViewController: NSWindowDelegate {
    
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
