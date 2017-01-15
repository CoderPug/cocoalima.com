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
        
//        var arrayHosts: [AnyObject]? = []
        
        let featuredEpisode: Node?
        if arrayEpisodes != nil && arrayEpisodes!.count > 0 {
            featuredEpisode = arrayEpisodes?.first
            arrayEpisodes?.removeFirst()
        } else {
            featuredEpisode = nil
        }
        
        var argument: [String: NodeRepresentable]
        
        if featuredEpisode != nil {
            argument = [
                "swiftLogoURL": "images/mainswiftlogo500x500.png",
                "featuredEpisode": EmptyNode,
                "episodes": EmptyNode,
                "hosts": EmptyNode
            ]
        } else {
            argument = [
                "swiftLogoURL": "images/mainswiftlogo500x500.png",
                "episodes": EmptyNode,
                "hosts": EmptyNode
            ]
        }
        
        return try! drop.view.make("mainswift", argument)
    }
}
