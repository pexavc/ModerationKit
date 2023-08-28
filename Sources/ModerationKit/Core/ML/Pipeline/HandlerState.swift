import Foundation
import CoreGraphics
import Metal

public class HandlerState {
    
    ///Context stored by the state.
    unowned let context : HandlerContext
    
    ///Current command buffer to execute graphical pipeline.
    public var commandBuffer : MTLCommandBuffer
    
    ///Original input size.
    public var originalInputSize : CGSize = .zero
    
    ///Current input size.
    public var currentInputSize : CGSize = .zero
    
    ///Storage for auxiliary information
    public var auxiliaryData = [String : Any]()
    
    ///Initialising the state with the specified context.
    public init?(context : HandlerContext) {
        guard let buffer = context.queue.makeCommandBuffer() else {
            return nil
        }
        
        self.context = context
        self.commandBuffer = buffer
    }

    ///Used on macOS to synchronize resources.
    public func synchronize(resource : MTLResource) {
        #if os(OSX)
        let encoder = commandBuffer.makeBlitCommandEncoder()
        encoder?.synchronize(resource: resource)
        encoder?.endEncoding()
        #endif
    }
    
    ///Completing all scheduled operations and initialising a new buffer to submit new operations.
    public func insertCommandBufferExecutionBoundary() {
        context.debugger.pushGroup(name: "Metal")
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        context.debugger.popGroup()
    
        guard let buffer = context.queue.makeCommandBuffer() else {
            return
        }
        
        commandBuffer = buffer
    }
    
}
