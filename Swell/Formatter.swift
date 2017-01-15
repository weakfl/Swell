//
//  Formatter.swift
//  Swell
//
//  Created by Hubert Rabago on 6/20/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//

/// A Log Formatter implementation generates the string that will be sent to a log location
/// if the log level requirement is met by a call to log a message.
public protocol LogFormatter {
    
    /// Formats the message provided for the given logger
    func formatLog<T>(_ logger: Logger, level: LogLevel, message: @autoclosure () -> T,
                   filename: String?, line: Int?,  function: String?) -> String;
    
    /// Returns an instance of this class given a configuration string
    static func logFormatterForString(_ formatString: String) -> LogFormatter;
    
    /// Returns a string useful for describing this class and how it is configured
    func description() -> String;
    
    /// Custom date formatter used when Date part is logged.
    var dateFormatter: DateFormatter { get set }
}


/// Default date format used by QuickFormatter and FlexFormatter
let DefaultDateFormat = "yyyy-MM-dd HH:mm:ss.SSS" // Same as NSLog date format.


public enum QuickFormatterFormat: Int {
    case messageOnly = 0x0001
    case levelMessage = 0x0101
    case nameMessage = 0x0011
    case levelNameMessage = 0x0111
    case dateLevelMessage = 0x1101
    case dateMessage = 0x1001
    case all = 0x1111
}


/// QuickFormatter provides some limited options for formatting log messages.
/// Its primary advantage over FlexFormatter is speed - being anywhere from 20% to 50% faster
/// because of its limited options.
open class QuickFormatter: LogFormatter {
    
    open var dateFormatter: DateFormatter
    let format: QuickFormatterFormat
    
    public init(format: QuickFormatterFormat = .levelNameMessage) {
        self.format = format
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = DefaultDateFormat
    }
    
    open func formatLog<T>(_ logger: Logger, level: LogLevel, message givenMessage: @autoclosure () -> T,
                          filename: String?, line: Int?,  function: String?) -> String {
        var s: String;
        let message = givenMessage()
        switch format {
        case .levelNameMessage:
            s = "\(level.label) \(logger.name): \(message)";
        case .dateLevelMessage:
            s = "\(self.dateFormatter.string(from: Date())) \(level.label): \(message)";
        case .messageOnly:
            s = "\(message)";
        case .nameMessage:
            s = "\(logger.name): \(message)";
        case .levelMessage:
            s = "\(level.label): \(message)";
        case .dateMessage:
            s = "\(self.dateFormatter.string(from: Date())) \(message)";
        case .all:
            s = "\(self.dateFormatter.string(from: Date())) \(level.label) \(logger.name): \(message)";
        }
        return s
    }
    
    open class func logFormatterForString(_ formatString: String) -> LogFormatter {
        var format: QuickFormatterFormat
        switch formatString {
        case "LevelNameMessage": format = .levelNameMessage
        case "DateLevelMessage": format = .dateLevelMessage
        case "MessageOnly": format = .messageOnly
        case "LevelMessage": format = .levelMessage
        case "NameMessage": format = .nameMessage
        case "DateMessage": format = .dateMessage
        default: format = .all
        }
        return QuickFormatter(format: format)
    }
    
    open func description() -> String {
        var s: String;
        switch format {
        case .levelNameMessage:
            s = "LevelNameMessage";
        case .dateLevelMessage:
            s = "DateLevelMessage";
        case .messageOnly:
            s = "MessageOnly";
        case .levelMessage:
            s = "LevelMessage";
        case .nameMessage:
            s = "NameMessage";
        case .dateMessage:
            s = "DateMessage";
        case .all:
            s = "All";
        }
        return "QuickFormatter format=\(s)"
    }
}




public enum FlexFormatterPart: Int {
    case date
    case name
    case level
    case message
    case line
    case `func`
}

/// FlexFormatter provides more control over the log format, allowing
/// the flexibility to specify what data appears and on what order.
open class FlexFormatter: LogFormatter {
    open var dateFormatter: DateFormatter
    var format: [FlexFormatterPart]
    
    public convenience init(parts: FlexFormatterPart...) {
        self.init(parts: parts)
    }
    
    /// This overload is needed (as of Beta 3) because
    /// passing an array to a variadic param is not yet supported
    public init(parts: [FlexFormatterPart]) {
        format = parts
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = DefaultDateFormat
    }
    
    
    open func formatLog<T>(_ logger: Logger, level: LogLevel, message givenMessage: @autoclosure () -> T,
                          filename: String?, line: Int?,  function: String?) -> String {
        var logMessage = ""
        for (index, part) in format.enumerated() {
            switch part {
            case .message:
                let message = givenMessage()
                logMessage += "\(message)"
            case .name: logMessage += logger.name
            case .level: logMessage += level.label
            case .date: logMessage += self.dateFormatter.string(from: Date())
            case .line:
                if (filename != nil) && (line != nil) {
                    logMessage += "[\((filename! as NSString).lastPathComponent):\(line!)]"
                }
            case .func:
                if let function = function {
                    logMessage += "[\(function)]"
                }
            }
            
            if (index < format.count-1) {
                if (format[index+1] == .message) {
                    logMessage += ":"
                }
                logMessage += " "
            }
        }
        return logMessage
    }
    
    
    open class func logFormatterForString(_ formatString: String) -> LogFormatter {
        var formatSpec = [FlexFormatterPart]()
        let parts = formatString.uppercased().components(separatedBy: CharacterSet.whitespaces)
        for part in parts {
            switch part {
            case "MESSAGE": formatSpec += [.message]
            case "NAME": formatSpec += [.name]
            case "LEVEL": formatSpec += [.level]
            case "LINE": formatSpec += [.line]
            case "FUNC": formatSpec += [.func]
            default: formatSpec += [.date]
            }
        }
        return FlexFormatter(parts: formatSpec)
    }
    
    open func description() -> String {
        var desc = ""
        for (index, part) in format.enumerated() {
            switch part {
            case .message: desc += "MESSAGE"
            case .name: desc += "NAME"
            case .level: desc += "LEVEL"
            case .date: desc += "DATE"
            case .line: desc += "LINE"
            case .func: desc += "FUNC"
            }
            
            if (index < format.count-1) {
                desc += " "
            }
        }
        return "FlexFormatter with \(desc)"
    }
    
}

