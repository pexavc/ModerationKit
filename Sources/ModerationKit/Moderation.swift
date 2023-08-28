//
//  Moderation.swift
//  
//
//  Created by PEXAVC on 5/12/23.
//

import Foundation
import Combine

#if os(iOS)
import UIKit
public typealias ModerationImage = UIImage
#else
import AppKit
public typealias ModerationImage = NSImage
#endif


public class Moderation {
    public enum Kind {
        case nsfw
    }
    
    public enum Detection {
        
        public struct Result {
            var label: String
            var confidence: Float
        }
        
        case error(Error)
        case success(result: Result)
    }
    
    let nsfwModel: NSFWDetector = .init()
    
    public func check(_ image: ModerationImage,
                      for kind: Moderation.Kind) async -> Bool {
        
        let time = CFAbsoluteTime()
        switch kind {
        case .nsfw:
            switch await nsfwModel.check(image: image) {
            case .success(result: let result):
                ModerationLog("Detected: \(result.label) [\(result.confidence)] | speed: \(CFAbsoluteTime() - time)s", level: .debug)
                return result.label == "NSFW"
            case .error(let error):
                ModerationLog(error.localizedDescription, level: .error)
                return false
            }
        }
    }
}
