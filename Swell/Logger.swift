//
//  Logger.swift
//  Swell
//
//  Created by Hubert Rabago on 6/20/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//



public class Logger {
    
    let name: String
    public var level: LogLevel
    public var formatter: LogFormatter
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
    
    
    public func log<T>(logLevel: LogLevel,
                    @autoclosure message: () -> T,
                                 filename: String? = #file, line: Int? = #line,  function: String? = #function) {
        if (self.enabled) && (logLevel.level >= level.level) {
            let logMessage = formatter.formatLog(self, level: logLevel, message: message,
                                                 filename: filename, line: line, function: function);
            for location in locations {
                location.log(logMessage)
            }
        }
    }
    
    
    //**********************************************************************
    // Main log methods
    
    public func trace<T>(@autoclosure message: () -> T,
                      filename: String? = #file, line: Int? = #line,  function: String? = #function) {
        self.log(.TRACE, message: message, filename: filename, line: line, function: function)
    }
    
    public func debug<T>(@autoclosure message: () -> T,
                      filename: String? = #file, line: Int? = #line,  function: String? = #function) {
        self.log(.DEBUG, message: message, filename: filename, line: line, function: function)
    }
    
    public func info<T>(@autoclosure message: () -> T,
                     filename: String? = #file, line: Int? = #line,  function: String? = #function) {
        self.log(.INFO, message: message, filename: filename, line: line, function: function)
    }
    
    public func warn<T>(@autoclosure message: () -> T,
                     filename: String? = #file, line: Int? = #line,  function: String? = #function) {
        self.log(.WARN, message: message, filename: filename, line: line, function: function)
    }
    
    public func error<T>(@autoclosure message: () -> T,
                      filename: String? = #file, line: Int? = #line,  function: String? = #function) {
        self.log(.ERROR, message: message, filename: filename, line: line, function: function)
    }
    
    public func severe<T>(@autoclosure message: () -> T,
                       filename: String? = #file, line: Int? = #line,  function: String? = #function) {
        self.log(.SEVERE, message: message, filename: filename, line: line, function: function)
    }
    
    //*****************************************************************************************
    // Log methods that accepts closures - closures must accept no param and return a String
    
    public func log(logLevel: LogLevel,
                    filename: String? = #file, line: Int? = #line,  function: String? = #function,fn: () -> String) {
        
        if (self.enabled) && (logLevel.level >= level.level) {
            let message = fn()
            self.log(logLevel, message: message)
        }
    }
    
    public func trace(filename: String? = #file, line: Int? = #line,  function: String? = #function, fn: () -> String) {
        log(.TRACE, filename: filename, line: line, function: function, fn: fn)
    }
    
    public func debug(filename: String? = #file, line: Int? = #line,  function: String? = #function, fn: () -> String) {
        log(.DEBUG, filename: filename, line: line, function: function, fn: fn)
    }
    
    public func info(filename: String? = #file, line: Int? = #line,  function: String? = #function, fn: () -> String) {
        log(.INFO, filename: filename, line: line, function: function, fn: fn)
    }
    
    public func warn(filename: String? = #file, line: Int? = #line,  function: String? = #function, fn: () -> String) {
        log(.WARN, filename: filename, line: line, function: function, fn: fn)
    }
    
    public func error(filename: String? = #file, line: Int? = #line,  function: String? = #function, fn: () -> String) {
        log(.ERROR, filename: filename, line: line, function: function, fn: fn)
    }
    
    public func severe(filename: String? = #file, line: Int? = #line,  function: String? = #function, fn: () -> String) {
        log(.SEVERE, filename: filename, line: line, function: function, fn: fn)
    }
    
    public class func getLogger(name: String) -> Logger {
        return Logger(name: name);
    }
    
    public func traceMessage(message: String) {
        self.trace(message, filename: nil, line: nil, function: nil);
    }
    
    public func debugMessage(message: String) {
        self.debug(message, filename: nil, line: nil, function: nil);
    }
    
    public func infoMessage(message: String) {
        self.info(message, filename: nil, line: nil, function: nil);
    }
    
    public func warnMessage(message: String) {
        self.warn(message, filename: nil, line: nil, function: nil);
    }
    
    public func errorMessage(message: String) {
        self.error(message, filename: nil, line: nil, function: nil);
    }
    
    public func severeMessage(message: String) {
        self.severe(message, filename: nil, line: nil, function: nil);
    }
}
