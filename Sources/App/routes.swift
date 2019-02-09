import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    /*
    /// post方法,/api/acronyms/,带id参数就是更新，不带就是创建
    router.post("api", "acronyms") { (req) -> Future<Acronym> in
       let futureAcroym = try req.content.decode(Acronym.self);
       let result = futureAcroym.flatMap(to: Acronym.self, { (acronym) -> EventLoopFuture<Acronym> in
            acronym.save(on: req);
        })
        return result;
    }
  
    /// 获取所有model
    router.get("api", "acronyms") { (req) -> Future<[Acronym]> in
        return Acronym.query(on: req).all();
    }
    
    /// 获取指定id的model
    router.get("api", "acronyms", Acronym.parameter) { (req) -> Future<Acronym> in
        return try req.parameters.next(Acronym.self);
    }
    
    /// put方法,/api/acronyms/1,带id参数
    router.put("api", "acronyms", Acronym.parameter) { (req) -> Future<Acronym> in
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self), { (acronym, updateAcronym) in
            acronym.short = updateAcronym.short;
            acronym.long = updateAcronym.long;
            return acronym.save(on: req);
        })
    }
    
    /// 删除一个model,/api/acronyms/9
    router.delete("api", "acronyms", Acronym.parameter) { (req) in
        return try req.parameters.next(Acronym.self).delete(on: req).transform(to: HTTPStatus.noContent);
    }
    
    /// 搜索关键字，根据get参数
    router.get("api", "acronyms", "search") { (req) -> Future<[Acronym]> in
        guard
            /// 获取查询字符串,也就是get参数,api/acronyms/search?term=OMG
            let searchTerm = req.query[String.self, at: "term"] else {
                throw Abort(.badRequest);
        }
        
            let long =  req.query[String.self, at: "long"] ?? "";
        if (long.count > 0) {
            /// 查询符合两个条件的,与操作
//            return Acronym.query(on: req).filter(\.short == searchTerm).filter(\.long == long).all();
            /// .or:或操作,.and:与操作
            return Acronym.query(on: req).group(.or, closure: { (or) in
                or.filter(\.short == searchTerm);
                or.filter(\.long == long);
                
            }).all()
        }
        return Acronym.query(on: req).filter(\.short == searchTerm).all();
    }
    
    /// 返回第一个model
    router.get("api", "acronyms", "first") { (req) -> Future<Acronym> in
        return Acronym.query(on: req).sort(\.id, .ascending).first().map(to: Acronym.self, { (acronym) in
            guard let acronym = acronym else {
                throw Abort(.notFound);
            }
            return acronym;
        });
    }
    
    /// 返回所有model并且排序
    router.get("api", "acronyms", "sorted") { (req) -> Future<[Acronym]> in
        return Acronym.query(on: req).sort(\.short, .descending).sort(\.id, .ascending).all();
    }
 
 */
    let accronymsController = AcronymsController();
    try router.register(collection: accronymsController);
    
    let usersController = UsersController()
    try router.register(collection: usersController)
    
    let categoriesController = CategoriesController()
    try router.register(collection: categoriesController)
    
    let websiteController = WebsiteController();
    try router.register(collection: websiteController);
}
