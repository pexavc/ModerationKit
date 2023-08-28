import Foundation
import Metal

public class MaskTexture : Handler, HandlerContextRecipient {
    public typealias Input = [String : MTLTexture]
    public typealias Output = MTLTexture
    
    var kernel : MetalKernel?

    public init() {
        
    }

    public func invalidate(context: HandlerContext) {
        self.kernel = MetalKernel(named: "MaskTexture", context: context)
    }
    
    public func handle(input: [String : MTLTexture], state: HandlerState) throws -> MTLTexture? {
        guard let kernel = kernel else {
            throw HandlerRuntimeError.missingContext(self)
        }
        
        let w = kernel.pipelineState.threadExecutionWidth
        let h = kernel.pipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        
        guard let mask = input["mask"], let input = input["image"] else {
            throw HandlerRuntimeError.genericError(self, "Expected 'mask' and 'image' to be present as arguments")
        }
  
        let output = input
        
        let encoder = state.commandBuffer.makeComputeCommandEncoder()
        encoder?.setTexture(input, index: 0)
        encoder?.setTexture(output, index: 1)
        encoder?.setTexture(mask, index: 2)
        encoder?.dispatch(
            pipeline: kernel.pipelineState,
            width: input.width,
            height: input.height)
        encoder?.endEncoding()
        
        return output
    }
    
}
