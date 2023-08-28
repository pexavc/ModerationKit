import Foundation

public enum HandlerRuntimeError : Error {
    case emptyResult(Runnable)
    case typeMismatch(Runnable, Any, Any)
    case genericError(Runnable, Any)
    case missingContext(Runnable)
    
    public var description: String {
        switch self {
            
        case .missingContext(let handler):
            return "HandlerRuntimeError: missing graphics context in \(handler.label)"
            
        case .genericError(let handler, let message):
            return "HandlerRuntimeError: \(message) in \(handler.label)"
            
        case .emptyResult(let handler):
            return "HandlerRuntimeError: empty result in \(handler.label)"
            
        case .typeMismatch(let handler, let gotType, let expectedType):
            return "HandlerRuntimeError: type mismatch in \(handler.label), expected \(expectedType), got \(gotType)"
            
        }
    }
}
