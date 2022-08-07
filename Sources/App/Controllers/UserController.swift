//
//  UserController.swift
//  
//
//  Created by Gleb Sobolevsky on 01.08.2022.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoute = routes.grouped("api", "user")
        
        userRoute.get(use: getAllHandler)
        userRoute.post(use: createHandler)
        userRoute.get(":userID", use: getHandler)
        userRoute.put(":userID", use: updateHandler)
        userRoute.delete(":userID", use: deleteHandler)
        userRoute.get("search", use: searchHandler)
        userRoute.post(":userID", "chat", ":chatID", use: addChatHandler)
        userRoute.get(":userID", "chat", use: getChatsHandler)
        userRoute.delete(":userID","chat",":chatID", use: removeChatHandler)
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db).map { user }
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<User> {
        User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let updatedUser = try req.content.decode(User.self)
        return User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { user in
            user.name = updatedUser.name
            user.imageBase64 = updatedUser.imageBase64
            user.email = updatedUser.email
            user.password = updatedUser.password
            user.phoneNumber = updatedUser.phoneNumber
            return user.save(on: req.db).map { user }
        }
    }
    
    func deleteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { user in
            user.delete(on: req.db).transform(to: .noContent)
        }
    }
    
    func searchHandler(_ req: Request) throws -> EventLoopFuture<User> {
        guard let searchEmail = req.query[String.self, at: "email"],
              let searchPassword = req.query[String.self, at: "password"] else {
            throw Abort(.badRequest)
        }
        return User.query(on: req.db).group(.and) { and in
            and.filter(\.$email == searchEmail)
            and.filter(\.$password == searchPassword)
        }.first().unwrap(or: Abort(.notFound))
    }
    
    //MARK: USER <-> CHAT Relationship
    func addChatHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        let userQuery = User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound))
        let chatQuery = Chat.find(req.parameters.get("chatID"), on: req.db).unwrap(or: Abort(.notFound))
        
        return userQuery.and(chatQuery).flatMap { user, chat in
            user.$chats.attach(chat, on: req.db).transform(to: .created)
        }
    }
    
    func getChatsHandler(_ req: Request) -> EventLoopFuture<[Chat]> {
        User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { user in
            user.$chats.query(on: req.db).all()
        }
    }
    
    func removeChatHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        let userQuery = User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound))
        let chatQuery = Chat.find(req.parameters.get("chatID"), on: req.db).unwrap(or: Abort(.notFound))
        
        return userQuery.and(chatQuery).flatMap { user, chat in
            user.$chats.detach(chat, on: req.db).transform(to: .noContent)
        }
    }
}

