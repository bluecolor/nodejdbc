Promise = require 'bluebird'


# Connection object to a datasource. @see {NodeJDBC#config}
# Queries and methods are executed using a connection object.
module.exports = 
class CallableStatement

    # constructor method
    # 
    # @param [Object] callableStatement java callableStatement interface object
    constructor: (callableStatement) ->
        @callableStatement = Promise.promisifyAll callableStatement

    # executes the call statement   
    executeUpdate: ->
        @callableStatement.executeUpdateAsync()        