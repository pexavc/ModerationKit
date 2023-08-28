import Foundation
import Metal
import simd

public class MeanColorTexture : Handler, HandlerContextRecipient {
    public typealias Input = MTLTexture
    public typealias Output = MTLTexture
  
    let color : int4

    var kernel : MetalKernel?
    var buffer : MetalBuffer<int4>?
    
    public init(red : Int, green : Int, blue : Int, alpha : Int = 0) {
        self.color = int4(Int32(red), Int32(green), Int32(blue), Int32(alpha))
    }
    
    public func invalidate(context: HandlerContext) {
        self.kernel = MetalKernel(named: "MeanColorTexture", context: context)
        self.buffer = MetalBuffer(data: color, context: context)
    }
    
    public func handle(input: MTLTexture, state: HandlerState) throws -> MTLTexture? {
        guard let kernel = kernel, let buffer = buffer else {
            throw HandlerRuntimeError.missingContext(self)
        }
        
        let w = kernel.pipelineState.threadExecutionWidth
        let h = kernel.pipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        
        let output = input
        
        let encoder = state.commandBuffer.makeComputeCommandEncoder()
        encoder?.setMetalBuffer(buffer, offset: 0, index: 0)
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


