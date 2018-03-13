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

public class OtherAppsPrompter {
    
    let suppressPromptKey = "com.otherappsprompter.suppressed"
    
    let appIdentifier: String
    let appName: String
    let configURL: URL
    
    private var windowController: NSWindowController?
    
    lazy private var appService: AppService = AppService()
    private let defaults = UserDefaults.standard
    private var apps: [App]?
    
    var isPrepared: Bool {
        guard
            let apps = apps,
            apps.isEmpty == false else {
                return false
        }
    }
    
    var isSuppressed: Bool {
        return defaults.bool(forKey: suppressPromptKey)
    }
    
    // MARK: Initialisation
    
    public required init(appIdentifier: String, appName: String, configURL: URL) {
        self.appIdentifier = appIdentifier
        self.appName = appName
        self.configURL = configURL
    }
    
    public func prepareAndPresentUnlessSuppressed(completion: @escaping (() -> Result<()>)) {
        
    }
    
    public func prepare(completion: @escaping (() -> Result<()>)) {
        appService.getApps { result in
            switch result {
            case .success(let apps):
                completion(.success)
                
            case .failure(let error):
                completion(.failure)
                
            }
        }
    }
    
    public func present() {
        
        guard
            isPrepared else {
                fatalError("Asked to present before being prepared")
        }
        
        guard
            isSuppressed == false else {
            return
        }

        let frameworkBundle = Bundle(for: OtherAppsPrompter.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("OtherAppsPrompter.bundle")
        let resourceBundle = Bundle(url: bundleURL!)!
        let storyboard = NSStoryboard(name: NSStoryboard.Name("OtherAppsPrompter") , bundle: resourceBundle)
        
        windowController = storyboard.instantiateInitialController() as? NSWindowController
        let viewController = (windowController?.contentViewController as! OtherAppsViewController)
        viewController.delegate = self
        viewController.appName = appName
        
        windowController?.window?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
}

extension OtherAppsPrompter: OtherAppsViewControllerDelegate {
    
    func otherAppsViewController(otherAppsViewController: OtherAppsViewController, didSelectApp app: App) {
        
    }
    
    func otherAppsViewController(otherAppsViewController: OtherAppsViewController, didCloseWithState dismissState: OtherAppsViewController.DismissState) {
        
    }
    
}
