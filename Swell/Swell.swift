//
//  Swell.swift
//  Swell
//
//  Created by Hubert Rabago on 6/26/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//
import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



struct LoggerConfiguration {
    var name: String
    var level: LogLevel?
    var formatter: LogFormatter?
    var locations: [LogLocation]
    
    init(name: String) {
        self.name = name
        self.locations = [LogLocation]()
    }
    func description() -> String {
        var locationsDesc = ""
        for loc in locations {
            locationsDesc += loc.description()
        }
        return "\(name) \(level?.desciption()) \(formatter?.description()) \(locationsDesc)"
    }
}



// We declare this here because there isn't any support yet for class var / class let
let globalSwell = Swell();


open class Swell {
    
    var swellLogger: Logger!;
    var selector = LogSelector()
    var allLoggers = Dictionary<String, Logger>()
    var rootConfiguration = LoggerConfiguration(name: "ROOT")
    var sharedConfiguration = LoggerConfiguration(name: "Shared")
    var allConfigurations = Dictionary<String, LoggerConfiguration>()
    var enabled = true;
    
    
    init() {
        // This configuration is used by the shared logger
        sharedConfiguration.formatter = QuickFormatter(format: .levelMessage)
        sharedConfiguration.level = LogLevel.TRACE
        sharedConfiguration.locations += [ConsoleLocation.getInstance()]
        
        // The root configuration is where all other configurations are based off of
        rootConfiguration.formatter = QuickFormatter(format: .levelNameMessage)
        rootConfiguration.level = LogLevel.TRACE
        rootConfiguration.locations += [ConsoleLocation.getInstance()]
        
        /**
         We'll just make sure to create every log level
         */
        LogLevel.DEBUG
        LogLevel.INFO
        LogLevel.TRACE
        LogLevel.WARN
        LogLevel.ERROR
        LogLevel.SEVERE
        
        readConfigurationFile()
    }
    
    func initInternalLogger() {
        //swellLogger = Logger(name: "SHARED", formatter: QuickFormatter(format: .LevelMessage))
        swellLogger = getLogger("Shared")
    }
    
    
    
    
    //========================================================================================
    // Global/convenience log methods used for quick logging
    
