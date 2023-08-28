import Foundation
import Metal
import CoreML

public struct MutliArrayToImage : Handler {
    public typealias Input = Any
    public typealias Output = ModerationImage
    
    public init() {
        
    }
    
    public func handle(input: Any, state: HandlerState) throws -> ModerationImage? {
        var array : MLMultiArray? = nil
        
        if let input = input as? [String : Any] {
            array = input.values.first as? MLMultiArray
        }
        else if let input = input as? MLMultiArray {
            array = input
        }
        
        guard let cgImage = array?.cgImage(min: -5, max: 5, channel: nil, axes: (2, 3, 4)) else {
            throw HandlerRuntimeError.genericError(self, "Cannot convert mask into CGImage")
        }
        
        return ModerationImage(cgImage: cgImage)
    }
    
}
