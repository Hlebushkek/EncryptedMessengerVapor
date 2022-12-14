//
//  Chat.swift
//  
//
//  Created by Gleb Sobolevsky on 01.08.2022.
//

import Vapor
import Fluent

final class Chat: Model, Content {
    static let schema = "Chat"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "imageBase64")
    var imageBase64: String?
    
    @Field(key: "keyBase64")
    var keyBase64: String
    
    @Siblings(through: UserChatPivot.self, from: \.$chat, to: \.$user)
    var users: [User]
    
    @Children(for: \Message.$chat)
    var messages: [Message]

    init() {}
    init(id: UUID? = nil, name: String, imageBase64: String?, keyBase64: String) {
        self.id = id
        self.name = name
        self.imageBase64 = imageBase64
        self.keyBase64 = keyBase64
    }
}
