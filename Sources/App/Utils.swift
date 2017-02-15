//
//  Utils.swift
//  cocoalima
//
//  Created by Jose Torres on 14/2/17.
//
//

import Foundation

extension String {

    /// String date must be in the format yyyyMMdd
    ///
    /// - Returns: String in the format requested
    public func formattedDate(with format: String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = TimeZone.current
        
        guard let date = formatter.date(from: self) else {
            
            return ""
        }
        
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    /// String date must be in the format yyyyMMdd
    ///
    /// - Returns: String in format "E, d MMM yyyy HH:mm:ss Z"
    public func formattedDateA() -> String {
        
        return self.formattedDate(with: "E, d MMM yyyy HH:mm:ss Z")
    }
    
    /// String date must be in the format yyyyMMdd
    ///
    /// - Returns: String in format "MMM d, yyyy"
    public func formattedDateB() -> String {
        
        return self.formattedDate(with: "MMM d, yyyy")
    }
    
}

extension Int {
    
    /// Convert seconds in formatted string
    ///
    /// - Returns: Formatted string like "h:m:s"
    public func toDurationString() -> String {
    
        let h = self / 3600
        let m = (self % 3600) / 60
        let s = (self % 3600) % 60
        
        return String(format: "%02d:%02d:%02d", h,m,s)
    }
    
}
