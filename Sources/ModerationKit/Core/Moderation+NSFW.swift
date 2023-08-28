//
//  NSFWDetector.swift
//  NSFWDetector
//
//  Created by Michael Berg on 13.08.18.
//

import Foundation
import CoreML
import Vision

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default:
            self = .up
            ModerationLog("Unknown image Orientation. Set as .up by default.")
        }
    }
}

public class NSFWDetector {
    
    private let model: VNCoreMLModel
    
    public required init() {
        guard let model = try? VNCoreMLModel(for: OpenNSFW(configuration: MLModelConfiguration()).model) else {
            fatalError("NSFW should always be a valid model")
        }
        self.model = model
    }
    
#if os(iOS)
    public func check(image: UIImage) async -> Moderation.Detection {
        
        // Create a requestHandler for the image
        let requestHandler: VNImageRequestHandler?
        if let cgImage = image.cgImage {
            requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        } else if let ciImage = image.ciImage {
            requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        } else {
            requestHandler = nil
        }
        
        return await check(requestHandler)
    }
#else
    public func check(image: NSImage) async -> Moderation.Detection {
        
        // Create a requestHandler for the image
        let requestHandler: VNImageRequestHandler?
        if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        } else {
            requestHandler = nil
        }
        
        return await check(requestHandler)
    }
#endif
    
    public func check(cvPixelbuffer: CVPixelBuffer) async -> Moderation.Detection {
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: cvPixelbuffer, options: [:])
        
        return await check(requestHandler)
    }
}

private extension NSFWDetector {
    
    func check(_ requestHandler: VNImageRequestHandler?) async -> Moderation.Detection {
        return await withCheckedContinuation({ continuation in
            
            
            guard let requestHandler = requestHandler else {
                continuation.resume(returning: .error(NSError(domain: "either cgImage or ciImage must be set inside of UIImage", code: 0, userInfo: nil)))
                return
            }
            
            /// The request that handles the detection completion
            let request = VNCoreMLRequest(model: self.model, completionHandler: { (request, error) in
                guard let observations = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: .error(NSError(domain: "Detection failed: No NSFW Observation found", code: 0, userInfo: nil)))
                    return
                }
                
                let results: [Moderation.Detection.Result] = observations.map { .init(label: $0.identifier, confidence: $0.confidence) }
                
                guard let highestConfidence: Moderation
                    .Detection
                    .Result = results
                    .sorted(by: { $0.confidence > $1.confidence })
                    .first else {
                    continuation.resume(returning: .error(NSError(domain: "failed to sort confidences", code: 0, userInfo: nil)))
                    return
                }
                
                continuation.resume(returning: .success(result: highestConfidence))
            })
            
            /// Start the actual detection
            do {
                try requestHandler.perform([request])
            } catch {
                continuation.resume(returning: .error(NSError(domain: "Detection failed: No NSFW Observation found", code: 0, userInfo: nil)))
            }
        })
    }
}