    open class func trace<T>(_ message: @autoclosure () -> T) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.trace(message)
    }
    
    open class func debug<T>(_ message: @autoclosure () -> T) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.debug(message)
    }
    
    open class func info<T>(_ message: @autoclosure () -> T) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.info(message)
    }
    
    open class func warn<T>(_ message: @autoclosure () -> T) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.warn(message)
    }
    
    open class func error<T>(_ message: @autoclosure () -> T) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.error(message)
    }
    
    open class func severe<T>(_ message: @autoclosure () -> T) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.severe(message)
    }
    
    open class func trace(_ fn: () -> String) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.trace(fn())
    }
    
    open class func debug(_ fn: () -> String) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.debug(fn())
    }
    
    open class func info(_ fn: () -> String) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.info(fn())
    }
    
    open class func warn(_ fn: () -> String) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.warn(fn())
    }
    
    open class func error(_ fn: () -> String) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.error(fn())
    }
    
    open class func severe(_ fn: () -> String) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.severe(fn())
    }
    
    //====================================================================================================
    // Public methods
    
    
    /// Returns the logger configured for the given name.
    /// This is the recommended way of retrieving a Swell logger.
    open class func getLogger(_ name: String) -> Logger {
        return globalSwell.getLogger(name);
    }
    
    
    /// Turns off all logging.
    open class func disableLogging() {
        globalSwell.disableLogging()
    }
    
    
    func disableLogging() {
        enabled = false
        for (_, value) in allLoggers {
            value.enabled = false
        }
    }
    
    func enableLogging() {
        enabled = true
        for (_, value) in allLoggers {
            value.enabled = selector.shouldEnable(value)
        }
    }
    
    // Register the given logger.  This method should be called
    // for ALL loggers created.  This facilitates enabling/disabling of
    // loggers based on user configuration.
    class func registerLogger(_ logger: Logger) {
        globalSwell.registerLogger(logger);
    }
    
    func registerLogger(_ logger: Logger) {
        allLoggers[logger.name] = logger;
        evaluateLoggerEnabled(logger);
    }
    
    func evaluateLoggerEnabled(_ logger: Logger) {
        logger.enabled = self.enabled && selector.shouldEnable(logger);
    }
    
    /// Returns the Logger instance configured for a given logger name.
    /// Use this to get Logger instances for use in classes.
    func getLogger(_ name: String) -> Logger {
        let logger = allLoggers[name]
        if (logger != nil) {
            return logger!
        } else {
            let result: Logger = createLogger(name)
            allLoggers[name] = result
            return result
        }
    }
    
    /// Creates a new Logger instance based on configuration returned by getConfigurationForLoggerName()
    /// This is intended to be in an internal method and should not be called by other classes.
    /// Use getLogger(name) to get a logger for normal use.
    func createLogger(_ name: String) -> Logger {
        let config = getConfigurationForLoggerName(name)
        let result = Logger(name: name, level: config.level!, formatter: config.formatter!, logLocation: config.locations[0])
        
        // Now we need to handle potentially > 1 locations
        if config.locations.count > 1 {
            for (index,location) in config.locations.enumerated() {
                if (index > 0) {
                    result.locations += [location]
                }
            }
        }
        
        return result
    }
    
    
    //====================================================================================================
    // Methods for managing the configurations from the plist file
    
    /// Returns the current configuration for a given logger name based on Swell.plist
    /// and the root configuration.
    func getConfigurationForLoggerName(_ name: String) -> LoggerConfiguration {
        var config: LoggerConfiguration = LoggerConfiguration(name: name);
        
        // first, populate it with values from the root config
        config.formatter = rootConfiguration.formatter
        config.level = rootConfiguration.level
        config.locations += rootConfiguration.locations
        
        if (name == "Shared") {
            if let level = sharedConfiguration.level {
                config.level = level
            }
            if let formatter = sharedConfiguration.formatter {
                config.formatter = formatter
            }
            if sharedConfiguration.locations.count > 0 {
                config.locations = sharedConfiguration.locations
            }
        }
        
        // Now see if there's a config specifically for this logger
        // In later versions, we can consider tree structures similar to Log4j
        // For now, let's require an exact match for the name
        let keys = allConfigurations.keys
        for key in keys {
            // Look for the entry with the same name
            if (key == name) {
                let temp = allConfigurations[key]
                if let spec = temp {
                    if let formatter = spec.formatter {
                        config.formatter = formatter
                    }
                    if let level = spec.level {
                        config.level = level
                    }
                    if spec.locations.count > 0 {
                        config.locations = spec.locations
                    }
                }
                
            }
        }
        
        return config;
    }
    
    
    
    //====================================================================================================
    // Methods for reading the Swell.plist file
    
    func readConfigurationFile() {
        var filename: String? = Bundle.main.path(forResource: "Swell", ofType: "plist");
        if filename == nil {
            for bundle in Bundle.allBundles {
                filename = bundle.path(forResource: "Swell", ofType: "plist");
                if (filename != nil) {
                    break
                }
            }
        }
        
        var dict: NSDictionary? = nil;
        if let bundleFilename = filename {
            dict = NSDictionary(contentsOfFile: bundleFilename)
        }
        if let map: Dictionary<String, AnyObject> = dict as? Dictionary<String, AnyObject> {
            
            //-----------------------------------------------------------------
            // Read the root configuration
            let configuration = readLoggerPList("ROOT", map: map);
            //Swell.info("map: \(map)");
            
            // Now any values configured, we put in our root configuration
            if let formatter = configuration.formatter {
                rootConfiguration.formatter = formatter
            }
            if let level = configuration.level {
                rootConfiguration.level = level
            }
            if configuration.locations.count > 0 {
                rootConfiguration.locations = configuration.locations
            }
            
            //-----------------------------------------------------------------
            // Now look for any keys that don't start with SWL, and if it contains a dictionary value, let's read it
            let keys = map.keys
            for key in keys {
                if (!key.hasPrefix("SWL")) {
                    let value: AnyObject? = map[key]
                    if let submap: Dictionary<String, AnyObject> = value as? Dictionary<String, AnyObject> {
                        let subconfig = readLoggerPList(key, map: submap)
                        applyLoggerConfiguration(key, configuration: subconfig)
                    }
                }
            }
            
            //-----------------------------------------------------------------
            // Now check if there is an enabled/disabled rule specified
            var item: AnyObject? = nil
            // Set the LogLevel
            
            item = map["SWLEnable"]
            if let value: AnyObject = item {
                if let rule: String = value as? String {
                    selector.enableRule = rule
                }
            }
            
            item = map["SWLDisable"]
            if let value: AnyObject = item {
                if let rule: String = value as? String {
                    selector.disableRule = rule
                }
            }
            
        }
        
    }
    
    
    /// Specifies or modifies the configuration of a logger.
    /// If any aspect of the configuration was not provided, and there is a pre-existing value for it,
    /// the pre-existing value will be used for it.
    /// For example, if two consecutive calls were made:
    ///     configureLogger("MyClass", level: LogLevel.DEBUG, formatter: MyCustomFormatter())
    ///     configureLogger("MyClass", level: LogLevel.INFO, location: ConsoleLocation())
    ///  then the resulting configuration for MyClass would have MyCustomFormatter, ConsoleLocation, and LogLevel.INFO.
    func configureLogger(_ loggerName: String,
                         level givenLevel: LogLevel? = nil,
                               formatter givenFormatter: LogFormatter? = nil,
                                         location givenLocation: LogLocation? = nil) {
        
        var oldConfiguration: LoggerConfiguration?
        if allConfigurations.index(forKey: loggerName) != nil {
            oldConfiguration = allConfigurations[loggerName]
        }
        
        var newConfiguration = LoggerConfiguration(name: loggerName)
        
        if let level = givenLevel {
            newConfiguration.level = level
        } else if let level = oldConfiguration?.level {
            newConfiguration.level = level
        }
        
        if let formatter = givenFormatter {
            newConfiguration.formatter = formatter
        } else if let formatter = oldConfiguration?.formatter {
            newConfiguration.formatter = formatter
        }
        
        if let location = givenLocation {
            newConfiguration.locations += [location]
        } else if oldConfiguration?.locations.count > 0 {
            newConfiguration.locations = oldConfiguration!.locations
        }
        
        applyLoggerConfiguration(loggerName, configuration: newConfiguration)
    }
    
    
    /// Store the configuration given for the specified logger.
    /// If the logger already exists, update its configuration to reflect what's in the logger.
    
    func applyLoggerConfiguration(_ loggerName: String, configuration: LoggerConfiguration) {
        // Record this custom config in our map
        allConfigurations[loggerName] = configuration
        
        // See if the logger with the given name already exists.
        // If so, update the configuration it's using.
        if let logger = allLoggers[loggerName] {
            
            // TODO - There should be a way to keep calls to logger.log while this is executing
            if let level = configuration.level {
                logger.level = level
            }
            if let formatter = configuration.formatter {
                logger.formatter = formatter
            }
            if configuration.locations.count > 0 {
                logger.locations.removeAll(keepingCapacity: false)
                logger.locations += configuration.locations
            }
        }
        
    }
    
    
    func readLoggerPList(_ loggerName: String, map: Dictionary<String, AnyObject>) -> LoggerConfiguration {
        var configuration = LoggerConfiguration(name: loggerName)
        var item: AnyObject? = nil
        // Set the LogLevel
        
        item = map["SWLLevel"]
        if let value: AnyObject = item {
            if let level: String = value as? String {
                configuration.level = LogLevel.getLevel(level)
            }
        }
        
        // Set the formatter;  First, look for a QuickFormat spec
        item = map["SWLQuickFormat"]
        if let value: AnyObject = item {
            configuration.formatter = getConfiguredQuickFormatter(configuration, item: value);
        } else {
            // If no QuickFormat was given, look for a FlexFormat spec
            item = map["SWLFlexFormat"]
            if let value: AnyObject = item {
                configuration.formatter = getConfiguredFlexFormatter(configuration, item: value);
            } else {
                let formatKey = getFormatKey(map)
                print("formatKey=\(formatKey)")
            }
        }
        
        // Set a custom date formatter.
        item = map["SWLDateFormatter"]
        if let value: AnyObject = item {
            configuration.formatter?.dateFormatter = getConfiguredDateFormatter(value)
        }
        
        // Set the location for the logs
        item = map["SWLLocation"]
        if let value: AnyObject = item {
            configuration.locations = getConfiguredLocations(configuration, item: value, map: map);
        }
        
        return configuration
    }
    
    
    func getConfiguredQuickFormatter(_ configuration: LoggerConfiguration, item: AnyObject) -> LogFormatter? {
        if let formatString: String = item as? String {
            let formatter = QuickFormatter.logFormatterForString(formatString)
            return formatter
        }
        return nil
    }
    
    func getConfiguredFlexFormatter(_ configuration: LoggerConfiguration, item: AnyObject) -> LogFormatter? {
        if let formatString: String = item as? String {
            let formatter = FlexFormatter.logFormatterForString(formatString);
            return formatter
        }
        return nil
    }
    
    func getConfiguredFileLocation(_ configuration: LoggerConfiguration, item: AnyObject) -> LogLocation? {
        if let filename: String = item as? String {
            let logLocation = FileLocation.getInstance(filename);
            return logLocation
        }
        return nil
    }
    
    func getConfiguredLocations(_ configuration: LoggerConfiguration, item: AnyObject,
                                map: Dictionary<String, AnyObject>) -> [LogLocation] {
        var results = [LogLocation]()
        if let configuredValue: String = item as? String {
            // configuredValue is the raw value in the plist
            
            // values is the array from configuredValue
            let values = configuredValue.lowercased().components(separatedBy: CharacterSet.whitespaces)
            
            for value in values {
                if (value == "file") {
                    // handle file name
                    let filenameValue: AnyObject? = map["SWLLocationFilename"]
                    if let filename: AnyObject = filenameValue {
                        let fileLocation = getConfiguredFileLocation(configuration, item: filename);
                        if fileLocation != nil {
                            results += [fileLocation!]
                        }
                    }
                } else if (value == "console") {
                    results += [ConsoleLocation.getInstance()]
                } else {
                    print("Unrecognized location value in Swell.plist: '\(value)'")
                }
            }
        }
        return results
    }
    
    func getConfiguredDateFormatter(_ item: AnyObject) -> DateFormatter {
        let dateFormatter = DateFormatter()
        if let formatString = item as? String {
            dateFormatter.dateFormat = formatString
        }
        return dateFormatter
    }
    
    //    if ((key.hasPrefix("SWL")) && (key.hasSuffix("Format"))) {
    //    let start = advance(key.startIndex, 3)
    //    let end = advance(key.endIndex, -6)
    //    let result: String = key[start..<end]
    //    //println("result=\(result)")
    //    return result
    //    }
    
    
    func getFormatKey(_ map: Dictionary<String, AnyObject>) -> String? {
        for (key, _) in map {
            if ((key.hasPrefix("SWL")) && (key.hasSuffix("Format"))) {
                let start = key.characters.index(key.startIndex, offsetBy: 3)
                let end = key.characters.index(key.endIndex, offsetBy: -6)
                let result: String = key[start..<end]
                print("result=\(result)")
                return result
            }
        }
        
        return nil;
    }
    
    
    func getFunctionFormat(_ function: String) -> String {
        var result = function;
        if (result.hasPrefix("Optional(")) {
            let len = "Optional(".characters.count
            let start = result.characters.index(result.startIndex, offsetBy: len)
            let end = result.characters.index(result.endIndex, offsetBy: -len)
            let range = start..<end
            result = result[range]
        }
        if (!result.hasSuffix(")")) {
            result = result + "()"
        }
        return result
    }
    
    
    
}


