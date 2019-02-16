//
//  User.swift
//  App
//
//  Created by apple on 2019/1/31.
//

import Foundation
import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    var password: String;
    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username
        self.password = password;
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String;
        var username: String;
        init(id: UUID?, name: String, username: String) {
            self.id = id;
            self.name = name;
            self.username = username;
        }
    }
}

extension User.Public: Content {}

extension User {
    func convertToPublic() -> User.Public {
        let userPublic = User.Public(id: id, name: name, username: username)
        return userPublic;
    }
}

extension User {
    var acronyms: Children<User, Acronym> {
        return children(\.userID)
    }
}

extension User: PostgreSQLUUIDModel {}

extension User: Content {}
extension User: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn, closure: { (builder) in
            try addProperties(to: builder)
            builder.unique(on: \.username)
        })
    }
}
extension User: Parameter {}

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username;
    static let passwordKey: PasswordKey = \User.password;
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User: PasswordAuthenticatable {}
extension User: SessionAuthenticatable {}


extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic();
        }
    }
}

struct AdminUser: Migration {
    typealias Database = PostgreSQLDatabase
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let password = try? BCrypt.hash("password");
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        let user = User(name: "Admin", username: "admin", password: hashedPassword);
        return user.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Future.done(on: conn);
    }
}


