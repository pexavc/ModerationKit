import Foundation
import Metal

#if os(iOS)
import UIKit
#endif

public struct TextureToImage : Handler {
    public typealias Input = MTLTexture
    public typealias Output = ModerationImage
    
    public init() {
        
    }
    
    public func handle(input: MTLTexture, state: HandlerState) throws -> ModerationImage? {
        //We need to make sure we have everything ready to have our texture exported
        state.synchronize(resource: input)
        state.insertCommandBufferExecutionBoundary()
          
        guard let cgImage = CGImage.fromTexture(input) else {
            throw HandlerRuntimeError.genericError(self, "Cannot convert image to texture")
        }

        return ModerationImage(cgImage: cgImage)
    }
    
}
