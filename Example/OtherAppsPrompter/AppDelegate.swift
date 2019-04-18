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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let otherAppsPrompter = OtherAppsPrompterController(appStoreID: "809625456",
                                                        appName: "My App",
                                                        configURL: Bundle.main.url(forResource: "OtherAppsConfig", withExtension: "json")!)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        otherAppsPrompter.prepare(completion: { result in
            print(result)
        })
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        
        if otherAppsPrompter.canPresent {
            otherAppsPrompter.present()
            return .terminateCancel
        }
        else {
            return .terminateNow
        }
        
    }


}

