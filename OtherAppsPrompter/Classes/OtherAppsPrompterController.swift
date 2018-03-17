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

public class OtherAppsPrompter {
    
    enum OtherAppsPrompterError: Error {
        case failedToPrefetchAllImages
    }
    
    let suppressPromptKey = "com.otherappsprompter.suppressed"
    let appStoreLinkFormat = "macappstore://itunes.apple.com/us/app/id%@?ls=1&mt=8"

    let appIdentifier: String
    let appName: String
    let configURL: URL
    let httpClient = HTTPClient()
    
    private var windowController: NSWindowController?
    
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
        return defaults.bool(forKey: suppressPromptKey)
    }
    
    // MARK: Initialisation
    
    public required init(appIdentifier: String, appName: String, configURL: URL) {
        self.appIdentifier = appIdentifier
        self.appName = appName
        self.configURL = configURL
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
        
        httpClient.makeNetworkRequest(with: request, completion: { result in
            
            switch result {
            case .success(let data):
                
                do {
                    let apps = try JSONDecoder().decode([App].self, from: data)
                    
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
            isPrepared else {
                fatalError("Asked to present before being prepared")
        }
        
        let frameworkBundle = Bundle(for: OtherAppsPrompter.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("OtherAppsPrompter.bundle")
        let resourceBundle = Bundle(url: bundleURL!)!
        let storyboard = NSStoryboard(name: NSStoryboard.Name("OtherAppsPrompter") , bundle: resourceBundle)
        
        windowController = storyboard.instantiateInitialController() as? NSWindowController
        let viewController = (windowController?.contentViewController as! OtherAppsViewController)
        viewController.delegate = self
        viewController.appName = appName
        viewController.apps = apps!
        
        windowController?.window?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
}

extension OtherAppsPrompter: OtherAppsViewControllerDelegate {
    
    func otherAppsViewController(otherAppsViewController: OtherAppsViewController, didSelectApp app: App) {
        
        let urlString = String(format: appStoreLinkFormat, app.appStoreID)
        guard let url = URL(string: urlString) else {
            fatalError("Failed to make url for app store")
        }
        
        NSWorkspace.shared.open(url)
    }
    
    func otherAppsViewController(otherAppsViewController: OtherAppsViewController, didCloseWithState dismissState: OtherAppsViewController.DismissState) {
        
    }
    
}
