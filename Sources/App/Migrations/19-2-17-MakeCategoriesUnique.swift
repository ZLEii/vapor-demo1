//
//  19-2-17-MakeCategoriesUnique.swift
//  App
//
//  Created by apple on 2019/2/17.
//

import FluentPostgreSQL
import Vapor

struct MakeCategoriesUnique: Migration {
    typealias Database = PostgreSQLDatabase
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Category.self, on: conn, closure: { (builder) in
            builder.unique(on: \.name);
            
        })
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Category.self, on: conn, closure: { (builder) in
            builder.deleteUnique(from: \.name);
        })
    }
}
