import Foundation

public protocol Runnable {
    
    var label : String { get }
    
    func run(on input : Any, state : HandlerState) throws -> Any?
    
    func runBatch(on inputs: [Any], state : HandlerState) throws -> [Any]?
}
