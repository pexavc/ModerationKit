import Foundation

public class GenericFunction<T> : Handler, HandlerContextRecipient {
    public typealias Input = Any
    public typealias Output = T
    public typealias Function = (_ input : Input, _ context : HandlerContext, _ state : HandlerState) -> T?
    
    weak var context : HandlerContext? = nil
    
    fileprivate let function : Function
    
    public init(function : @escaping Function) {
        self.function = function
    }
    
    public func invalidate(context: HandlerContext) {
        self.context = context
    }
    
    public func handle(input: Any, state: HandlerState) throws -> T? {
        guard let context = context else {
            throw HandlerRuntimeError.missingContext(self)
        }
        
        return function(input, context, state)
    }
}
