//
//  Copyright © 2017 John Lewis plc. All rights reserved.
//

import Foundation

enum Result<ResultType> {
    case success(ResultType)
    case failure(Error)
}

extension Result {

    var result: ResultType? {

        guard case .success(let result) = self else {

            return nil
        }
        return result
    }

    var error: Error? {

        guard case .failure(let error) = self else {

            return nil
        }
        return error
    }

    var isSuccess: Bool {

        guard case .success = self else {

            return false
        }
        return true
    }
}
