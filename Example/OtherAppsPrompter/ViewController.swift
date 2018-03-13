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
import OtherAppsPrompter

class ViewController: NSViewController {
    
    let mailingListPrompter = OtherAppsPrompterPrompter(suiteName: "the user default suite's identifier",
                                                  apiKey: "your mailgun api key",
                                                  domain: "the mailgun api",
                                                  appIdentifier: Bundle.main.bundleIdentifier!,
                                                  appName: Bundle.main.displayName!
                                                  )

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mailingListPrompter.showPromptIfNecessary(completion: { result in
            
            switch result {
                
            case .signedUp(let email):
                break
                
            case .registeredNewAppIdentifier(let email):
                break
                
            case .emailAndAppIdentifierAlreadyRegistered(let email):
                break
                
            case .failed(let email, let error):
                break
                
            case .didntSignUp:
                break
                
            case .suppressed:
                break
                
            }
            
        })
    }

}

