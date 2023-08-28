import Foundation

public struct KeyedHandler : Handler {
    public typealias Input = Any
    public typealias Output = [String : Any]
    
    public let context : HandlerContext
    public let handlers : [String : Runnable]
    
    public init(handlers : [String : Runnable], context : HandlerContext) {
        self.handlers = handlers
        self.context = context
        
        self.handlers.forEach {
            ($0.value as? HandlerContextRecipient)?.invalidate(context: context)
        }
    }
    
    public func handle(input: Any, state: HandlerState) throws -> [String : Any]? {
        var output = [String : Any]()
        
        for (name, handler) in handlers {
            guard let handlerOutput = try handler.run(on: input, state: state) else {
                throw HandlerRuntimeError.emptyResult(handler)
            }
     
            output[name] = handlerOutput
        }
        
        state.insertCommandBufferExecutionBoundary()
        
        return output
    }
}
