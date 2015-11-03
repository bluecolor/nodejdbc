Promise = require 'bluebird'
PreparedStatement = require './preparedstatement'
java = require 'java'

# Connection object to a datasource. @see {NodeJDBC#config}
# Queries and methods are executed using a connection object.
module.exports = 
class CallableStatement extends PreparedStatement

    # constructor method
    # 
    # @param [Object] callableStatement java callableStatement interface object
    constructor: (callableStatement) ->
        super callableStatement
        @callableStatement = Promise.promisifyAll callableStatement


    # Registers the OUT parameter in ordinal position parameterIndex to the JDBC type sqlType.
    # 
    # @param [int] index parameter position. first parameter is 1, second 2 ...
    # @param [String] sql type identifier @see [java.sql.Types](http://docs.oracle.com/javase/7/docs/api/java/sql/Types.html)
    #   @example for java.sql.Types.INTEGER just pass 'INTEGER'
    #   @example for java.sql.Types.CHAR just pass 'CHAR'
    #   The above examples apply to all types in java.sql.Type. 
    #   In short ; just pass the string representation of the type name 
    registerOutParameter: (index, type) ->
        @callableStatement.registerOutParameter index, @getType(type)


    # @sync
    # 
    # Retrieves the value of the designated JDBC CHAR, 
    # VARCHAR, or LONGVARCHAR parameter as a string
    #
    # @param index parameter position. first parameter is 1, second 2 ... 
    # @return [string] get parameter value as string      
    getString: (index) ->
        @callableStatement.getStringSync index    


    # @sync
    # 
    # Retrieves the value of the designated JDBC CHAR, 
    # VARCHAR, or LONGVARCHAR parameter as an integer
    # 
    # @param index parameter position. first parameter is 1, second 2 ... 
    # @return [int] get parameter value as integer      
    getInt: (index) ->
        @callableStatement.getIntSync index    

    
    # returns int representation of the type
    # 
    # @return [int] integer representation of the java.sql.Types.{TYPE} constant
    getType: (type) ->
        java.getStaticFieldValue "java.sql.Types", type        