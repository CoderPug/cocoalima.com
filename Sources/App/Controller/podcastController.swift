//
//  PodcastController.swift
//  cocoalima
//
//  Created by Jose Torres on 15/1/17.
//
//

import Vapor
import HTTP
import VaporPostgreSQL

//  -

final class PodcastController {
    
    var drop = Droplet()
    
    //  MARK: -
    
    /// Get current database version. Response will only return if there exists a valid database connection.
    func getDBVersion(_ request: Request) throws -> ResponseRepresentable {
        
        if let db = drop.database?.driver as? PostgreSQLDriver {
            
            let version = try db.raw("SELECT version()")
            return try JSON(node: version)
            
        } else {
            
            return "No db connection"
        }
    }
    
    /// Get homepage
    func getHome(_ request: Request) throws -> ResponseRepresentable {
        
        var arrayEpisodes: [Episode]?
        
        do {
            
            if let db = drop.database?.driver as? PostgreSQLDriver {
                let resultArray = try db.raw("select * from episodes order by id desc limit 5")
                arrayEpisodes = resultArray.nodeArray?.flatMap { try? Episode(node: $0) }
                
            } else {
                arrayEpisodes = []
            }
            
        } catch {
            
            print(error)
            arrayEpisodes = []
        }
        
        var arrayHosts: [AnyObject]?
        arrayHosts = try? Host.all()
        
        let featuredEpisode: Episode?
        if arrayEpisodes != nil && arrayEpisodes!.count > 0 {
            featuredEpisode = arrayEpisodes?.first
            arrayEpisodes?.removeFirst()
        } else {
            featuredEpisode = nil
        }
        
        let arguments: [String: NodeRepresentable]
        
        if featuredEpisode != nil {
            arguments = [
                "featuredEpisode": try featuredEpisode?.makeNode() ?? EmptyNode,
                "episodes": try arrayEpisodes?.makeNode() ?? EmptyNode,
                "hosts": try (arrayHosts as? [Host])?.makeNode() ?? EmptyNode
            ]
        } else {
            arguments = [
                "episodes": try arrayEpisodes?.makeNode() ?? EmptyNode,
                "hosts": try (arrayHosts as? [Host])?.makeNode() ?? EmptyNode
            ]
        }
        
        return try drop.view.make("mainswift/mainswift", arguments)
    }
    
    /// Get list of available episodes
    func getEpisodes(_ request: Request) throws -> ResponseRepresentable {
        
        var arrayEpisodes: [AnyObject]? = []
        arrayEpisodes = try? Episode.all()
        
        arrayEpisodes?.sort(by: {

            guard let a = $0 as? Episode,
                let b = $1 as? Episode else {
                    return false
            }
            return (a.id?.int ?? 0) > (b.id?.int ?? 0)
        })
        
        var arrayHosts: [AnyObject]? = []
        arrayHosts = try? Host.all()
        
        let arguments = [
            "episodes": try (arrayEpisodes as? [Episode])?.makeNode() ?? EmptyNode,
            "hosts": try (arrayHosts as? [Host])?.makeNode() ?? EmptyNode
        ]
        
        return try drop.view.make("mainswift/episodes", arguments)
    }
    
    /// Get a specific episode with id
    func getEpisode(_ episodeId: Int, _ request: Request) throws -> ResponseRepresentable {
        
        var episode: Episode?
        episode = try Episode.find(episodeId)
        
        var arrayHosts: [AnyObject]? = []
        arrayHosts = try? Host.all()
        
        let arguments: [String: NodeRepresentable]

        if episode != nil {
            arguments = [
                "episode": try episode?.makeNode() ?? EmptyNode,
                "hosts": try (arrayHosts as? [Host])?.makeNode() ?? EmptyNode
            ]
        } else {
            arguments = [
                "hosts": try (arrayHosts as? [Host])?.makeNode() ?? EmptyNode
            ]
        }
        
        return try drop.view.make("mainswift/episode", arguments)
    }
    
    //  MARK: - RSS
    
