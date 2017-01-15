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
    
}
