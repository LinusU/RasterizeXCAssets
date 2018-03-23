import Foundation

import Commander
import PromiseKit

public func command<A:ArgumentDescriptor, A1:ArgumentDescriptor, A2:ArgumentDescriptor>(_ descriptor: A, _ descriptor1:A1, _ descriptor2:A2, _ closure:@escaping (A.ValueType, A1.ValueType, A2.ValueType) throws -> Promise<Void>) -> CommandType {
    return command(descriptor, descriptor1, descriptor2) { (value0: A.ValueType, value1: A1.ValueType, value2: A2.ValueType) throws -> () in
        firstly {
            try closure(value0, value1, value2)
        }.done { _ in
            exit(0)
        }.catch { err in
            command({ throw err }).run()
        }

        CFRunLoopRun()
    }
}
