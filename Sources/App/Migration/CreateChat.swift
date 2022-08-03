//
//  CreateChat.swift
//  
//
//  Created by Gleb Sobolevsky on 01.08.2022.
//

import Fluent

struct CreateChat: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("Chat")
            .id()
            .field("name", .string, .required)
            .field("keyBase64", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("Chat").delete()
    }
}
