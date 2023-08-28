import Foundation
import Metal

public protocol Handler : Runnable {
    associatedtype Input
    associatedtype Output
    
    ///The debugging label of the handler.
    var label : String { get }

    ///Handling input and returning the appropriate output.
    func handle(input : Input, state : HandlerState) throws -> Output?
}

extension Handler {
    
    public var label : String {
        return String(describing: Self.self)
    }
    
    public func run(on anyInput: Any, state: HandlerState) throws -> Any? {
        guard let input = anyInput as? Input else {
            throw HandlerRuntimeError.typeMismatch(self, type(of: anyInput), Input.self)
        }
        
        state.context.debugger.pushGroup(name: label)
        let output = try handle(input: input, state: state)
        state.context.debugger.popGroup()
        
        return output
    }
    
    public func runBatch(on inputs: [Any], state: HandlerState) throws -> [Any]? {
        var results = [Any]()
        
        for input in inputs {
            guard let result = try run(on: input, state: state) else {
                return nil
            }
            
            results.append(result)
        }
        
        return results
    }
    
}
