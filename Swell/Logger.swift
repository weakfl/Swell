//
//  Logger.swift
//  Swell
//
//  Created by Hubert Rabago on 6/20/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//



open class Logger {
    
    let name: String
    open var level: LogLevel
    open var formatter: LogFormatter
    var locations: [LogLocation]
    var enabled: Bool;
    
    public init(name: String,
                level: LogLevel = .INFO,
                formatter: LogFormatter = QuickFormatter(),
                logLocation: LogLocation = ConsoleLocation.getInstance()) {
        
        self.name = name
        self.level = level
        self.formatter = formatter
        self.locations = [LogLocation]()
        self.locations.append(logLocation)
        self.enabled = true;
        
        Swell.registerLogger(self);
    }
    
    
    open func log<T>(_ logLevel: LogLevel,
                    message: @autoclosure () -> T,
                                 filename: String? = #file, line: Int? = #line,  function: String? = #function) {
        if (self.enabled) && (logLevel.level >= level.level) {
            let logMessage = formatter.formatLog(self, level: logLevel, message: message(),
                                                 filename: filename, line: line, function: function);
            for location in locations {
                location.log(logMessage)
            }
        }
    }
    
    
    //**********************************************************************
    // Main log methods
    
    open func trace<T>(_ message: @autoclosure () -> T,
                      filename: String? = #file, line: Int? = #line,  function: String? = #function) {
        self.log(.TRACE, filename: filename, line: line, function: function, fn: message)
    }
    
    open func debug<T>(_ message: @autoclosure () -> T,
                      filename: String? = #file, line: Int? = #line,  function: String? = #function) {
        self.log(.DEBUG, filename: filename, line: line, function: function, fn: message)
    }
    
    open func info<T>(_ message: @autoclosure () -> T,
                     filename: String? = #file, line: Int? = #line,  function: String? = #function) {
        self.log(.INFO, filename: filename, line: line, function: function, fn: message)
    }
    
    open func warn<T>(_ message: @autoclosure () -> T,
                     filename: String? = #file, line: Int? = #line,  function: String? = #function) {
        self.log(.WARN, filename: filename, line: line, function: function, fn: message)
    }
    
    open func error<T>(_ message: @autoclosure () -> T,
                      filename: String? = #file, line: Int? = #line,  function: String? = #function) {
        self.log(.ERROR, filename: filename, line: line, function: function, fn: message)
    }
    
    open func severe<T>(_ message: @autoclosure () -> T,
                       filename: String? = #file, line: Int? = #line,  function: String? = #function) {
        self.log(.SEVERE, filename: filename, line: line, function: function, fn: message)
    }
    
    //*****************************************************************************************
    // Log methods that accepts closures - closures must accept no param and return a String
    
    open func log<T>(_ logLevel: LogLevel,
                    filename: String? = #file, line: Int? = #line,  function: String? = #function,fn: () -> T) {
        
        if (self.enabled) && (logLevel.level >= level.level) {
            let message = fn()
            self.log(logLevel, message: message, filename: filename, line: line, function: function)
        }
    }
    
    open func trace(_ filename: String? = #file, line: Int? = #line,  function: String? = #function, fn: () -> String) {
        log(.TRACE, filename: filename, line: line, function: function, fn: fn)
    }
    
    open func debug(_ filename: String? = #file, line: Int? = #line,  function: String? = #function, fn: () -> String) {
        log(.DEBUG, filename: filename, line: line, function: function, fn: fn)
    }
    
    open func info(_ filename: String? = #file, line: Int? = #line,  function: String? = #function, fn: () -> String) {
        log(.INFO, filename: filename, line: line, function: function, fn: fn)
    }
    
    open func warn(_ filename: String? = #file, line: Int? = #line,  function: String? = #function, fn: () -> String) {
        log(.WARN, filename: filename, line: line, function: function, fn: fn)
    }
    
    open func error(_ filename: String? = #file, line: Int? = #line,  function: String? = #function, fn: () -> String) {
        log(.ERROR, filename: filename, line: line, function: function, fn: fn)
    }
    
    open func severe(_ filename: String? = #file, line: Int? = #line,  function: String? = #function, fn: () -> String) {
        log(.SEVERE, filename: filename, line: line, function: function, fn: fn)
    }
    
    open class func getLogger(_ name: String) -> Logger {
        return Logger(name: name);
    }
    
    open func traceMessage(_ message: String) {
        self.trace(message, filename: nil, line: nil, function: nil);
    }
    
    open func debugMessage(_ message: String) {
        self.debug(message, filename: nil, line: nil, function: nil);
    }
    
    open func infoMessage(_ message: String) {
        self.info(message, filename: nil, line: nil, function: nil);
    }
    
    open func warnMessage(_ message: String) {
        self.warn(message, filename: nil, line: nil, function: nil);
    }
    
    open func errorMessage(_ message: String) {
        self.error(message, filename: nil, line: nil, function: nil);
    }
    
    open func severeMessage(_ message: String) {
        self.severe(message, filename: nil, line: nil, function: nil);
    }
}
