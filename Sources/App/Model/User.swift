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
    
    @Field(key: "imageBase64")
    var imageBase64: String?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "phoneNumber")
    var phoneNumber: String?
    
    @Siblings(through: UserChatPivot.self, from: \.$user, to: \.$chat)
    var chats: [Chat]
    
    @Children(for: \Message.$user)
    var messages: [Message]

    init() {}
    init(id: UUID? = nil, name: String, imageBase64: String?, email: String, password: String, phoneNumber: String? = nil) {
        self.id = id
        self.name = name
        self.imageBase64 = imageBase64
        self.email = email
        self.password = password
        self.phoneNumber = phoneNumber
    }
}
