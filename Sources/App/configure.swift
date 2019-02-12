import Vapor
/// 1
import FluentPostgreSQL
import Leaf

public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// 2
    try services.register(FluentPostgreSQLProvider())
    try services.register(LeafProvider())
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(ErrorMiddleware.self)
    middlewares.use(FileMiddleware.self)
    services.register(middlewares)

    /// 3
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let databaseName: String;
    let databasePort: Int;
    let password = Environment.get("DTABASE_PASSWORD") ?? "password"
    if env == .testing {
        databaseName = "vapor-test"
//        databasePort = 5433;
        if let testPort = Environment.get("DATABASE_PORT") {
            databasePort = Int(testPort) ?? 5433;
        } else {
            databasePort = 5433;
        }
    } else {
        databaseName = Environment.get("DATABASE_DB") ?? "vapor"
        databasePort = 5432;
    }
    
    
    
    let postgreSQLDatabaseConfig = PostgreSQLDatabaseConfig(hostname: hostname, port: databasePort, username: username, database: databaseName, password: password);
    let postgresDatabase = PostgreSQLDatabase(config: postgreSQLDatabaseConfig);
    
    var databases = DatabasesConfig()
    ///4
    databases.add(database: postgresDatabase, as: .psql)
    services.register(databases)

    /// 5
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Acronym.self, database: .psql)
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: AcronymCategoryPivot.self, database: .psql)
    services.register(migrations)
    
    var commandConfig = CommandConfig.default();
    commandConfig.useFluentCommands();
    services.register(commandConfig);

    config.prefer(LeafRenderer.self, for: ViewRenderer.self);
}
