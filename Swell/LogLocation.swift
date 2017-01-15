//
//  LogLocation.swift
//  Swell
//
//  Created by Hubert Rabago on 6/26/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//
import Foundation

public protocol LogLocation {
    //class func getInstance(param: AnyObject? = nil) -> LogLocation
    
    func log(_ message: @autoclosure () -> String);
    
    func enable();
    
    func disable();
    
    func description() -> String
}



open class ConsoleLocation: LogLocation {
    var enabled = true
    
    // Use the static-inside-class-var approach to getting a class var instance
    class var instance: ConsoleLocation {
        struct Static {
            static let internalInstance = ConsoleLocation()
        }
        return Static.internalInstance
    }
    
    open class func getInstance() -> LogLocation {
        return instance
    }
    
    open func log(_ message: @autoclosure () -> String) {
        if enabled {
            NSLog("%@", message())
        }
    }
    
    open func enable() {
        enabled = true
    }
    
    open func disable() {
        enabled = false
    }
    
    open func description() -> String {
        return "ConsoleLocation"
    }
}

// Use the globally-defined-var approach to getting a class var dictionary
var internalFileLocationDictionary = Dictionary<String, FileLocation>()

open class FileLocation: LogLocation {
    var enabled = true
    var filename: String
    var fileHandle: FileHandle?
    
    open class func getInstance(_ filename: String) -> LogLocation {
        let temp = internalFileLocationDictionary[filename]
        if let result = temp {
            return result
        } else {
            let result: FileLocation = FileLocation(filename: filename)
            internalFileLocationDictionary[filename] = result
            return result
        }
    }
    
    
    init(filename: String) {
        self.filename = filename
        self.setDirectory()
        fileHandle = nil
        openFile()
    }
    
    deinit {
        closeFile()
    }
    
    open func log(_ message: @autoclosure () -> String) {
        //message.writeToFile(filename, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
        if (!enabled) {
            return
        }
        
        let output = message() + "\n"
        if let handle = fileHandle {
            handle.seekToEndOfFile()
            if let data = output.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                handle.write(data)
            }
        }
        
    }
    
    func setDirectory() {
        let temp: NSString = self.filename as NSString
        if temp.range(of: "/").location != Foundation.NSNotFound {
            // "/" was found in the filename, so we use whatever path is already there
            if (self.filename.hasPrefix("~/")) {
                self.filename = (self.filename as NSString).expandingTildeInPath
            }
            
            return
        }
        
        //let dirs : [String]? = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true) as? [String]
        let dirs:AnyObject = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as AnyObject
        
        if let dir: String = dirs as? String {
            //let dir = directories[0]; //documents directory
            let path = (dir as NSString).appendingPathComponent(self.filename)
            self.filename = path;
        }
    }
    
    func openFile() {
        // open our file
        //Swell.info("Opening \(self.filename)")
        if !FileManager.default.fileExists(atPath: self.filename) {
            FileManager.default.createFile(atPath: self.filename, contents: nil, attributes: nil)
        }
        fileHandle = FileHandle(forWritingAtPath:self.filename);
        //Swell.debug("fileHandle is now \(fileHandle)")
    }
    
    func closeFile() {
        // close the file, if it's open
        if let handle = fileHandle {
            handle.closeFile()
        }
        fileHandle = nil
    }
    
    open func enable() {
        enabled = true
    }
    
    open func disable() {
        enabled = false
    }
    
    open func description() -> String {
        return "FileLocation filename=\(filename)"
    }
}


