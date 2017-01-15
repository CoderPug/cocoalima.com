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
    var date: String
    var title: String
    var imageURL: String
    var audioURL: String
    var shortDescription: String
    var fullDescription: String
    
    init(title: String, shortDescription: String, fullDescription: String, imageURL: String, audioURL: String, date: String) {
        self.title = title
        self.shortDescription = shortDescription
        self.fullDescription = fullDescription
        self.imageURL = imageURL
        self.audioURL = audioURL
        self.date = date
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        title = try node.extract("title")
        shortDescription = try node.extract("shortdescription")
        fullDescription = try node.extract("fulldescription")
        imageURL = try node.extract("imageurl")
        audioURL = try node.extract("audiourl")
        date = try node.extract("date")
    }
    
    convenience init() {
        self.init(title: "", shortDescription: "", fullDescription: "", imageURL: "", audioURL: "", date: "")
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
        ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("episodes") { episodes in
            episodes.id()
            episodes.string("title")
            episodes.string("imageurl")
            episodes.string("audiourl")
            episodes.string("date")
            episodes.string("shortdescription")
            episodes.string("fulldescription", length: 3000)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("episodes")
    }
    
    
    //  MARK:
    
    func update(title: String, shortDescription: String, fullDescription: String, imageURL: String, audioURL: String, date: String) {
        self.title = title
        self.shortDescription = shortDescription
        self.fullDescription = fullDescription
        self.imageURL = imageURL
        self.audioURL = audioURL
        self.date = date
    }
    
}
