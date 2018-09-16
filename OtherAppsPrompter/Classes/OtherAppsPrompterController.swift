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
import Kingfisher

public class OtherAppsPrompterController {
    
    enum OtherAppsPrompterError: Error {
        case failedToPrefetchAllImages
    }
    
    let suppressPromptKey = "com.otherappsprompter.suppressed"
    let initCountKey = "com.otherappsprompter.init-count"
    let appStoreLinkFormat = "macappstore://itunes.apple.com/us/app/id%@?ls=1&mt=8"

    let appStoreID: String
    let appName: String
    let configURL: URL
    let initialSuppressionCount: Int
    let httpClient = HTTPClient()
    
    // MARK: Logging Classes
    
    let eventLogger: EventTrackingLogger.Type?
    let debugLogger: DebugLogger.Type?
    
    private var windowController: NSWindowController?
    private var hasBeenPresented = false
    
    private let defaults = UserDefaults.standard
    private var apps: [App]?
    
    var isPrepared: Bool {
        guard
            let apps = apps,
            apps.isEmpty == false else {
                return false
        }
        return true
    }
    
    var isSuppressed: Bool {
        return defaults.bool(forKey: suppressPromptKey) || initCount <= initialSuppressionCount
    }
    
    public var canPresent: Bool {
        return isSuppressed == false && isPrepared && hasBeenPresented == false
    }
    
    private(set) var initCount: Int {
        get {
            return defaults.integer(forKey: initCountKey)
        }
        set {
            defaults.set(newValue, forKey: initCountKey)
        }
    }
    
    // MARK: Initialisation
    
    public required init(appStoreID: String,
                         appName: String,
                         configURL: URL,
                         initialSuppressionCount: Int = 2,
                         eventLogger: EventTrackingLogger.Type? = nil,
                         debugLogger: DebugLogger.Type? = nil) {
        self.appStoreID = appStoreID
        self.appName = appName
        self.configURL = configURL
        self.initialSuppressionCount = initialSuppressionCount
        self.eventLogger = eventLogger
        self.debugLogger = debugLogger
        
        initCount = initCount.advanced(by: 1)
    }
    
    public func prepareAndPresentUnlessSuppressed(completion: @escaping ((Result<()>) -> Void)) {
        
        guard
            isSuppressed == false else {
                return
        }
        
        if isPrepared {
            present()
            completion(.success(()))
        }
        else {
            prepare(completion: { [weak self] result in
                switch result {
                    
                case .success():
                    self?.present()
                    completion(.success(()))

                case .failure(let error):
                    completion(.failure(error))
                    
                }
            })
        }

    }
    
    public func prepare(completion: @escaping ((Result<Void>) -> Void)) {
        
        let request = URLRequest(url: configURL)
        
        httpClient.makeNetworkRequest(with: request, completion: { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let data):
                
                do {
                    let allDecodedApps = try JSONDecoder().decode([App].self, from: data)
                    
                    let apps = allDecodedApps.filter{ $0.appStoreID != strongSelf.appStoreID }
                    
                    let urls = apps.map{ $0.imageUrl }
                    let prefetcher = ImagePrefetcher(urls: urls) { [weak self] skippedResources, failedResources, completedResources in
                        
                        guard failedResources.isEmpty else {
                            completion(.failure(OtherAppsPrompterError.failedToPrefetchAllImages))
                            return
                        }
                        
                        self?.apps = apps
                        
                        completion(.success(()))
                        
                    }
                    prefetcher.start()
                    
                    
                } catch {
                    completion(.failure(error))
                    return
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
            
        })        
        
    }
    
    public func present() {
        
        guard
            canPresent else {
                fatalError("Asked to present before being prepared")
        }
        
        let frameworkBundle = Bundle(for: OtherAppsPrompterController.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("OtherAppsPrompter.bundle")
        let resourceBundle = Bundle(url: bundleURL!)!
        let storyboard = NSStoryboard(name: "OtherAppsPrompter" , bundle: resourceBundle)
        
        windowController = storyboard.instantiateInitialController() as? NSWindowController
        let viewController = (windowController?.contentViewController as! OtherAppsViewController)
        viewController.delegate = self
        viewController.appName = appName
        viewController.apps = apps!
        
        windowController?.window?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
        
        hasBeenPresented = true
    }
    
}

extension OtherAppsPrompterController: OtherAppsViewControllerDelegate {
    
    func otherAppsViewController(otherAppsViewController: OtherAppsViewController, didSelectApp app: App) {
        
        let urlString = String(format: appStoreLinkFormat, app.appStoreID)
        guard let url = URL(string: urlString) else {
            fatalError("Failed to make url for app store")
        }
        
        NSWorkspace.shared.open(url)
        
        eventLogger?.logEvent("other_app_viewed", parameters: ["app" : app.appName] )
    }
    
    func otherAppsViewController(otherAppsViewController: OtherAppsViewController, didCloseWithState dismissState: OtherAppsViewController.DismissState) {
        
        defaults.set((dismissState == .dontShowAgain), forKey: suppressPromptKey)
        
        eventLogger?.logEvent("other_app_promoter_dismissed", parameters: ["canShowAgain": (dismissState == .canShowAgain)])
    }
    
}
