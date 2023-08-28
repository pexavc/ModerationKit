import Foundation

public protocol HandlerContextRecipient : class {
   
    func invalidate(context : HandlerContext)
    
}
