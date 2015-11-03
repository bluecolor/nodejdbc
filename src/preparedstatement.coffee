Promise = require 'bluebird'
ResultSet = require './resultset'

# PreparedStatement stores the precompiled SQL statements
# SQL statements with parameter binding can be precompiled and
# stored in PreparedStatement object. 

module.exports = 
class PreparedStatement

    # constructor method
    #
    # @param [Object] preparedStatement
    constructor: (preparedStatement) ->
        @preparedStatement = Promise.promisifyAll preparedStatement
    
    # Binds a string value to the parameter with the `index`
    #
    # @param [int] index order of the paratemer to be binded indexes starts at 1
    # @param [string] value string value of the parameter
    setString: (index,value) ->
        @preparedStatement.setStringSync(index,value)        

    # Binds a int value to the parameter with the `index`
    #
    # @param [int] index order of the paratemer to be binded indexes starts at 1
    # @param [int] value int value of the parameter
    setInt: (index,value) ->
        @preparedStatement.setIntSync(index,value)             

    # executes DDL(Data Definition Language) or DML(Data Manipulation Language) statements
    # if DDL statement is executed returns nothing else returns the number of 
    # manipulated(inserted,updated,deleted) records
    # 
    # @param [String] sql SQL statement to be executed
    #   @example 'SELECT COLUMN_A from MY_TABLE' 
    #   @example 'DROP TABLE MY_TABLE'  
    # 
    # @return [int] a promise that returns the result of the executed statement
    executeUpdate: ->
        @preparedStatement.executeUpdateAsync

    # Same as {Statement.executeUpdate} except it runs synchronously  and returns result directly 
    #
    # @return [int] 
    executeUpdateSync: ->
        @preparedStatement.executeUpdateAsync            

    # Execute given SQL statement and return a promise to the result set
    # 
    # @param SQL statment to be executed @example 'SELECT COLUMN_A from MY_TABLE'
    # 
    # @return [ResultSet] a promise that returns ResultSet       
    executeQuery: ->
        @preparedStatement.executeQueryAsync().then (resultSet) ->
            new ResultSet(resultSet)            

    # Closes the statement and frees the resources immediately.        
    close: ->
        @preparedStatement.closeAsync()