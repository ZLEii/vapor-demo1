import Vapor
/// 1
import FluentPostgreSQL

public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// 2
    try services.register(FluentPostgreSQLProvider())

    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)

    /// 3
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
    let password = Environment.get("DTABASE_PASSWORD") ?? "password"
    
    let postgreSQLDatabaseConfig = PostgreSQLDatabaseConfig(hostname: hostname, port: 5432, username: username, database: databaseName, password: password);
    let postgresDatabase = PostgreSQLDatabase(config: postgreSQLDatabaseConfig);
    
    var databases = DatabasesConfig()
//    databases.add(database: sqlite, as: .sqlite)
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

}