    func getRSS(_ request: Request) throws -> ResponseRepresentable {
        
        var arrayEpisodes: [Episode]?
        arrayEpisodes = try? Episode.all()

        arrayEpisodes?.sort(by: {
            
            return ($0.0.id?.int ?? 0) > ($0.1.id?.int ?? 0)
        })
        
        var stringEpisodes = ""
        if let arrayEpisodes = arrayEpisodes {
            for episode in arrayEpisodes {
                stringEpisodes.append( RSSItem(episode).representation() )
            }
        }
        
        let xml = XML("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
            "<rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom/\" xmlns:content=\"http://purl.org/rss/1.0/modules/content/\" xmlns:itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\">\n" +
            "  <channel>\n" +
            "    <atom:link rel=\"self\" type=\"application/atom+xml\" href=\"http://cocoalima.com/mainswift/rss\" title=\"MP3 Audio\"/>\n" +
            "    <title>main.swift</title>\n" +
            "    <generator>http://cocoalima.com/mainswift</generator>\n" +
            "    <description>Podcast en español con episodios de conversaciones sobre las últimas novedades en el mundo tecnológico de una manera casual y simple. Además de episodios más técnicos sobre las últimas novedades en el desarrollo para las plataformas de Apple.</description>\n" +
            "    <copyright>© 2016 cocoalima</copyright>\n" +
            "    <language>es</language>\n" +
            "    <pubDate>Mon, 05 Dec 2016 05:00:00 -0800</pubDate>\n" +
            "    <lastBuildDate>Mon, 05 Dec 2016 05:00:00 -0800</lastBuildDate>\n" +
            "    <link>http://cocoalima.com/mainswift</link>\n" +
            "    <image>\n" +
            "      <url>https://s3-us-west-2.amazonaws.com/mainswift/mainswiftlogo1400x1400.png</url>\n" +
            "      <title>main.swift</title>\n" +
            "      <link>http://cocoalima.com/mainswift</link>\n" +
            "    </image>\n" +
            "    <itunes:author>main.swift</itunes:author>\n" +
            "    <itunes:image href=\"https://s3-us-west-2.amazonaws.com/mainswift/mainswiftlogo1400x1400.png\"/>\n" +
            "    <itunes:summary>Podcast en español con episodios de conversaciones sobre las últimas novedades en el mundo tecnológico de una manera casual y simple. Además de episodios más técnicos sobre las últimas novedades en el desarrollo para las plataformas de Apple.</itunes:summary>\n" +
            "    <itunes:subtitle>Podcast en español sobre novedades en el mundo tecnológico y desarrollo con Swift.</itunes:subtitle>\n" +
            "    <itunes:explicit>no</itunes:explicit>\n" +
            "    <itunes:keywords>technology, development, swift, apple, ios, programacion, tecnologia</itunes:keywords>\n" +
            "    <itunes:owner>\n" +
            "      <itunes:name>main.swift</itunes:name>\n" +
            "      <itunes:email>jose.torres@santexgroup.com</itunes:email>\n" +
            "    </itunes:owner>\n" +
            "    <itunes:category text=\"Technology\"/>\n" +
            "    <itunes:category text=\"Technology\">\n" +
            "      <itunes:category text=\"Tech News\"/>\n" +
            "    </itunes:category>\n" +
            stringEpisodes +
            "  </channel>\n" +
            "</rss>")
        return xml
    }
    
    //  MARK: - API
    
    func APIGetHosts(_ request: Request) throws -> ResponseRepresentable {
        
        return try JSON(node: Host.all())
    }
    
    func APIGetEpisodes(_ request: Request) throws -> ResponseRepresentable {
        
        var tarrayEpisodes: [Episode]?
        tarrayEpisodes = try? Episode.all()
        
        guard var arrayEpisodes = tarrayEpisodes else {
            
            throw Abort.badRequest
        }
        
        arrayEpisodes.sort(by: { return ($0.id?.int ?? 0) > ($1.id?.int ?? 0) })
        
        return try arrayEpisodes.makeJSON()
    }
    
    func APIPostHost(_ request: Request) throws -> ResponseRepresentable {
        
        guard let name = request.data["name"]?.string,
            let url = request.data["url"]?.string,
            let imageURL = request.data["imageurl"]?.string else {
                throw Abort.badRequest
        }
        
        var host = Host(name: name, url: url, imageURL: imageURL)
        
        try host.save()
        
        return host
    }
    
    func APIPostEpisode(_ request: Request) throws -> ResponseRepresentable {
        
        guard let title = request.data["title"]?.string,
            let imageURL = request.data["imageurl"]?.string,
            let audioURL = request.data["audiourl"]?.string,
            let date = request.data["date"]?.string,
            let shortDescription = request.data["shortdescription"]?.string,
            let fullDescription = request.data["fulldescription"]?.string,
            let duration = request.data["duration"]?.int else {
                throw Abort.badRequest
        }
        
        var episode = Episode(title: title, shortDescription: shortDescription, fullDescription: fullDescription, imageURL: imageURL, audioURL: audioURL, date: date, duration: duration)
        try episode.save()
        
        return episode
    }
    
    func APIPutEpisode(_ episodeId: Int, _ request: Request) throws -> ResponseRepresentable {
        
        var tepisode: Episode?
        
        do {
            tepisode = try Episode.find(episodeId)
        } catch {
            print(error)
            tepisode = nil
        }
        
        guard var episode = tepisode else {
            
            throw Abort.badRequest
        }
        
        if let title = request.data["title"]?.string {
            episode.title = title
        }
        
        if let imageURL = request.data["imageurl"]?.string {
            episode.imageURL = imageURL
        }
        
        if let audioURL = request.data["audiourl"]?.string {
            episode.audioURL = audioURL
        }
        
        if let date = request.data["date"]?.string {
            episode.date = date
        }
        
        if let shortDescription = request.data["shortdescription"]?.string {
            episode.shortDescription = shortDescription
        }
        
        if let fullDescription = request.data["fulldescription"]?.string {
            episode.fullDescription = fullDescription
        }
        
        if let duration = request.data["duration"]?.int {
            episode.duration = duration
        }
        
        try episode.save()
        
        return episode
    }
    
}
