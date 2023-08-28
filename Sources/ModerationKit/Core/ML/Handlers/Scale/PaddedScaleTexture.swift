import Foundation
import Metal

#if os(iOS)
import UIKit
#endif


public class PaddedScaleTexture : Handler, HandlerContextRecipient {
    public typealias Input = MTLTexture
    public typealias Output = MTLTexture
    
    let width : Int
    let height : Int
    
    var context : HandlerContext?
    var kernel : MetalKernel?

    public init(width : Int, height : Int) {
        self.width = width
        self.height = height
    }
    
    public func invalidate(context: HandlerContext) {
        self.context = context
        self.kernel = MetalKernel(named: "PaddedScaleTexture", context: context)
    }
    
    public func handle(input: MTLTexture, state: HandlerState) throws -> MTLTexture? {
        guard let kernel = kernel else {
            throw HandlerRuntimeError.missingContext(self)
        }
        
        let w = kernel.pipelineState.threadExecutionWidth
        let h = kernel.pipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        
        //Creating the output texture descriptor
        let outputTextureDescriptor : MTLTextureDescriptor = {
            let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: input.pixelFormat,
                                                                      width: width,
                                                                      height: height,
                                                                      mipmapped: false)
            descriptor.usage = [.shaderRead, .shaderWrite]
            return descriptor
        }()
        
        
        //Creating the output texture
        guard let output = context?.device.makeTexture(descriptor: outputTextureDescriptor) else {
            throw HandlerRuntimeError.genericError(self, "Cannot make texture to padded scale the texture")
        }
        
        let encoder = state.commandBuffer.makeComputeCommandEncoder()
        encoder?.setTexture(input, index: 0)
        encoder?.setTexture(output, index: 1)
        encoder?.dispatch(
            pipeline: kernel.pipelineState,
            width: width,
            height: height)
        encoder?.endEncoding()
        
        state.currentInputSize = CGSize(width: output.width, height: output.height)
        
        return output
    }
    
}
