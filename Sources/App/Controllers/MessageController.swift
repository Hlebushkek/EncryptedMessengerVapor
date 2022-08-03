//
//  MessageController.swift
//  
//
//  Created by Gleb Sobolevsky on 31.07.2022.
//

import Vapor
import Fluent

struct CreateMessageData: Content {
    let content: String
    let userID: UUID
    let chatID: UUID
}

struct MessageController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let messageRoute = routes.grouped("api", "message")
        
        messageRoute.get(use: getAllHandler)
        messageRoute.post(use: createHandler)
        messageRoute.get(":messageID", use: getHandler)
        messageRoute.put(":messageID", use: updateHandler)
        messageRoute.delete(":messageID", use: deleteHandler)
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[Message]> {
        return Message.query(on: req.db).all()
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Message> {
        let data = try req.content.decode(CreateMessageData.self)
        let message = Message(content: data.content, userID: data.userID, chatID: data.chatID)
        return message.save(on: req.db).map { message }
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<Message> {
        Message.find(req.parameters.get("messageID"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Message> {
        let updatedMessage = try req.content.decode(Message.self)
        return Message.find(req.parameters.get("messageID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { message in
            message.content = updatedMessage.content
            message.date = updatedMessage.date
            return message.save(on: req.db).map { message }
        }
    }
    
    func deleteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Message.find(req.parameters.get("messageID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { message in
            message.delete(on: req.db).transform(to: .noContent)
        }
    }
}
