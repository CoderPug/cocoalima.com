//
//  RSS.swift
//  cocoalima
//
//  Created by Jose Torres on 18/1/17.
//
//

import HTTP

public struct XML {
    public var content: String
    
    public init(_ string: String) {
        self.content = string
    }
}

extension XML {
    public func serialize(
        prettyPrint: Bool = false
        ) throws -> Bytes {
        return self.content.bytes
    }
}

extension Response {
    /**
     Convenience Initializer
     
     - parameter status: the http status
     - parameter xml: xml object
     */
    public convenience init(status: Status, xml: XML) throws {
        let headers: [HeaderKey: String] = [
            "Content-Type": "application/rss+xml; charset=utf-8"
        ]
        self.init(status: status, headers: headers, body: try xml.serialize())
    }
}

extension XML: ResponseRepresentable {
    public func makeResponse() throws -> Response {
        return try Response(status: .ok, xml: self)
    }
}
