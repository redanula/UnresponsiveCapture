//#!/usr/bin/swift
import Foundation
import SwiftyScript
import TSCBasic

var passStr = "<your password>"
var prStr = "WeChat"
var path = ""
let dpaths = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)
path = "\(dpaths[0])/jlog"
var count = CommandLine.argc

// Default Value
if count == 2 {
    passStr = CommandLine.arguments[1]
} else if count == 3 {
    passStr = CommandLine.arguments[1]
    prStr = CommandLine.arguments[2]
} else if count > 3 {
    passStr = CommandLine.arguments[1]
    prStr = CommandLine.arguments[2]
    path = CommandLine.arguments[3]
}

Task.DefaultValue.printTaskInfo = false
Task.DefaultValue.workspace = path
// Reset if lock
"find \(path)/Default -name \".swift_script.lock\" | xargs rm -f".fastRunAsScript(language: .Bash)

print("Number of arguments is: \(count) pass:\(passStr) key:\(prStr) dir:\(path)")

Task.init(language: .Bash, content: "echo ================= spindump Start =================").run()

let fs = TSCBasic.localFileSystem
let fileDir = AbsolutePath(path)
if !fs.exists(fileDir) {
     try fs.createDirectory(fileDir)
}

// Delete last *.j
"find \(fileDir) -name \"*.j\" | xargs rm -f".fastRunAsScript(language: .Bash)

let (result, log) = "pgrep \(prStr)".runAsScript(language: .Bash, output: .log)
if result == .success {
    let pids = log.components(separatedBy: "\n")
    print("\(pids)")
    for pid in pids {
        var foundUnresponsive = false
        let fullPath = "\(fileDir)/\(pid).j"
        let exeStr = "echo \(passStr) | sudo -S spindump \(pid) 1 -noBinary -noSymbolicate -onlyTarget -file \(fullPath)"
        print(exeStr)
        exeStr.fastRunAsScript(language: .Bash)
        
        // Found Unresponsive from *.j
        var inProcessState: Int = 0
        if let aStreamReader = StreamReader(path: fullPath) {
            defer {
                aStreamReader.close()
            }
            while let line = aStreamReader.nextLine() {
                if inProcessState == 2 {
                    break
                } else if line.contains("Process: ") {
                    inProcessState = 1
                } else if inProcessState == 1, line.contains("Unresponsive") {
                    foundUnresponsive = true
                    inProcessState = 2
                } else if line.contains("Note: ") {
                    inProcessState = 2
                }
            }
            if foundUnresponsive {
                print("!!!found pid:\(pid) is Unresponsive!!!")
                print("!!!kill pid:\(pid) !!!")
                "kill -9 \(pid)".fastRunAsScript(language: .Bash)
            }
        }
    }
} else {
    print(result)
    print("pgrep is null or fail")
}

Task.init(language: .Bash, content: "echo ================= spindump Done =================").run()


