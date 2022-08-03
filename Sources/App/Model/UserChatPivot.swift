//
//  UserChatPivot.swift
//  
//
//  Created by Gleb Sobolevsky on 01.08.2022.
//

import Fluent
import Foundation

final class UserChatPivot: Model {
    static let schema = "user-chat-pivot"

    @ID
    var id: UUID?
    
    @Parent(key: "userID")
    var user: User
    @Parent(key: "chatID")
    var chat: Chat
    
    init() {}
    init(id: UUID? = nil, user: User, chat: Chat) throws {
        self.id = id
        self.$user.id = try user.requireID()
        self.$chat.id = try chat.requireID()
    }
}
