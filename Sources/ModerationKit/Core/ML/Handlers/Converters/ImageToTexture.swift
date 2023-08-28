import Foundation
import Metal
import CoreGraphics
import AVFoundation

public class ImageToTexture : Handler, HandlerContextRecipient {
    public typealias Input = Any
    public typealias Output = MTLTexture
    
    var context : HandlerContext?
    var textureCache: CVMetalTextureCache?
    let format: MTLPixelFormat
    let makeTextureView: Bool
    public init(
        format: MTLPixelFormat = .bgra8Unorm,
        makeTextureView: Bool = true) {
        self.format = format
        self.makeTextureView = makeTextureView
    }
    
    public func invalidate(context: HandlerContext) {
        self.context = context
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, context.device, nil, &textureCache)
    }
    
    public func handle(input: Any, state: HandlerState) throws -> MTLTexture? {
        guard let context = context else {
            throw HandlerRuntimeError.missingContext(self)
        }
        
        if let input = input as? ModerationImage {
            state.originalInputSize = input.size
            state.currentInputSize = input.size
            
            if let cgImage = input.cgImage,
                let texture = cgImage.toTexture(with: context.device) {
                return texture
            }
            
            throw HandlerRuntimeError.genericError(self, "Cannot convert image to texture")
        }
        else if CFGetTypeID(input as CFTypeRef) == CVPixelBufferGetTypeID() {
            let pixelBuffer = input as! CVPixelBuffer
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)
            
            state.originalInputSize = CGSize(width: width, height: height)
            state.currentInputSize = state.originalInputSize
            
            if let textureCache = textureCache {
                var texture: CVMetalTexture?
                
                CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                          textureCache,
                                                          pixelBuffer,
                                                          nil,
                                                          format,
                                                          width,
                                                          height,
                                                          0,
                                                          &texture)
                
                if let texture = texture {
                    if makeTextureView {
                        return CVMetalTextureGetTexture(texture)?.makeTextureView(pixelFormat: format)
                    } else {
                        return CVMetalTextureGetTexture(texture)
                    }
                    
                }
            }
            
            throw HandlerRuntimeError.genericError(self, "Cannot convert CVPixelBuffer to texture")
        }
        else {
            throw HandlerRuntimeError.typeMismatch(self, "CVPixelBuffer or Image", type(of: input))
        }
    }
}
