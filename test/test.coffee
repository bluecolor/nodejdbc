test = require 'unit.js'
ESDBC = require '../lib/esdbc'

config = 
    libs : ['lib/sqlite-jdbc-3.8.11.2.jar']
    className: 'org.sqlite.JDBC'
    url: 'jdbc:sqlite:test.db'

describe 'ESDBC', ->
    it 'Connection', ->
        esdbc = new ESDBC config
        test.promise
        .given ->
            esdbc.getConnection()
        .then (connection) ->
            test.must(connection.isValid 2).be true
            test.must(connection.isClosed()).be false
            connection.close().then ->
                connection 
        .then (connection) ->
            test.must(connection.isValid 2).be false
            test.must(connection.isClosed()).be true
            connection
                
            