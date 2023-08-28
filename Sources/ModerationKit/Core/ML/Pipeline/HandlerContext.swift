import Foundation
import Metal
import MetalPerformanceShaders

///The core context abstracts Metal definitions away by
///providing infrastructure to work with Metal buffers and textures.
public class HandlerContext {
    
    ///The device used to do all the Metal processing.
    public let device : MTLDevice
    
    ///The queue to get command buffers from.
    public let queue : MTLCommandQueue
    
    ///The library to get the kernel definitions (shaders) from.
    public let library : MTLLibrary
    
    ///Debugger which handles debugging output and debugging calculations.
    let debugger = HandlerStateDebugger()

    public init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Cannot obtain system default device.")
        }
        
        guard let queue = device.makeCommandQueue() else {
            fatalError("Cannot obtain device queue.")
        }
    
        #if swift(>=5.3)
        if let libraryDefault = try? device.makeDefaultLibrary(bundle: Bundle.module) {
            self.library = libraryDefault
        } else {
            do {
                var contentsUrl: URL? = Bundle.module.url(
                    forResource: "default",
                    withExtension: "metallib")
                
                if let metalUrl = contentsUrl {
                    do {
                        let submoduleLibrary = try device.makeLibrary(URL: metalUrl)
                        ModerationLog("Library loaded")

                        self.library = submoduleLibrary
                    }
                    catch let error {
                        fatalError("Cannot initialise Metal libraries for GraniteML.")
                    }
                } else {
                    fatalError("Cannot initialise Metal libraries for GraniteML.")
                }
            }
            catch {
                fatalError("Cannot initialise Metal libraries for GraniteML.")
            }
        }
        #else
        if let libraryDefault = device.makeDefaultLibrary() {
            self.library = libraryDefault
        } else {
            fatalError("Cannot initialize Metal libraries")
        }
        #endif
        
        self.device = device
        self.queue = queue
    }
    
}
