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
        
        var arrayEpisodes: [Node]?
        
        do {
            
            if let db = drop.database?.driver as? PostgreSQLDriver {
                let resultArray = try db.raw("select * from episodes order by id desc limit 5")
                arrayEpisodes = resultArray.nodeArray
            } else {
                arrayEpisodes = []
            }
            
        } catch {
            
            print(error)
            arrayEpisodes = []
        }
        
        var arrayHosts: [AnyObject]?
        arrayHosts = try? Host.all()
        
        let featuredEpisode: Node?
        if arrayEpisodes != nil && arrayEpisodes!.count > 0 {
            featuredEpisode = arrayEpisodes?.first
            arrayEpisodes?.removeFirst()
        } else {
            featuredEpisode = nil
        }
        
        let arguments: [String: NodeRepresentable]
        
        if featuredEpisode != nil {
            arguments = [
                "featuredEpisode": featuredEpisode ?? EmptyNode,
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
        
        return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom/\" xmlns:content=\"http://purl.org/rss/1.0/modules/content/\" xmlns:itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\"><channel><atom:link rel=\"self\" type=\"application/atom+xml\" href=\"http://cocoalima.com/mainswift/rss\" title=\"MP3 Audio\"/><title>main.swift</title><generator>http://cocoalima.com/mainswift</generator><description>Podcast en español con episodios de conversaciones sobre las últimas novedades en el mundo tecnológico de una manera casual y simple. Además de episodios más técnicos sobre las últimas novedades en el desarrollo para las plataformas de Apple.</description><copyright>© 2016 cocoalima</copyright><language>es</language><pubDate>Mon, 05 Dec 2016 05:00:00 -0800</pubDate><lastBuildDate>Mon, 05 Dec 2016 05:00:00 -0800</lastBuildDate><link>http://cocoalima.com/mainswift</link><image><url>http://www.cocoalima.com/images/mainswiftlogo500x500.png</url><title>main.swift</title><link>http://cocoalima.com/mainswift</link></image><itunes:author>main.swift</itunes:author><itunes:image href=\"http://www.cocoalima.com/images/mainswiftlogo500x500.png\"/><itunes:summary>Podcast en español con episodios de conversaciones sobre las últimas novedades en el mundo tecnológico de una manera casual y simple. Además de episodios más técnicos sobre las últimas novedades en el desarrollo para las plataformas de Apple.</itunes:summary><itunes:subtitle>Podcast en español sobre novedades en el mundo tecnológico y desarrollo con Swift.</itunes:subtitle><itunes:explicit>no</itunes:explicit><itunes:keywords>technology, development, swift, apple, ios, programacion, tecnologia</itunes:keywords><itunes:owner><itunes:name>main.swift</itunes:name><itunes:email>jose.torres@santexgroup.com</itunes:email></itunes:owner><itunes:category text=\"Technology\"/><itunes:category text=\"Technology\"><itunes:category text=\"Tech News\"/></itunes:category><item><title>0: Presentación</title><guid isPermaLink=\"false\">1d47c475-3913-4ef5-8231-aca0d26c54d9</guid><description>Presentación del equipo detrÃ¡s de main.swift 😁</description><content:encoded><![CDATA[<div> <p>Presentación del equipo detrás de main.swift 😁</a></p> <h3>Temas</h3> <ul> <li><strong><a>00:00</a></strong> <a>🐥</a> </li> </ul> </div>]]></content:encoded><pubDate>Sun, 30 Oct 2016 05:00:00 -0800</pubDate><author>main.swift</author><enclosure url=\"https://s3-us-west-2.amazonaws.com/mainswift/mainswift1.mp3\" length=\"20589441\" type=\"audio/mpeg\"/><itunes:author>main.swift</itunes:author><itunes:image href=\"https://s3-us-west-2.amazonaws.com/mainswift/default.png\"/><itunes:duration>00:21:24</itunes:duration><itunes:summary>Presentación del equipo detrás de main.swift 😁</itunes:summary><itunes:subtitle>Presentación del equipo detrás de main.swift 😁</itunes:subtitle><itunes:keywords></itunes:keywords><itunes:explicit>no</itunes:explicit></item></channel></rss>"
    }
    
    //  MARK: - API
    
    func APIGetHosts(_ request: Request) throws -> ResponseRepresentable {
        
        return try JSON(node: Host.all())
    }
    
    func APIGetEpisodes(_ request: Request) throws -> ResponseRepresentable {
        
        return try JSON(node: Episode.all())
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
            let fullDescription = request.data["fulldescription"]?.string else {
                throw Abort.badRequest
        }
        
        var episode = Episode(title: title, shortDescription: shortDescription, fullDescription: fullDescription, imageURL: imageURL, audioURL: audioURL, date: date)
        try episode.save()
        
        return episode
    }
    
    func APIPutEpisode(_ episodeId: Int, _ request: Request) throws -> ResponseRepresentable {
        
        guard let title = request.data["title"]?.string,
            let imageURL = request.data["imageurl"]?.string,
            let audioURL = request.data["audiourl"]?.string,
            let date = request.data["date"]?.string,
            let shortDescription = request.data["shortdescription"]?.string,
            let fullDescription = request.data["fulldescription"]?.string else {
                throw Abort.badRequest
        }
        
        var episode: Episode?
        do {
            episode = try Episode.find(episodeId)
        } catch {
            print(error)
            episode = nil
        }
        
        if episode != nil {
            episode?.update(title: title, shortDescription: shortDescription, fullDescription: fullDescription, imageURL: imageURL, audioURL: audioURL, date: date)
            try episode!.save()
        }
        
        return episode ?? Episode()
    }
    
}
