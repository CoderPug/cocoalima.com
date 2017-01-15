import Vapor

let drop = Droplet()

drop.get { req in
    return try drop.view.make("welcome", [
        "message": drop.localization[req.lang, "welcome", "message"],
        "announcement-mainswift": drop.localization[req.lang, "announcements", "mainswift"],
        "announcement-twitter": drop.localization[req.lang, "announcements", "twitter"],
        ])
}

drop.run()
