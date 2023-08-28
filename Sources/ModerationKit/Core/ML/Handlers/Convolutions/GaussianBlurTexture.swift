import Foundation
import Metal
import MetalPerformanceShaders

public class GaussianBlurTexture : Handler, HandlerContextRecipient {
    public typealias Input = MTLTexture
    public typealias Output = MTLTexture
    
    let sigma : Float
    
    var context : HandlerContext?
    var blur : MPSImageGaussianBlur?
    
    public init(sigma : Float) {
        self.sigma = sigma
    }
    
    public func invalidate(context: HandlerContext) {
        self.context = context
        self.blur = MPSImageGaussianBlur(device: context.device, sigma: sigma)
    }
    
    public func handle(input: MTLTexture, state: HandlerState) throws -> MTLTexture? {
        guard let _ = context, let blur = blur else {
            throw HandlerRuntimeError.missingContext(self)
        }
        
        var input = input
        blur.encode(commandBuffer: state.commandBuffer, inPlaceTexture: &input, fallbackCopyAllocator: nil)
        
        return input
    }
    
}
