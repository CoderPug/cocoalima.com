//
//  RSS.swift
//  cocoalima
//
//  Created by Jose Torres on 18/1/17.
//
//

import HTTP

//  MARK: - XML

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

//  MARK: - RSSItem

struct RSSItem {
    
    let title: String
    let guid: String
    let description: String
    let content: String
    let imageURL: String
    let duration: String
    let pubDate: String
    let author: String
    let enclosure: RSSItemEnclosure
    
    struct RSSItemEnclosure {
        
        let url: String
        let length: Int
        let type: String
        
        func representation() -> String {

            return "<enclosure url=\"" + url + "\" length=\"\(length)\" type=\"" + type + "\"/>"
        }
    }
    
    func getTitleTag() -> String {
        return "<title>" + title + "</title>"
    }
    
    func getGUIDTag() -> String {
        return "<guid isPermaLink=\"false\">" + guid + "</guid>"
    }
    
    func getDescription() -> String {
        return "<description>" + description + "</description>"
    }
    
    func getContent() -> String {
        return "      <content:encoded>\n" +
        "        <![CDATA[" + content + "]]>\n" +
        "      </content:encoded>\n"
    }
    
    func getPubDate() -> String {       
        return "<pubDate>" + pubDate.formattedDateA() + "</pubDate>"
    }
    
    func getAuthor() -> String {
        return "<author>" + author + "</author>"
    }
    
    func representation() -> String {
        return
            "    <item>\n" +
                "      " + self.getTitleTag() + "\n" +
                "      " + self.getGUIDTag() + "\n" +
                "      " + self.getDescription() + "\n" +
                self.getContent() +
                "      " + self.getPubDate() + "\n" +
                "      " + self.getAuthor() + "\n" +
                "      " + self.enclosure.representation() + "\n" +
                "      <itunes:author>" + author + "</itunes:author>\n" +
                "      <itunes:image href=\"" + imageURL + "\"/>\n" +
                "      <itunes:duration>" + duration + "</itunes:duration>\n" +
                "      <itunes:summary>" + description + "</itunes:summary>\n" +
                "      <itunes:subtitle>" + description + "</itunes:subtitle>\n" +
                "      <itunes:keywords></itunes:keywords>\n" +
                "      <itunes:explicit>no</itunes:explicit>\n" +
        "    </item>\n"
    }
}

extension RSSItem {
    
    init(_ episode: Episode) {
        
        self.title = episode.title
        self.guid = "1234567890"
        self.description = episode.shortDescription
        self.content = episode.fullDescription
        self.pubDate = episode.date
        self.author = "main.swift"
        self.imageURL = "https://s3-us-west-2.amazonaws.com/mainswift/default.png"
        self.duration = "00:20:15"
        self.enclosure = RSSItemEnclosure(url: "https://s3-us-west-2.amazonaws.com/mainswift/mainswift2.mp3", length: 1260, type: "audio/mpeg")
    }
}
