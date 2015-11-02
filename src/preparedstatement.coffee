Promise = require 'bluebird'
ResultSet = require './resultset'

module.exports = 
class PreparedStatement

    constructor: (preparedStatement) ->
        @preparedStatement = Promise.promisifyAll preparedStatement
    
    setString: (index,value) ->
        @preparedStatement.setStringSync(index,value)        

    setInt: (index,value) ->
        @preparedStatement.setIntSync(index,value)             

    executeUpdate: ->
        @preparedStatement.executeUpdateAsync

    executeUpdateSync: ->
        @preparedStatement.executeUpdateAsync            


    executeQuery: ->
        @preparedStatement.executeQueryAsync().then (resultSet) ->
            new ResultSet(resultSet)            

    close: ->
        @preparedStatement.closeAsync()