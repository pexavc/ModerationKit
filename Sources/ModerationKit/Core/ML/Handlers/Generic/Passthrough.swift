import Foundation

public struct Passthrough : Handler {
    public typealias Input = Any
    public typealias Output = Any
    
    public func handle(input: Any, state: HandlerState) throws -> Any? {
        return input
    }
}
