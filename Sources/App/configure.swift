import Fluent
import FluentMongoDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    try app.databases.use(.mongo(
        connectionString: Environment.get("DATABASE_URL") ?? "mongodb://localhost:27017/encrypted_messenger_database"
    ), as: .mongo)
    
    app.views.use(.leaf)
    
    app.routes.defaultMaxBodySize = "500kb"
    
    app.migrations.add(CreateUser())
    app.migrations.add(CreateChat())
    app.migrations.add(CreateUserChatPivot())
    app.migrations.add(CreateMessage())
    
    // register routes
    try routes(app)
}
