import Foundation
import Metal

public class FloatTexture : Handler, HandlerContextRecipient {
    public typealias Input = MTLTexture
    public typealias Output = MTLTexture
    
    var context : HandlerContext?
    var kernel : MetalKernel?
    var format: MTLPixelFormat
    public init(
        format: MTLPixelFormat = .rgba32Float) {
        self.format = format
    }
    
    public func invalidate(context: HandlerContext) {
        self.context = context
        self.kernel = MetalKernel(named: "FloatTexture", context: context)
    }
    
    public func handle(input: NormalizeTexture.Input, state: HandlerState) throws -> NormalizeTexture.Output? {
        guard let kernel = kernel else {
            throw HandlerRuntimeError.missingContext(self)
        }
        
        let w = kernel.pipelineState.threadExecutionWidth
        let h = kernel.pipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        
        //Creating the output texture descriptor
        let outputTextureDescriptor : MTLTextureDescriptor = {
            let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: format,
                                                                      width: input.width,
                                                                      height: input.height,
                                                                      mipmapped: false)
            descriptor.usage = [.shaderRead, .shaderWrite]
            return descriptor
        }()
        
        //Creating the output texture
        guard let output = context?.device.makeTexture(descriptor: outputTextureDescriptor) else {
            throw HandlerRuntimeError.genericError(self, "Cannot make texture to convert to float texture")
        }
        
        let encoder = state.commandBuffer.makeComputeCommandEncoder()
        encoder?.setTexture(input, index: 0)
        encoder?.setTexture(output, index: 1)
        encoder?.dispatch(
            pipeline: kernel.pipelineState,
            width: input.width,
            height: input.height)
        encoder?.endEncoding()
        
        return output
    }
}
