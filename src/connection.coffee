Statement = require './statement' 
Promise = require 'bluebird'


# Connection object to a datasource. @see {ESDBC#config}
# Queries and methods are executed using a connection object.
module.exports = 
class Connection
    
    # constructor method
    # 
    # @param [Object] connection java connection insterface
    constructor: (connection) ->
        @connection = Promise.promisifyAll connection
    
    # Set the auto-commit mode of the connection
    # 
    # @param [boolean] autoCommit true to set auto-commit mode on 
    setAutoCommit: (autoCommit) ->
        @connection.setAutoCommitSync autoCommit

    # Create a statement for executing SQL queries.
    # SQL statements with no parameters can be executed by using Statement object.
    #   @example statement.executeQuery('SELECT COL_NAME FROM MY_TABLE')   
    # If the sql statement is to be executed many times or with binding parameters
    # {Connection#prepareStatement} should be used instead
    # 
    # @return [Statement] a promise that returns a statement Statement object that will create result set. @see {ResultSet}    
    createStatement: ->
        @connection.createStatementAsync().then (statement)->
            return new Statement(statement)            

    # Creates a PreparedStatement for executing SQL statements with or without parameter binding.
    # This is designed for precompilation optimization. If the driver supports precompilation option
    # then given sql statement will be passed to datasource for precompilation once when this method is called.
    # If precompilation is not supported then the SQL statement will be passed when the PreparedStatement object
    # is executed.
    #
    # @return [PreparedStatement] a promise that returs a PreparedStatement object           
    prepareStatement: (sql) ->
         @connection.prepareStatementAsync(sql).then (preparedStatement)->
            return new PreparedStatement(preparedStatement)            

    # Persists the changes to the datasource from the last commit.
    # This method throws exception if the auto-commit mode is on.        
    commit: ->
        @connection.commitAsync()        

    # Ignore all the changes since last commit and release locks on the given datastore.
    # This method throws exception if the auto-commit mode is on.    
    rollback: ->
        @connection.rollbackAsync()        

    # Closes the connection to the given datasource.     
    close: ->
        @connection.closeAsync()


    # Checks if the connection is closed
    #
    # @return [boolean] true if the connection is closed    
    isClosed: ->
        @connection.isClosedSync()

    # Checks is connection is still valid
    #
    # @param [int] timeout wait for number of (secods) to validate connection state
    isValid: (timeout) ->
        @connection.isValidSync(timeout)        
                 