Promise = require 'bluebird'
PreparedStatement = require './preparedstatement'

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

