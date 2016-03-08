Promise = require 'bluebird'
ResultSet = require './resultset'
java = Promise.promisifyAll (require 'java')

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


    # Binds a Timestamp value to the parameter with the `index`
    #
    # @param [int] index order of the paratemer to be binded indexes starts at 1
    # @param [date] date value of the parameter
    setTimestamp: (index,value) ->
        # longValue = java.callStaticMethodSync('java.lang.Long', 'valueOf', String(value.getTime()));
        # timestamp = java.newInstanceSync("java.sql.Timestamp", value.getYear(), value.getMonth(), value.getDay());
        timestamp = java.callStaticMethodSync("java.sql.Timestamp", 'valueOf', value);
        @preparedStatement.setTimestampSync(index,timestamp)


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
        @preparedStatement.executeUpdateAsync()


    # Same as {Statement.executeUpdate} except it runs synchronously  and returns result directly
    #
    # @return [int]
    executeUpdateSync: ->
        @preparedStatement.executeUpdateSync()


    # Adds a set of parameters to this PreparedStatement object's batch of commands.
    addBatch: ->
        @preparedStatement.addBatchAsync()


    # Adds a set of parameters to this PreparedStatement object's batch of commands.
    addBatchSync: ->
        @preparedStatement.addBatchSync()


    # Submits a batch of commands to the database for execution and if all commands execute successfully, returns an array of update counts. The int elements of the array that is returned are ordered to correspond to the commands in the batch, which are ordered according to the order in which they were added to the batch. The elements in the array returned by the method executeBatch may be one of the following:
    # A number greater than or equal to zero -- indicates that the command was processed successfully and is an update count giving the number of rows in the database that were affected by the command's execution
    # A value of SUCCESS_NO_INFO -- indicates that the command was processed successfully but that the number of rows affected is unknown
    # If one of the commands in a batch update fails to execute properly, this method throws a BatchUpdateException, and a JDBC driver may or may not continue to process the remaining commands in the batch. However, the driver's behavior must be consistent with a particular DBMS, either always continuing to process commands or never continuing to process commands. If the driver continues processing after a failure, the array returned by the method BatchUpdateException.getUpdateCounts will contain as many elements as there are commands in the batch, and at least one of the elements will be the following:
    #
    # A value of EXECUTE_FAILED -- indicates that the command failed to execute successfully and occurs only if a driver continues to process commands after a command fails
    # The possible implementations and return values have been modified in the Java 2 SDK, Standard Edition, version 1.3 to accommodate the option of continuing to proccess commands in a batch update after a BatchUpdateException obejct has been thrown.
    #
    # @return int[] an array of update counts containing one element for each command
    # in the batch. The elements of the array are ordered according to the order in which commands were added to the batch.
    executeBatch: ->
        @preparedStatement.executeBatchAsync()


    # (see the jdbc doc)[https://docs.oracle.com/javase/7/docs/api/java/sql/Statement.html#executeBatch()]
    executeBatchSync: ->
        @preparedStatement.executeBatchSync()


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