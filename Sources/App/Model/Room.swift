//
//  File.swift
//  
//
//  Created by Gleb Sobolevsky on 07.08.2022.
//

import Vapor

class Room {
    
    weak var app: Application?
    
    private init() {}
    static var shared = Room()
    
    var connections = [UUID: WebSocket]()
    
    func send(message: String) {
        for (_, socket) in connections {
            do {
                let users = Users(users: Array(connections.keys))
                let data = try JSONEncoder().encode(users)
                print("Socket send")
//                socket.send(user.uuidString)
                socket.send([UInt8](data))
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func send(message: Message) {
        print("Room shared send")
        guard let db = app?.db else {
            print("DB is nil")
            return
        }
        
        Chat.find(message.$chat.id, on: db).unwrap(or: Abort(.notFound)).always { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let chat):
                chat.$users.get(on: db).map { users in
                    let data = [UInt8](try! JSONEncoder().encode(message))
                    for user in users {
                        if let userID = user.id, self.connections.keys.contains(userID) {
                            print("send message for \(userID)")
                            self.connections[userID]?.send(data)
                        }
                    }
                }
            }
        }
    }
    
    func send(message: Message, for users: [User]) {
        print("Room shared send")
        let data = [UInt8](try! JSONEncoder().encode(message))
        for user in users {
            print("send before check")
            if let userID = user.id, connections.keys.contains(userID) {
                print("send message for \(userID)")
                connections[userID]?.send(data)
            }
        }
    }
}

struct Users: Codable {
    let users: [UUID]
}
