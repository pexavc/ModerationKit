//
//  Filters.swift
//  LinenAndSole
//
//  Created by PEXAVC on 4/18/19.
//  Copyright © 2019 PEXAVC. All rights reserved.
//

import Foundation
import Metal
import simd

public class FilterTexture : Handler, HandlerContextRecipient {
    public typealias Input = MTLTexture
    public typealias Output = MTLTexture
    
    let filterName : String
    
    var kernel : MetalKernel?
    
    public init(filterName: String) {
        self.filterName = filterName
    }
    
    public func invalidate(context: HandlerContext) {
        self.kernel = MetalKernel(named: filterName, context: context)
    }
    
    public func handle(input: MTLTexture, state: HandlerState) throws -> MTLTexture? {
        guard let kernel = kernel else {
            throw HandlerRuntimeError.missingContext(self)
        }
        
        let w = kernel.pipelineState.threadExecutionWidth
        let h = kernel.pipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        
        let output = input
        
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


