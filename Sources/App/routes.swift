import Vapor

let room = Room.shared

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    try app.register(collection: MessageController())
    try app.register(collection: ChatController())
    try app.register(collection: UserController())
    
    app.webSocket("echo", maxFrameSize: .init(integerLiteral: 1 << 20)) { req, ws in
        ws.onText { ws, text in
            print("OnText")
        }
        ws.onBinary { ws, data in
            print("OnBinary")
            guard let user = try? JSONDecoder().decode(User.self, from: data),
                  let userID = user.id
            else {
                print("Undefined data")
                return
            }
            room.connections[userID] = ws
            room.send(message: "Hi i am webSocket")
        }
    }
}
