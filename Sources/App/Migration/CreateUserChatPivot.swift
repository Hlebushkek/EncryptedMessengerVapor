//
//  CreateUserChatPivot.swift
//  
//
//  Created by Gleb Sobolevsky on 01.08.2022.
//

import Fluent

struct CreateUserChatPivot: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user-chat-pivot")
        
        .id()
        
        .field("userID", .uuid, .required, .references("users", "id", onDelete: .cascade))
        .field("chatID", .uuid, .required, .references("chats", "id", onDelete: .cascade))
        
        .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("ser-chat-pivot").delete()
    }
}
