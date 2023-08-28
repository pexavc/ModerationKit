import Foundation

class HandlerStateDebugger {
    
    struct Group {
        let name : String
        let level : Int
        let index : Int
        
        let startTime : CFAbsoluteTime
        var endTime : CFAbsoluteTime
        
        var durationTime : CFAbsoluteTime {
            return endTime - startTime
        }
        
        init(name : String, level : Int, index : Int) {
            self.name = name
            self.level = level
            self.index = index
            self.startTime = CFAbsoluteTimeGetCurrent()
            self.endTime = 0.0
        }
    }
    
    ///Debugging logging nesting level.
    var level = 0
    
    ///Logging groups
    var groups = [Group]()
}

extension HandlerStateDebugger {
    
    func pushGroup(name : String) {
        groups.append(Group(name: name, level: level, index: groups.count - 1))
        level += 1
    }
    
    func popGroup() {
        var group = groups.removeLast()
        group.endTime = CFAbsoluteTimeGetCurrent()
        groups.insert(group, at: 0)
        
        level -= 1
    }
    
}

extension HandlerStateDebugger {
    
    func printDebuggingGroups() {
        let totalExecutionTime = groups.filter { $0.level == 0 }.reduce(0.0) { $0 + $1.durationTime }
        
        for group in groups.sorted(by: { $0.index < $1.index }) {
            let absString = NSString(format: "%.5f", group.durationTime)
            let relString = NSString(format: "%.2f", (group.durationTime / totalExecutionTime)*100)
            
            var string = [String](repeating: "-", count: group.level + 1).joined()
            string += " \(group.name) \(absString)s \(relString)%"
            ModerationLog(string, level: .debug)
        }
    }
    
}
