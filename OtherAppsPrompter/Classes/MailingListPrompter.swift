import Cocoa

public class OtherAppsPrompterPrompter {
    
    public enum OtherAppsPrompterPromptResult {
        case signedUp(email: String)
        case registeredNewAppIdentifier(email: String)
        case emailAndAppIdentifierAlreadyRegistered(email: String)
        case failed(email: String, error: Error)
        case didntSignUp
        case suppressed
    }
    
    public typealias OtherAppsPrompterPrompterCompletion = ((OtherAppsPrompterPromptResult) -> ())
    
    let suiteName: String
    let apiKey: String
    let domain: String
    let appIdentifier: String
    let appName: String
    
    private let emailAddressKey = "emailAddress"
    private let supressOtherAppsPrompterPromptKey = "supressOtherAppsPrompterPrompt1"
    
    private var mailingListPrompterCompletion: OtherAppsPrompterPrompterCompletion?
    
    private var windowController: NSWindowController?
    
    lazy private var mailingListService: MailGunService = {
        return MailGunService(apiKey: self.apiKey, domain: self.domain)
    }()
    
    lazy private var defaults: UserDefaults = {
        guard let defaults =  UserDefaults(suiteName: suiteName) else {
            fatalError("Unabled to initialise user defaults with suite named: \(suiteName)")
        }
        return defaults
    }()
    
    // MARK: Initialisation
    
    public required init(suiteName: String, apiKey: String, domain: String, appIdentifier: String, appName: String) {
        self.suiteName = suiteName
        self.apiKey = apiKey
        self.domain = domain
        self.appIdentifier = appIdentifier
        self.appName = appName
    }
    
    public func showPromptIfNecessary(completion: @escaping OtherAppsPrompterPrompterCompletion) {
        
        mailingListPrompterCompletion = completion
        
        if let existingEmail = defaults.string(forKey: emailAddressKey) {
            addAppIdentifier(toEmail: existingEmail)
        }
        else if defaults.bool(forKey: supressOtherAppsPrompterPromptKey) != true {
            
            let frameworkBundle = Bundle(for: OtherAppsPrompterPrompter.self)
            let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("OtherAppsPrompter.bundle")
            let resourceBundle = Bundle(url: bundleURL!)!
            let storyboard = NSStoryboard(name: NSStoryboard.Name("OtherAppsPrompter") , bundle: resourceBundle)
            
            windowController = storyboard.instantiateInitialController() as? NSWindowController
            let viewController = (windowController?.contentViewController as! SignUpPromptViewController)
            viewController.delegate = self
            viewController.appName = appName
            
            windowController?.window?.makeKeyAndOrderFront(self)
            NSApp.activate(ignoringOtherApps: true)
        }
        else {
            mailingListPrompterCompletion?(.suppressed)
        }
        
    }
    
    private func addAppIdentifier(toEmail email: String) {
        
        mailingListService.getMember(forEmail: email) { [weak self] result in
            
            switch result {
            case .success(let member):
                self?.addAppIdentifier(toMember: member)
                
            case .failure(let error):
                self?.mailingListPrompterCompletion?(.failed(email: email, error: error))
                
            }
            
        }
        
    }
    
    private func addAppIdentifier(toMember member: Member) {
        
        if member.appIdentifiers.contains(appIdentifier) == false {
            
            var newIdentifiers = member.appIdentifiers
            newIdentifiers.insert(appIdentifier)
            
            let updatedMember = Member(address: member.address, appIdentifiers: newIdentifiers)
            
            mailingListService.updateMember(updatedMember, withCompletion: { [weak self] result in
                
                switch result {
                case .success():
                    self?.mailingListPrompterCompletion?(.registeredNewAppIdentifier(email: member.address))
                    
                case .failure(let error):
                    self?.mailingListPrompterCompletion?(.failed(email: member.address, error: error))
                    
                }
                
            })
        }
        else {
            mailingListPrompterCompletion?(.emailAndAppIdentifierAlreadyRegistered(email: member.address))
        }
    }
    
}

extension OtherAppsPrompterPrompter: SignUpPromptViewControllerDelegate {
    
    func signUpPromptViewController(signUpPromptViewController: SignUpPromptViewController, didFinishedWithState state: SignUpPromptViewController.SignUpState) {
        
        switch state {
        case .didSignUp(let email):
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            guard NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email) else {
                print("Email doesn't appear to be valid: \(email)")
                return
            }
            
            let member = Member(address: email, appIdentifiers: Set([appIdentifier]))
            defaults.setValue(email, forKey: emailAddressKey)
            
            mailingListService.addMember(member) { [weak self] result in
                
                switch result {
                case .success():
                    self?.mailingListPrompterCompletion?(.signedUp(email: email))
                    
                case .failure(let error):
                    self?.mailingListPrompterCompletion?(.failed(email: email, error: error))
                    
                }
                
            }
            
        case .dismissed(let suppressedFuturePrompts):
            
            if suppressedFuturePrompts {
                defaults.setValue(true, forKey: supressOtherAppsPrompterPromptKey)
            }
            
            if defaults.value(forKey: emailAddressKey) == nil {
                mailingListPrompterCompletion?(.didntSignUp)
            }
            
        }
        
    }
    
    
    
}
