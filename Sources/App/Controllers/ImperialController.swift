//
//  ImperialController.swift
//  App
//
//  Created by apple on 2019/2/16.
//

import Vapor
import Imperial
import Authentication

struct GoogleUserInfo: Content {
    let email: String
    let name: String
}

struct ImperialController: RouteCollection {
    func boot(router: Router) throws {
        guard let callbackURL = Environment.get("GOOGLE_CALLBACK_URL") else {
            fatalError("Calback URL not set");
        }
        try router.oAuth(from: Google.self, authenticate: "login-google", callback: callbackURL, scope: ["profile", "email"], completion: processGoogleLogin)
        
    }
    
    func processGoogleLogin(req: Request, token: String) throws -> Future<ResponseEncodable> {
        return req.future(req.redirect(to: "/"))
    }
}
