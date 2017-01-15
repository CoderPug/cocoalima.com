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
        
        let arguments = ["swiftLogoURL": "images/mainswiftlogo500x500.png"]
        
        return try drop.view.make("mainswift/mainswift", arguments)
    }
}
