//
//  CreateUser.swift
//  
//
//  Created by Gleb Sobolevsky on 01.08.2022.
//

import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("User")
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("phoneNumber", .string)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("User").delete()
    }
}
