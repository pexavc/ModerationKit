import Foundation

#if os(iOS)
import UIKit

extension ModerationImage {
    
    convenience init(cgImage : CGImage) {
        self.init(cgImage: cgImage, scale: 1.0, orientation: .up)
    }
    
}

#else
import AppKit

extension ModerationImage {
    
    var cgImage : CGImage? {
        return self.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    convenience init(cgImage : CGImage) {
        self.init(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    }
    
}
#endif
