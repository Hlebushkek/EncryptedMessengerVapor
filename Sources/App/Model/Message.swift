//
//  Message.swift
//  
//
//  Created by Gleb Sobolevsky on 31.07.2022.
//

import Vapor
import Fluent

final class Message: Model, Content {
    
    static let schema = "Message"
    
    @ID
    var id: UUID?
    
    @Field(key: "content")
    var content: String
    
    @Timestamp(key: "date", on: .create, format: .iso8601)
    var date: Date?
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "chat_id")
    var chat: Chat
    
    init() {}
    init(id: UUID? = nil, content: String, userID: User.IDValue, chatID: Chat.IDValue) {
        self.content = content
        self.$user.id = userID
        self.$chat.id = chatID
    }
}
