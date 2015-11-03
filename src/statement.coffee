Promise = require 'bluebird'
ResultSet = require './resultset'

# Statement object that executes SQL statements 
# A {ResultSet} object is returned after successful execution of the SQL statement
# The same statment object can not create different result sets asynchronously.
# Each execution of the statement object implicitly closes the previous result set
# and created a new result set  
module.exports = 
class Statement
    
    # constructor method
    #
    # @param [Object] statement
    constructor: (statement) ->
        @statement = Promise.promisifyAll statement
    
    # executes DDL(Data Definition Language) or DML(Data Manipulation Language) statements
    # if DDL statement is executed returns nothing else returns the number of 
    # manipulated(inserted,updated,deleted) records
    # 
    # @param [String] sql SQL statement to be executed
    #   @example 'SELECT COLUMN_A from MY_TABLE' 
    #   @example 'DROP TABLE MY_TABLE'  
    # 
    # @return [int] a promise that returns the result of the executed statement
    executeUpdate: (sql) ->
        @statement.executeUpdateAsync sql

    # Same as {Statement.executeUpdate} except it runs synchronously  and returns result directly 
    #
    # @return [int] 
    executeUpdateSync: (sql) ->
        @statement.executeUpdateAsync sql            

    # Execute given SQL statement and return a promise to the result set
    # 
    # @param SQL statment to be executed @example 'SELECT COLUMN_A from MY_TABLE'
    # 
    # @return [ResultSet] a promise that returns ResultSet    
    executeQuery: (sql) ->
        @statement.executeQueryAsync(sql).then (resultSet) ->
            new ResultSet(resultSet)            

    # Closes the statement and frees the resources immediately.        
    close: ->
        @statement.closeAsync()
