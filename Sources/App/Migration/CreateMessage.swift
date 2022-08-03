//
//  CreateMessage.swift
//  
//
//  Created by Gleb Sobolevsky on 31.07.2022.
//

import Fluent

struct CreateMessage: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("Message")
            .id()
        
            .field("content", .string, .required)
            .field("date", .string)
            
            .field("user_id", .uuid, .references("User", "id"))
            .field("chat_id", .uuid, .references("Chat", "id"))
        
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("Message").delete()
    }
}
