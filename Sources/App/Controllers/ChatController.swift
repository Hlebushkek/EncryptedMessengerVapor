//
//  ChatController.swift
//  
//
//  Created by Gleb Sobolevsky on 01.08.2022.
//

import Vapor
import Fluent

struct ChatController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let chatRoute = routes.grouped("api", "chat")
        
        chatRoute.get(use: getAllHandler)
        chatRoute.post(use: createHandler)
        chatRoute.get(":chatID", use: getHandler)
        chatRoute.put(":chatID", use: updateHandler)
        chatRoute.delete(":chatID", use: deleteHandler)
        chatRoute.get(":chatID", "user", use: getUsersHandler)
        chatRoute.get(":chatID", "message", use: getChatMessagesHandler)
        chatRoute.get("search", use: searchHandler)
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[Chat]> {
        return Chat.query(on: req.db).all()
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Chat> {
        let chat = try req.content.decode(Chat.self)
        return chat.save(on: req.db).map { chat }
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<Chat> {
        Chat.find(req.parameters.get("chatID"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Chat> {
        let updatedChat = try req.content.decode(Chat.self)
        return Chat.find(req.parameters.get("chatID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { chat in
            chat.name = updatedChat.name
            chat.keyBase64 = updatedChat.keyBase64
            return chat.save(on: req.db).map { chat }
        }
    }
    
    func deleteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Chat.find(req.parameters.get("chatID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { chat in
            chat.delete(on: req.db).transform(to: .noContent)
        }
    }
    
    func searchHandler(_ req: Request) throws -> EventLoopFuture<Chat> {
        guard let searchName = req.query[String.self, at: "name"] else {
            throw Abort(.badRequest)
        }
        return Chat.query(on: req.db).group() { chats in
            chats.filter(\.$name == searchName)
        }.first().unwrap(or: Abort(.notFound))
    }
    
    func getUsersHandler(_ req: Request) -> EventLoopFuture<[User]> {
        Chat.find(req.parameters.get("chatID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { chat in
            chat.$users.get(on: req.db)
        }
    }
    
    func getChatMessagesHandler(_ req: Request) -> EventLoopFuture<[Message]> {
        Chat.find(req.parameters.get("chatID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { chat in
            chat.$messages.get(on: req.db)
        }
    }
}
