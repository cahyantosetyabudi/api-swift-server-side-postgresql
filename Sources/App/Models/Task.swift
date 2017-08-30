import Vapor
import FluentProvider
import HTTP

final class Task: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    /// The content of the post
    var title: String
    
    /// The column names for `id` and `content` in the database
    static let idKey = "id"
    static let titleKey = "title"
    
    /// Creates a new Post
    init(title: String) {
        self.title = title
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        title = try row.get(Task.titleKey)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Task.titleKey, title)
        return row
    }
}

// MARK: Fluent Preparation

extension Task: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Task.titleKey)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension Task: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            title: json.get(Task.titleKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Task.idKey, id)
        try json.set(Task.titleKey, title)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension Task: ResponseRepresentable { }

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension Task: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Task>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Task.titleKey, String.self) { task, title in
                task.title = title
            }
        ]
    }
}
