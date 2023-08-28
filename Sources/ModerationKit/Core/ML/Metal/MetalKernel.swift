import Foundation
import Metal
import MetalPerformanceShaders

public struct MetalKernel {
    
    //Pipeline descriptor instance
    public let pipelineState : MTLComputePipelineState
    
    public init(named name : String, context : HandlerContext) {
        if let function = context.library.makeFunction(name: name) {
            let descriptor = MTLComputePipelineDescriptor()
            descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = false
            descriptor.computeFunction = function
            
            do {
                self.pipelineState = try context.device.makeComputePipelineState(descriptor: descriptor,
                                                                                 options: MTLPipelineOption(),
                                                                                 reflection: nil)
            }
            catch let error {
                fatalError("Cannot initialize MetalKernel with function named '\(name)': \(error.localizedDescription).")
            }
        }
        else {
            fatalError("Cannot initialize MetalKernel with function named '\(name)'.")
        }
    }
    
}
