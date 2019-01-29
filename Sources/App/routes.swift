import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.post("api", "acronyms") { (req) -> Future<Acronym> in
       let futureAcroym = try req.content.decode(Acronym.self);
       let result = futureAcroym.flatMap(to: Acronym.self, { (acronym) -> EventLoopFuture<Acronym> in
            acronym.save(on: req);
        })
        return result;
    }
  
}
