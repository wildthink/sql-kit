public protocol SQLDatabase {
    var logger: Logger { get }
    var dialect: SQLDialect { get }
    func execute(
        sql query: SQLExpression,
        _ onRow: @escaping (SQLRow) -> ()
    )
}

extension SQLDatabase {
    public func serialize(_ expression: SQLExpression) -> (sql: String, binds: [Encodable]) {
        var serializer = SQLSerializer(database: self)
        expression.serialize(to: &serializer)
        return (serializer.sql, serializer.binds)
    }
 }

extension SQLDatabase {
    public func logging(to logger: Logger) -> SQLDatabase {
        CustomLoggerSQLDatabase(database: self, logger: logger)
    }
}

private struct CustomLoggerSQLDatabase: SQLDatabase {
    let database: SQLDatabase
    let logger: Logger
    
    var dialect: SQLDialect {
        self.database.dialect
    }
    
    func execute(sql query: SQLExpression, _ onRow: @escaping (SQLRow) -> ()) {
        self.database.execute(sql: query, onRow)
    }
}
