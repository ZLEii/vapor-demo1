//
//  UsersController.swift
//  App
//
//  Created by apple on 2019/1/31.
//

import Vapor
import Crypto

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        usersRoute.post(User.self, use: createHandler)
        
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.parameter, use: getHandler)
        usersRoute.get(User.parameter, "acronyms", use: getAcronymsHandler)
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
        user.password = try BCrypt.hash(user.password);
        let result = user.save(on: req).convertToPublic();
        
//        return user.save(on: req).map(to: User.Public.self) { (user:User) -> User.Public in
//            let publicUser = User.Public(id: user.id, name: user.name, username: user.username);
//            return publicUser;
//        }
//        result.map { (userPublic:User.Public) in
//            print(userPublic.username)
//        }
        return result;
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all();
    }

    func getHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).convertToPublic();
    }
    
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(User.self).flatMap(to: [Acronym].self) { user in
            try user.acronyms.query(on: req).all();
        }
    }
}
