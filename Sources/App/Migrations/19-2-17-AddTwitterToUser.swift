//
//  19-2-17-AddTwitterToUser.swift
//  App
//
//  Created by apple on 2019/2/17.
//

import FluentPostgreSQL
import Vapor

struct AddTwitterURLToUser: Migration {
    typealias Database = PostgreSQLDatabase
    static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(User.self, on: connection, closure: { (builder) in
            builder.field(for: \.twitterURL)
        })
    }
    
    static func revert(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(User.self, on: connection, closure: { (builder) in
            builder.deleteField(for: \.twitterURL)
        })
    }
}
