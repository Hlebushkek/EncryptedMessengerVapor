//
//  User.swift
//  
//
//  Created by Gleb Sobolevsky on 01.08.2022.
//

import Vapor
import Fluent

final class User: Model, Content {
    static let schema = "User"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "number")
    var phoneNumber: String?
    
    @Siblings(through: UserChatPivot.self, from: \.$user, to: \.$chat)
    var chats: [Chat]
    
    @Children(for: \Message.$user)
    var messages: [Message]

    init() {}
    init(id: UUID? = nil, name: String, email: String, phoneNumber: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
    }
}
