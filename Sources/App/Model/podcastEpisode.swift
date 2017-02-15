//
//  podcastEpisode.swift
//  cocoalima
//
//  Created by Jose Torres on 15/1/17.
//
//

import Vapor
import Fluent

final class Episode: Model {
    
    var id: Node?
    /// Date format : YYYYMMdd
    var date: String
    /// Date format : MMM d, yyyy
    var formattedDate: String
    var title: String
    var imageURL: String
    var audioURL: String
    var duration: Int
    /// Duration format: hh:mm:ss
    var formattedDuration: String
    var shortDescription: String
    var fullDescription: String
    var exists: Bool = false
    
    init(title: String, shortDescription: String, fullDescription: String, imageURL: String, audioURL: String, date: String, duration: Int) {
        self.title = title
        self.shortDescription = shortDescription
        self.fullDescription = fullDescription
        self.imageURL = imageURL
        self.audioURL = audioURL
        self.date = date
        self.duration = duration
        self.formattedDate = self.date.formattedDateB()
        self.formattedDuration = self.duration.toDurationString()
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        title = try node.extract("title")
        shortDescription = try node.extract("shortdescription")
        fullDescription = try node.extract("fulldescription")
        imageURL = try node.extract("imageurl")
        audioURL = try node.extract("audiourl")
        date = try node.extract("date")
        duration = try node.extract("duration")
        formattedDate = date.formattedDateB()
        formattedDuration = duration.toDurationString()
    }
    
    convenience init(node: Node) throws {
        self.init()
        id = try node.extract("id")
        title = try node.extract("title")
        shortDescription = try node.extract("shortdescription")
        fullDescription = try node.extract("fulldescription")
        imageURL = try node.extract("imageurl")
        audioURL = try node.extract("audiourl")
        date = try node.extract("date")
        duration = try node.extract("duration")
        formattedDate = date.formattedDateB()
        formattedDuration = duration.toDurationString()
    }
    
    convenience init() {
        self.init(title: "", shortDescription: "", fullDescription: "", imageURL: "", audioURL: "", date: "", duration: 0)
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "title": title,
            "imageurl": imageURL,
            "audiourl": audioURL,
            "date": date,
            "shortdescription": shortDescription,
            "fulldescription": fullDescription,
            "formattedDate": date.formattedDateB(),
            "duration": duration,
            "formattedDuration": duration.toDurationString()
        ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("episodes") { episodes in
            episodes.id()
            episodes.string("title")
            episodes.string("imageurl")
            episodes.string("audiourl")
            episodes.string("date")
            episodes.string("formattedDate")
            episodes.string("shortdescription")
            episodes.int("duration")
            episodes.string("formattedDuration")
            episodes.string("fulldescription", length: 3000)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("episodes")
    }
    
    
    //  MARK:
    
    func update(title: String, shortDescription: String, fullDescription: String, imageURL: String, audioURL: String, date: String, duration: Int) {
        self.title = title
        self.shortDescription = shortDescription
        self.fullDescription = fullDescription
        self.imageURL = imageURL
        self.audioURL = audioURL
        self.date = date
        self.duration = duration
        self.formattedDuration = self.duration.toDurationString()
        self.formattedDate = self.date.formattedDateB()
    }
    
}
