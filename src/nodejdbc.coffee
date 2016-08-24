
Promise = require 'bluebird'
Connection = require './connection'
_ = require 'lodash'
# Promisify java library
java = Promise.promisifyAll (require 'java')


# Main class for connection.
# Basically initializes configuration and supplies connection object
module.exports =
class NodeJDBC

    # Connection object. Initilized once for each new NodeJDBC
    # @private
    @_connection = undefined

    # constructor method
    # initializes classpath and registers jdbc driver.
    # Also validates the given configuration object
    #
    # @param [Object] config configuration parameters for NodeJDBC and java instance
    # @option options [Array] libs list of libraries that will be added to classpath.
    #   driver jars are specified here. If you want to extend NodeJDBC and use other java
    #   libraries you can also suply additional jars here.
    #   @example ['lib/sqlite-jdbc-3.8.11.2.jar','commons-collections-3.2.1.jar']
    # @option options [String] className driver class name @example 'org.sqlite.JDBC'
    # @option options [String] url jdbc url @example 'jdbc:sqlite:test.db'
    constructor: (@config) ->
        @validateConfig()
        _.each @config.libs, (lib) ->
            if java.classpath.indexOf(lib) < 0
                java.classpath.push.apply java.classpath, [lib]
        @registerDriver()

    # Each time creates new connection to the given datasource!
    # Use {NodeJDBC#getConnection} for creating and reusing connections.
    #
    # @return [Connection] A promise that returns a new Connection object
    newConnection: ->
        conn = java.callStaticMethodAsync 'java.sql.DriverManager', 'getConnection', @config.url, @config.username, @config.password
        conn.then (connection) ->
            new Connection(connection)

    # Create or return existing connection object if it is created before.
    # @see {NodeJDBC.newConnection}
    #
    # @return [Connection] A promise that returns a Connection object
    getConnection: (createIfClosed=no)->

        con = @_connection
        me  = this

        if ! @_connection
          return @_connection = @newConnection()
        else
          return @_connection = @_connection.then (c)->
            if c.isClosed() and createIfClosed==yes
              return  me.newConnection()
            else
              return me._connection

    # Each time creates a statement from given configuration.
    # This is rather a shorthand method. Instead directly create statement in your code
    # unless you want a new statement each time.
    #
    # @return [Statement] A promise that returns a Statement object
    createStatement: ->
        @getConnection().then (connection)->
            connection.createStatement()

    # initialize driver class name
    # in java this is : Class.forName('jdbc.class.name')
    classForName: ->
        java.newInstanceSync @config.className

    # registers jdbc driver
    registerDriver: ->
        driver = @classForName()
        java.callStaticMethodSync 'java.sql.DriverManager','registerDriver',driver

    # validates given configuration object
    # @see {NodeJDBC#constructor constructor}
    validateConfig: ->
        if ! @config
            throw 'Missing configuration ...'
        else if ! @config.libs or _.isEmpty @config.libs
            throw 'Missing libraries ...'

        if _.isEmpty @config.className
            throw 'Missing driver class'

    # print configuration object
    printConfig: ->
        console.log @config
