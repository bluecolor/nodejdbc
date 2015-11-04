NodeJDBC = require './lib/nodejdbc'
_ = require 'lodash'
Promise = require 'bluebird'

OUTLAW_DDL = '
    CREATE TABLE OUTLAW
    (
        ID              INT,
        NAME            TEXT,
        AKA             TEXT,
        GANG            INT,
        BIRTH_DATE      DATE,
        DEATH_DATE      DATE,
        HANDEDNESS      INT
    )'

OUTLAW_DML = [
    'INSERT INTO OUTLAW 
        (ID, NAME, AKA, GANG, BIRTH_DATE, DEATH_DATE, HANDEDNESS)
     VALUES 
        (10, "Henry McCarty", "Billy the Kid", 10, "1859.September.17","1881.July.14",10)',

    'INSERT INTO OUTLAW 
        (ID, NAME, AKA, GANG, BIRTH_DATE, DEATH_DATE, HANDEDNESS)
     VALUES 
        (20, "Josiah Gordon Scurlock", "Doc", 10, "1849.January.11","1929.July.25",20)',
    
    'INSERT INTO OUTLAW 
        (ID, NAME, AKA, GANG, BIRTH_DATE, DEATH_DATE, HANDEDNESS)
     VALUES 
        (30, "Jesse Woodson James", "Jesse James", 20, "1847.September.05","1882.April.03",20)',
     
    'INSERT INTO OUTLAW
        (ID, NAME, AKA, GANG, BIRTH_DATE, DEATH_DATE, HANDEDNESS)
     VALUES  
        (40, "Alexander Franklin James", "Frank", 20, "1843.January.10","1915.February.18",20)',

    'INSERT INTO OUTLAW 
        (ID, NAME, AKA, GANG, BIRTH_DATE, DEATH_DATE, HANDEDNESS)
     VALUES
        (50,"Harry Alonzo Longabaugh","Sundance Kid",30, "1867.July.17","1908.November.07",30)',

    'INSERT INTO OUTLAW 
        (ID, NAME, AKA, GANG, BIRTH_DATE, DEATH_DATE, HANDEDNESS)
     VALUES
        (60,"Robert Leroy Parker","Butch Cassidy",30, "1867.July.17","1908.November.07",30)',

    'INSERT INTO OUTLAW 
        (ID, NAME, AKA, GANG, BIRTH_DATE, DEATH_DATE, HANDEDNESS)
     VALUES
        (70,"John Wesley Hardin","Little Arkansaw",40, "1853.May.26","1895.Agust.19",40)'    
]


GANG_DDL = '
    CREATE TABLE GANG
    (
        ID      INT,
        NAME    TEXT,
        LEADER  INT
    )'

GANG_DML = [
    'INSERT INTO GANG (ID,NAME, LEADER) VALUES (10,"Regulators",10)',
    'INSERT INTO GANG (ID,NAME, LEADER) VALUES (20,"James-Younger",30)'
    'INSERT INTO GANG (ID,NAME, LEADER) VALUES (30,"Wild Bunch",60)',
    'INSERT INTO GANG (ID,NAME, LEADER) VALUES (40,"Hardin Gang",70)'
]
    



HANDEDNESS_DDL = '
    CREATE TABLE HANDEDNESS
    (
        ID      INT,
        NAME    TEXT,
        DESC    TEXT
    )'

HANDEDNESS_DML = [
    'INSERT INTO HANDEDNESS (ID, NAME, DESC) VALUES (10, "Left Handed",  "Uses left hand primarily")',
    'INSERT INTO HANDEDNESS (ID, NAME, DESC) VALUES (20, "Right Handed", "Uses right hand primarily")',
    'INSERT INTO HANDEDNESS (ID, NAME, DESC) VALUES (30, "Mixed Handed", "Uses one or the other hand for different tasks")',
    'INSERT INTO HANDEDNESS (ID, NAME, DESC) VALUES (40, "Ambidextrous", "Uses both hands equally.")'
]



ddls    = [OUTLAW_DDL,GANG_DDL,HANDEDNESS_DDL]
dmls    = [OUTLAW_DML,GANG_DML,HANDEDNESS_DML]
tables  = ['OUTLAW','GANG','HANDEDNESS']  

config =
    libs : ['test/lib/sqlite-jdbc-3.8.11.2.jar']
    className: 'org.sqlite.JDBC'
    url: 'jdbc:sqlite:test.db'




###
    @Method dropClean

    Drops all _DDL tables. This method throws
    TableNotFound exception if the tables do not exist
    in database.

    @return returns a promise when all the tables are dropped 
    successfully  
