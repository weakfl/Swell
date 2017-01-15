//
//  LogSelector.swift
//  Swell
//
//  Created by Hubert Rabago on 7/2/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//


/// Implements the logic for determining which loggers are enabled to actually log anything.
/// The rules used by this are:
///  * By default, everything is enabled
///  * If a logger is specifically disabled, then that rule will be followed regardless of whether it was enabled by another rule
///  * If any one logger is specifically enabled, then all other loggers must be specifically enabled, too,
///    otherwise they wouldn't be enabled
open class LogSelector {
    
    open var enableRule: String = "" {
        didSet {
            enabled = parseCSV(enableRule)
        }
    }
    open var disableRule: String = "" {
        didSet {
            disabled = parseCSV(disableRule)
        }
    }
    
    open var enabled: [String] = [String]()
    open var disabled: [String] = [String]()
    
    public init() {
        
    }
    
    func shouldEnable(_ logger: Logger) -> Bool {
        let name = logger.name
        return shouldEnableLoggerWithName(name)
    }
    
    open func shouldEnableLoggerWithName(_ name: String) -> Bool {
        // If the default rules are in place, then yes
        if disableRule == "" && enableRule == "" {
            return true
        }
        
        // At this point, we know at least one rule has changed
        
        // If logger was specifically disabled, then no
        if isLoggerDisabled(name) {
            return false
        }
        
        // If logger was specifically enabled, then yes!
        if isLoggerEnabled(name) {
            return true
        }
        
        // At this point, we know that the logger doesn't have a specific rule
        
        // If any items were specifically enabled, then this wasn't, then NO
        if enabled.count > 0 {
            return false
        }
        
        // At this point, we know there weren't any loggers specifically enabled, but
        //  the disableRule has been modified, and yet this logger wasn't
        return true
    }
    
    /// Returns true if the given logger name was specifically configured to be disabled
    func isLoggerEnabled(_ name: String) -> Bool {
        for enabledName in enabled {
            if (name == enabledName) {
                return true
            }
        }
        
        return false
    }
    
    /// Returns true if the given logger name was specifically configured to be disabled
    func isLoggerDisabled(_ name: String) -> Bool {
        for disabledName in disabled {
            if (name == disabledName) {
                return true
            }
        }
        
        return false
    }
    
    
    func parseCSV(_ string: String) -> [String] {
        var result = [String]()
        let temp = string.components(separatedBy: ",")
        for s: String in temp {
            // 'countElements(s)' returns s.length
            if (s.characters.count > 0) {
                result.append(s)
            }
            //if (s.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
            //    result.append(s)
            //}
        }
        return result
    }
    
    
}


