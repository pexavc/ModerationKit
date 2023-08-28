import Foundation
import Metal
import CoreML
import Accelerate

public class CoreML : Handler, HandlerContextRecipient {
    public typealias Input = MTLTexture
    public typealias Output = [String : Any]
 
    fileprivate var model : MLModel? = nil
    
    fileprivate var lastMultiArrayPointer : UnsafeMutableRawPointer?
    fileprivate var bytes : [Double] = [Double]()
    fileprivate weak var context : HandlerContext?
    
    convenience public init(url : URL) {
        
        self.init(path: url.path)
    }
    
    public init(path : String) {
        do { 
            if path.hasSuffix("mlmodelc") {
                //Model is already compiled
                self.model = try MLModel(contentsOf: URL(fileURLWithPath: path))
            }
            else {
                //Model is not encrypted
                let compiledModelUrl = try MLModel.compileModel(at: URL(fileURLWithPath: path))
                self.model = try MLModel(contentsOf: compiledModelUrl)
            }
        }
        catch {
            
        }
    }
    
    public func invalidate(context: HandlerContext) {
        self.context = context
    }
    
    public func handle(input: MTLTexture, state: HandlerState) throws -> [String : Any]? {
        guard let model = model else {
            throw HandlerRuntimeError.genericError(self, "Unable to load specified CoreML model")
        }
        
        state.synchronize(resource: input)
        state.insertCommandBufferExecutionBoundary()
        
        var inputs = [String : AnyObject]()
        var outputs = [String : Any]()
    
        for (name, description) in model.modelDescription.inputDescriptionsByName {
            
            switch description.type {
                
            case .multiArray:
                guard let constraint = description.multiArrayConstraint else {
                    continue
                }

                context?.debugger.pushGroup(name: "MLMultiArray Conversion")
                inputs[name] = createMultiArray(from: input, constraint: constraint)
                context?.debugger.popGroup()
                
            case .image:
                context?.debugger.pushGroup(name: "CVPixelBuffer Conversion")
                inputs[name] = createCVPixelBuffer(from: input)
                context?.debugger.popGroup()
                
            default:
                break
            }
        }
        
        guard let outputProvider = try? model.prediction(from: CoreMLInputProvider(inputs: inputs)) else {
            throw HandlerRuntimeError.genericError(self, "Unable to run CoreML model")
        }
        
        for (name, _) in model.modelDescription.outputDescriptionsByName {
            guard let feature = outputProvider.featureValue(for: name) else{
                continue
            }
            
            switch feature.type {
            case .string:
                outputs[name] = feature.stringValue
            case .dictionary:
                outputs[name] = feature.dictionaryValue
            case .multiArray:
                outputs[name] = feature.multiArrayValue
            case .image:
                outputs[name] = feature.imageBufferValue
            default:
                break
            }
        }
        
        return outputs
    }
    
}

extension CoreML {
    fileprivate func createMultiArray(from input : MTLTexture, constraint : MLMultiArrayConstraint) -> MLMultiArray? {
        let channelsCount = 4
        
        if input.pixelFormat == .rgba8Unorm {
            let pixels = input.toUInt8Array(width: input.width, height: input.height, featureChannels: channelsCount)
            bytes = [Double](repeating: 0, count: pixels.count)
            vDSP_vfltu8D(pixels, 1, &bytes, 1, vDSP_Length(pixels.count))
            
            lastMultiArrayPointer = UnsafeMutableRawPointer(mutating: bytes)!
        }
        else if input.pixelFormat == .rgba32Float {
            let pixels = input.toFloatArray(width: input.width, height: input.height, featureChannels: channelsCount)
            bytes = [Double](repeating: 0, count: pixels.count)
            
            vDSP_vspdp(pixels, 1, &bytes, 1, vDSP_Length(pixels.count))
            
            lastMultiArrayPointer = UnsafeMutableRawPointer(mutating: bytes)!
        }
        
        return try? MLMultiArray(dataPointer: lastMultiArrayPointer!,
                                 shape: constraint.shape,
                                 dataType: constraint.dataType,
                                 strides: [1,
                                           NSNumber(value: channelsCount*Int(truncating: (constraint.shape[1]))),
                                           NSNumber(value: channelsCount)])
    }
    
    fileprivate func createCVPixelBuffer(from input : MTLTexture) -> CVPixelBuffer? {
        var sourceBuffer : CVPixelBuffer?
        
        let attrs = NSMutableDictionary()
        attrs[kCVPixelBufferIOSurfacePropertiesKey] = NSMutableDictionary()
        
        CVPixelBufferCreate(kCFAllocatorDefault,
                            input.width,
                            input.height,
                            kCVPixelFormatType_32BGRA,
                            attrs as CFDictionary,
                            &sourceBuffer)
        
        guard let buffer = sourceBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let bufferPointer = CVPixelBufferGetBaseAddress(buffer)!
        
        let region = MTLRegionMake2D(0, 0, input.width, input.height)
        input.getBytes(bufferPointer, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), from: region, mipmapLevel: 0)
        
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return buffer
    }
    
}