###
dropClean = ->
    nodejdbc = new NodeJDBC(config)
    promises = tables.map (table) ->
        nodejdbc.createStatement().then (statement) ->
            sql = 'DROP TABLE ' + table
            console.log "Executing #{sql}"

            exception = (e) ->
                console.log "Failed to drop table #{table}"
                console.log e
            statement.executeUpdate(sql).catch(exception) 

    close = ->
        nodejdbc.getConnection().then (connection) -> 
            connection.close()

    Promise.all(promises).finally(close)        



###
    @Method deleteClean

    Deletes all the records from the tables in our Outlaw DB.
    
    @return returns a promise when all the DELETE statements are fulfilled.
    @todo We can also return number of records deleted for each statement.
###
deleteClean = ->
    nodejdbc = new NodeJDBC(config)
    promises = tables.map (table) ->
        nodejdbc.createStatement().then (statement) ->
            sql = 'DELETE FROM ' + table
            console.log "Executing #{sql}"

            exception = (e) ->
                console.log "Failed to delete table #{table}"
                console.log e
        
            statement.executeUpdate(sql).catch(exception)

    # if db is not in AutoCommit mode              
    commit = ->
        nodejdbc.getConnection().then (connection) ->
            connection.commit()
    close = ->
        nodejdbc.getConnection().then (connection) -> 
            connection.close()

    Promise.all(promises).finally(close)    


###
    @Method create

    executes CREATE ddl statements.
    
    @return returns a promise when all the CREATE statements are fulfilled.
###
create = ->
    nodejdbc = new NodeJDBC(config)
    promises = ddls.map (ddl) ->
            nodejdbc.createStatement().then (statement) ->
                console.log "Executing \n #{ddl}"

                exception = (e) ->
                    console.log e
                
                statement.executeUpdate(ddl).catch(exception) 

    close = ->
        nodejdbc.getConnection().then (connection) -> 
            connection.close()
            

    Promise.all(promises).then(close)    


###
    @Method load
    Inserts records to tables.
    @return returns a promise when all the CREATE statements are fulfilled.
###
load = ->
    nodejdbc = new NodeJDBC(config)
    promises = _.flatten(dmls).map (dml) ->
            nodejdbc.createStatement().then (statement) ->
                console.log "Executing \n #{dml}"

                exception = (e) ->
                    console.log e
                statement.executeUpdate(dml).catch(exception)

    # if db is not in AutoCommit mode            
    commit = ->
        nodejdbc.getConnection().then (connection) ->
            connection.commit()
    close = ->
        nodejdbc.getConnection().then (connection) -> 
            connection.close() 
                            
    Promise.all(promises).then(close)    
    
###
    @Method read
    executes a sample select statement and returns all the records as a json object

    @return [Object] result all records returned by the sample SQL query
###
read = ->
    sql = 'SELECT NAME,AKA FROM OUTLAW'
    nodejdbc = new NodeJDBC(config)
    promise = nodejdbc.createStatement().then (statement) ->
        statement.executeQuery(sql).then (rs)->
            result = []
            while rs.next()
                name = rs.getString('NAME')
                aka = rs.getString('AKA')
                result.push {} =
                    name: name
                    aka: aka
            result

            
    promise.then (result) ->
        nodejdbc.getConnection().then (connection) -> 
            connection.close()
            result                

# -------------------------------------------------------
# Drop -> Create -> Insert
# dropClean().then(create).then(load)
# -------------------------------------------------------

# -------------------------------------------------------
# Drop -> Create -> Insert -> Delete
# dropClean().then(create).then(load).then(deleteClean)
# -------------------------------------------------------


# -------------------------------------------------------
# Read
# read().then (result) ->
#     console.log result
# -------------------------------------------------------


config =
    libs : ['test/lib/ojdbc7.jar']
    className: 'oracle.jdbc.driver.OracleDriver'
    url: 'jdbc:oracle:thin:@//win:1521/orcl',
    username: 'demo',
    password: 'demo'

nodejdbc = new NodeJDBC(config)

nodejdbc.getConnection().then (connection) ->
    console.log 'conn is valid', connection.isValid(2)
    
    call = '{call demo.pkg_outlaw.prc_flip_coin(?,?,?)}'
    connection.prepareCall(call).then (statement) ->
        statement.setString 1, 'Heads'
        statement.registerOutParameter 2,'VARCHAR'
        statement.registerOutParameter 3,'VARCHAR'
        statement.executeUpdate().then ()->
            console.log "Result : #{statement.getString 2 }"
            console.log "Message: #{statement.getString 3 }"
            connection.close()
