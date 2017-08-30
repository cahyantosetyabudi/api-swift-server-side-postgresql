import Vapor

extension Droplet {
    func setupRoutes() throws {
                
        get("version") { req in
            let node = try Post.database?.driver.raw("SELECT VERSION();")
            
            return try JSON(node: node)
        }
        
        get("tasks") { req in
            let tasks = try Task.all()
            
            return try tasks.makeJSON()
        }
        
        post("task") { req in
            guard let title = req.json?["title"]?.string else {
                return try JSON(node: ["title is null"])
            }
            
            let task = Task(title: title)
            try task.save()
            
            return try task.makeJSON()
        }
        
        delete("task") { req in
            guard let taskId = req.json?["taskId"]?.int else {
                throw Abort.badRequest
            }
            
            let task = try Task.find(taskId)
            try task?.delete()
            
            return try JSON(node: ["Task has been deleted"])
        }
        
    }
}
