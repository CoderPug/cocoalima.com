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
        
        return try drop.view.make("mainswift/mainswift")
    }
    
    /// Get list of available episodes
    func getEpisodes(_ request: Request) throws -> ResponseRepresentable {
        
        return try drop.view.make("mainswift/episodes")
    }
    
    /// Get a specific episode with id
    func getEpisode(_ request: Request) throws -> ResponseRepresentable {
        
        return try drop.view.make("mainswift/episode")
    }
}
