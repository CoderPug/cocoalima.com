
import Vapor
import VaporPostgreSQL

let drop = Droplet()

try drop.addProvider(VaporPostgreSQL.Provider.self)
drop.preparations.append(Episode.self)
drop.preparations.append(Host.self)

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
    
    return try podcast.getEpisode(episodeId, request)
}

//  MARK: Podcast-RSS

drop.get("mainswift/rss") { request in
    
    return try podcast.getRSS(request)
}

//  MARK: Podcast-API

drop.group("podcast/api/v1") { v1 in
    
    v1.get("hosts") { request in
        
        return try podcast.APIGetHosts(request)
    }

    v1.get("episodes") { request in
        
        return try podcast.APIGetEpisodes(request)
    }
    
    v1.post("host") { request in
        
        return try podcast.APIPostHost(request)
    }
    
    v1.post("episode") { request in
        
        return try podcast.APIPostEpisode(request)
    }
    
    v1.put("episode", Int.self) { request, episodeId in
        
        return try podcast.APIPutEpisode(episodeId, request)
    }
}

drop.run()
