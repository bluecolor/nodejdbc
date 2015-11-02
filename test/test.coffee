test = require 'unit.js'
NodeJDBC = require '../lib/nodejdbc'

config = 
    libs : ['lib/sqlite-jdbc-3.8.11.2.jar']
    className: 'org.sqlite.JDBC'
    url: 'jdbc:sqlite:test.db'

describe 'NodeJDBC', ->
    it 'Connection', ->
        nodejdbc = new NodeJDBC config
        test.promise
        .given ->
            nodejdbc.getConnection()
        .then (connection) ->
            test.must(connection.isValid 2).be true
            test.must(connection.isClosed()).be false
            connection.close().then ->
                connection 
        .then (connection) ->
            test.must(connection.isValid 2).be false
            test.must(connection.isClosed()).be true
            connection
                
            