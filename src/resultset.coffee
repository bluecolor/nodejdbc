Promise = require 'bluebird'

# Data sets generated by executing SQL statements
# Result sets contains a cursor which points to the current position
# on the resulting data record. Initially this cursor is positioned
# before the first record of the data. Calling the {ResultSet#next} moves the
# cursor one position forward 
module.exports = 
class ResultSet
    # Constructor method
    # 
    # @param [Object] resultSet
    constructor: ( resultSet ) ->
        @resultSet = Promise.promisifyAll resultSet
    
    # Moves the cursor ,that points to resutset data record, one position forward.
    # this method executed synchronously 
    next: ->
        @resultSet.nextSync()    

    # Gets the given column's value as String    
    getString: (column) ->
        @resultSet.getStringSync(column)
    
    # Gets the given column's value as int
    getInt: (column) ->
        @resultSet.getStringSync(column)           
