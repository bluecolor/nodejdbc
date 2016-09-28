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


  # Adds a set of parameters to this PreparedStatement object's batch of commands.
  addBatch: (sql)->
    @statement.addBatchAsync(sql)


  # Adds a set of parameters to this PreparedStatement object's batch of commands.
  addBatchSync: (sql)->
    @statement.addBatchSync(sql)

  clearBatchSync: () ->
    @statement.clearBatchSync()    
  
  clearBatch: () ->
    @statement.clearBatchAsync()  


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
    @statement.executeBatchAsync()


  # (see the jdbc doc)[https://docs.oracle.com/javase/7/docs/api/java/sql/Statement.html#executeBatch()]
  executeBatchSync: ->
    @statement.executeBatchSync()


  # sets the query time out parameter
  # this method is synchronous
  setQueryTimeout: (seconds)->
    @statement.setQueryTimeoutSync seconds



  # Closes the statement and frees the resources immediately.
  close: ->
    @statement.closeAsync()
