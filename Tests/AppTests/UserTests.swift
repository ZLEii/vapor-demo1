//
//  UserTests.swift
//  App
//
//  Created by apple on 2019/2/5.
//

import Foundation

@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTests: XCTestCase {
    /*
    func testUserscanBeRetrievedFromAPI() throws{
        /// 复原数据库(清空数据库)
        // 1
        let revertEnvironmentArgs = ["vapor", "revert", "--all", "-y"]
        // 2
        var revertConfig = Config.default()
        var revertServices = Services.default()
        var revertEnv = Environment.testing
        // 3
        revertEnv.arguments = revertEnvironmentArgs
        // 4
        try App.configure(&revertConfig, &revertEnv, &revertServices)
        let revertApp = try Application(
            config: revertConfig,
            environment: revertEnv,
            services: revertServices)
        try App.boot(revertApp)
        // 5
        try revertApp.asyncRun().wait()
        // 6
        let migrateEnvironmentArgs = ["vapor", "migrate", "-y"]
        var migrateConfig = Config.default()
        var migrateServices = Services.default()
        var migrateEnv = Environment.testing
        migrateEnv.arguments = migrateEnvironmentArgs
        try App.configure(&migrateConfig, &migrateEnv, &migrateServices)
        let migrateApp = try Application(
            config: migrateConfig,
            environment: migrateEnv,
            services: migrateServices)
        try App.boot(migrateApp)
        try migrateApp.asyncRun().wait()
        ////////////////////////////////////////////////////////////////
        
        /// 保存一个用户到数据库
        let expectedName = "Alice"
        let expectedUsername = "alice"
        
        var config = Config.default();
        var services = Services.default();
        var env = Environment.testing;
        try App.configure(&config, &env, &services)
        let app = try Application(config: config, environment: env, services: services);
        try App.boot(app);
        let conn = try app.newConnection(to: .psql).wait();
        
        let user = User(name: expectedName, username: expectedUsername)
        let saveUser = try user.save(on: conn).wait();
        
        /// 保存第二个用户到数据库
        _ = try User(name: "Luke", username: "lukes").save(on: conn).wait;
        let responder = try app.make(Responder.self);
        /// 获取所有用户
        let request = HTTPRequest(method: .GET, url: URL(string: "/api/users")!)
        let wrappedRequest = Request(http: request, using: app)
        let response = try responder.respond(to: wrappedRequest).wait()
        let data = response.http.body.data;
        let users = try JSONDecoder().decode([User].self, from: data!)
        
        XCTAssertEqual(users.count, 2);
        XCTAssertEqual(users[0].name, expectedName)
        XCTAssertEqual(users[0].username, expectedUsername)
        XCTAssertEqual(users[0].id, saveUser.id)
        
        /// 关闭数据库连接
        conn.close();
    }
 */
    let usersName = "Alice";
    let userUsername = "alicea";
    let usersURI = "/api/users/";
    var app: Application!
    var conn: PostgreSQLConnection!
    
    override func setUp() {
        try! Application.reset();
        app = try! Application.testable();
        conn = try! app.newConnection(to: .psql).wait();
    }
    
    override func tearDown() {
        conn.close();
    }
    
    func testUsersCanBeRetrievedFromAPI() throws {
        let user = try User.create(name: usersName, username: userUsername, on: conn)
        _ = try User.create(on: conn)
        
        let users = try app.getResponse(to: usersURI, decodeTo: [User.Public].self);
        
        XCTAssertEqual(users.count, 3)
        XCTAssertEqual(users[1].name, usersName);
        XCTAssertEqual(users[1].username, userUsername);
        XCTAssertEqual(users[1].id, user.id);
    }
    
    func testUserCanBeSavedWithAPI() throws {
        let user = User(name: usersName, username: userUsername, password: "password")
        let receivedUser = try app.getResponse(to: usersURI, method: .POST, headers: ["Content-Type":"application/json"], data: user, decodeTo: User.Public.self,loggedInRequest: true)
        
        XCTAssertEqual(receivedUser.name, usersName);
        XCTAssertEqual(receivedUser.username, userUsername);
        XCTAssertNotNil(receivedUser.id);
        
        let users = try app.getResponse(to: usersURI, decodeTo: [User.Public].self);
        
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[1].name, usersName)
        XCTAssertEqual(users[1].username, userUsername)
        XCTAssertEqual(users[1].id, receivedUser.id)
    }
    
    func testGettingASingleUserFromTheAPI() throws {
        let user = try User.create(name: usersName, username: userUsername, on: conn);
        let receivedUser = try app.getResponse(to: "\(usersURI)\(user.id!)",decodeTo: User.Public.self);
        XCTAssertEqual(receivedUser.name, usersName);
        XCTAssertEqual(receivedUser.username, userUsername);
        XCTAssertEqual(receivedUser.id, user.id);
    }
    
    func testGettingAUsersAcronymsFromTheAPI() throws {
        let user = try User.create(on: conn);
        let acronymShort = "OMG"
        let acronymLong = "Oh My God";
        let acronym1 = try Acronym.create(short: acronymShort, long: acronymLong, user: user, on: conn);
        _ = try Acronym.create(short: "LOL", long: "Laugh Out Loud", user: user, on: conn)
        
        let acronyms = try app.getResponse(to: "\(usersURI)\(user.id!)/acronyms", decodeTo: [Acronym].self);
        
        XCTAssertEqual(acronyms.count, 2)
        XCTAssertEqual(acronyms[0].id, acronym1.id)
        XCTAssertEqual(acronyms[0].short, acronymShort)
        XCTAssertEqual(acronyms[0].long, acronymLong)
    }
    
    static let allTests = [
        ("testUsersCanBeRetrievedFromAPI",
         testUsersCanBeRetrievedFromAPI),
        ("testUserCanBeSavedWithAPI", testUserCanBeSavedWithAPI),
        ("testGettingASingleUserFromTheAPI",
         testGettingASingleUserFromTheAPI),
        ("testGettingAUsersAcronymsFromTheAPI",
         testGettingAUsersAcronymsFromTheAPI)
    ]
}
