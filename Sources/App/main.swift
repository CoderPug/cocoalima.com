
import Vapor
import VaporPostgreSQL

let drop = Droplet()

try drop.addProvider(VaporPostgreSQL.Provider.self)

//  MARK: - Welcome

drop.get { req in
    return try drop.view.make("welcome", [
        "message": drop.localization[req.lang, "welcome", "message"],
        "announcement-mainswift": drop.localization[req.lang, "announcements", "mainswift"],
        "announcement-twitter": drop.localization[req.lang, "announcements", "twitter"],
        ])
}

//  MARK: - Podcast

let podcast = PodcastController()
podcast.drop = drop

drop.get("test-db-connection") { request in
    
    return try podcast.getDBVersion(request)
}

drop.get("mainswift") { request in
    
    return try podcast.getHome(request)
}

drop.get("mainswift/episodes") { request in
    
    return try podcast.getEpisodes(request)
}

drop.get("mainswift/episodes/", Int.self) { request, episodeId in
    
    return try podcast.getEpisode(request)
}

drop.run()
