//
//  Copyright © 2017 John Lewis plc. All rights reserved.
//

import Cocoa

public extension Bundle {
    
    public var displayName: String? {
        return infoDictionary?["CFBundleName"] as? String
    }

}
