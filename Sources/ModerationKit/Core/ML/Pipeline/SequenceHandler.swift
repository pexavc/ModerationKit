import Foundation

public class SequenceHandler<T> : Handler {
    public typealias Input = Any
    public typealias Output = T
    
    public let handlers : [Runnable]
    public let context : HandlerContext
    
    public init(handlers : [Runnable], context: HandlerContext) {
        self.handlers = handlers
        self.context = context
        
        self.handlers.forEach {
            ($0 as? HandlerContextRecipient)?.invalidate(context: context)
        }
    }
    
    public func handle(input: Any, state: HandlerState) throws -> T? {
        var output = input
        
        context.debugger.pushGroup(name: "Sequence")
        
        for handler in handlers {
            guard let handlerOutput = try handler.run(on: output, state: state) else {
                throw HandlerRuntimeError.emptyResult(handler)
            }
            
            output = handlerOutput
        }
        
        state.insertCommandBufferExecutionBoundary()
        
        context.debugger.popGroup()

        return output as? T
    }
    
    public func handle(inputs : [Any], state : HandlerState) throws -> [T]? {
        var outputs = inputs
        
        context.debugger.pushGroup(name: "Sequence (Array)")
        
        for handler in handlers {
            guard let handlerOutputs = try handler.runBatch(on: outputs, state: state) else {
                throw HandlerRuntimeError.emptyResult(handler)
            }
            
            outputs = handlerOutputs
        }
        
        state.insertCommandBufferExecutionBoundary()
        
        context.debugger.popGroup()
        
        return outputs as? [T]
    }
    
    public func run(on input: Any) throws -> T? {
        guard let state = HandlerState(context: context) else {
            throw HandlerRuntimeError.missingContext(self)
        }
        
        return try handle(input: input, state: state)
    }
    
    public func runBatch(on inputs: [Any]) throws -> [T]? {
        guard let state = HandlerState(context: context) else {
            throw HandlerRuntimeError.missingContext(self)
        }
        
        return try handle(inputs: inputs, state: state)
    }
    
}

extension SequenceHandler {
    
    public func printDebuggingGroups() {
        context.debugger.printDebuggingGroups()
    }
    
}


