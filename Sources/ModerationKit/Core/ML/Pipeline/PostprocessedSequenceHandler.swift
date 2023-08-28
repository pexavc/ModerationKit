import Foundation

public class PostprocessedSequenceHandler<T1, T2> {
    
    let sequence : SequenceHandler<T2>
    let postprocessor : Runnable
    
    let context : HandlerContext
    
    public init(handlers: [Runnable], postprocessor: Runnable, context: HandlerContext) {
        self.sequence = SequenceHandler(handlers: handlers, context: context)
        self.postprocessor = postprocessor
        self.context = context
        
        if let postprocessor = self.postprocessor as? HandlerContextRecipient {
            postprocessor.invalidate(context: context)
        }
    }
    
    public func run(on input: Any) throws -> T1? {
        guard let state = HandlerState(context: context) else {
            throw HandlerRuntimeError.missingContext(sequence)
        }
        
        guard let sequenceResult = try sequence.run(on: input, state: state) else {
            throw HandlerRuntimeError.emptyResult(sequence.handlers.last!)
        }
        
        return try postprocessor.run(on: sequenceResult, state: state) as? T1
    }
    
    public func runBatch(on inputs: [Any]) throws -> T1? {
        guard let state = HandlerState(context: context) else {
            throw HandlerRuntimeError.missingContext(sequence)
        }
        
        guard let sequenceResult = try sequence.runBatch(on: inputs) else {
            throw HandlerRuntimeError.emptyResult(sequence.handlers.last!)
        }
        
        guard let result = try postprocessor.run(on: sequenceResult, state: state) else {
            throw HandlerRuntimeError.emptyResult(postprocessor)
        }
        
        return result as? T1
    }
    
}

extension PostprocessedSequenceHandler {
    
    public func printDebuggingGroups() {
        context.debugger.printDebuggingGroups()
    }
    
}
