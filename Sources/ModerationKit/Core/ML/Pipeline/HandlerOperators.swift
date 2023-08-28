import Foundation

precedencegroup ChainingPrecedence {
    associativity: left
}

infix operator --> : ChainingPrecedence
infix operator --| : ChainingPrecedence

/* Basics sequential chaining */

public func --><T1 : Handler, T2 : Handler>(input : T1, output : T2) -> SequenceHandler<T2.Output> {
    return SequenceHandler(handlers: [input, output], context: HandlerContext())
}

public func --><T1, T2 : Handler>(input : SequenceHandler<T1>, output : T2) -> SequenceHandler<T2.Output> {
    return SequenceHandler(handlers: input.handlers + [output], context: input.context)
}

/* Keyed */

public func --><T1 : Handler>(input : T1, output : [String : Runnable]) -> SequenceHandler<KeyedHandler.Output> {
    let keyedHandler = KeyedHandler(handlers: output, context: HandlerContext())
    return SequenceHandler(handlers: [input, keyedHandler], context: keyedHandler.context)
}

public func --><T1>(input : SequenceHandler<T1>, output : [String : Runnable]) -> SequenceHandler<KeyedHandler.Output> {
    let keyedHandler = KeyedHandler(handlers: output, context: input.context)
    return SequenceHandler(handlers: input.handlers + [keyedHandler], context: input.context)
}

public func --><T1 : Handler>(input : [String : Runnable], output : T1) -> SequenceHandler<T1.Output> {
    let keyedHandler = KeyedHandler(handlers: input, context: HandlerContext())
    return SequenceHandler(handlers: [keyedHandler, output], context: keyedHandler.context)
}



/* Postprocessing */

public func --|<T1, T2 : Handler>(input : SequenceHandler<T1>, output : T2) -> PostprocessedSequenceHandler<T2.Output, T1> {
    return PostprocessedSequenceHandler(handlers: input.handlers, postprocessor: output, context: input.context)
}
