# nodejdbc
JDBC API wrapper for nodejs

A promise based JDBC wrapper for nodejs. Uses [bluebird](https://github.com/petkaantonov/bluebird) for promise integration and [node-java](https://github.com/joeferner/node-java) for calling java methods.

One of the good things about java is its standard JDBC API. JDBC API provides a standard way for the client applications to access a data source. It has interface methods that enable clients to perform DDL(Data Definition Language) or DML(Data Manipulation Language) operations on the target data source. JDBC is oriented towards relational database systems. 

nodejdbc tries to wrap JDBC API and provide a consistent way of accessing relational database systems. nodejdbc API also tries to extend JDBC API by introducing new methods

## Installation
At the moment nodejdbc api is only available for local builds.
You can clone the repository and execute `make build` under project folder.

* make sure `git` is installed
* `cd path/to/install/directory`
* `git clone https://github.com/blue-color/nodejdbc.git` 
* `cd nodejdbc && make build`
* check out the `lib` folder for library files


## Examples

To give a real insight about the usage of the API lets create sample datastores on [SQLite](https://www.sqlite.org/) database. Other JDBC-Compliant databases can also be chosen but do not forget to
convert DDL,DML statements to apropriate syntax.

You can follow the tests by preparing your environment like;

* under nodejdbc `mkdir demo && cd demo`
* `mkdir driver` # i preferer *lib* as name but it would be confusing
* make sure you have the [JDBC driver for SQLite](http://central.maven.org/maven2/org/xerial/sqlite-jdbc/3.8.11.2/sqlite-jdbc-3.8.11.2.jar) under the `driver` folder you have created on previous step 
* `touch test.coffee` # Assuming you have the [coffeescript](http://coffeescript.org/) installed
* install following packages [lodash](https://github.com/lodash/lodash) ,  [bluebird](https://github.com/petkaantonov/bluebird)
* use your text editor to copy and try the following examples

### Example *Outlaw* DB

Our example datasource contains data about the fomous outlaws of the **Wild West**

```coffeescript
_ = require 'lodash'
NodeJDBC = require './nodejdbc'
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
    'INSERT INTO HANDEDNESS 
        (ID, NAME, DESC) 
    VALUES 
        (10, "Left Handed",  "Uses left hand primarily")',
    
    'INSERT INTO HANDEDNESS 
        (ID, NAME, DESC) 
    VALUES 
        (20, "Right Handed", "Uses right hand primarily")',
    
    'INSERT INTO HANDEDNESS 
        (ID, NAME, DESC) 
    VALUES
        (30, "Mixed Handed", "Uses one or the other hand for different tasks")',
    
    'INSERT INTO HANDEDNESS 
        (ID, NAME, DESC) 
    VALUES 
        (40, "Ambidextrous", "Uses both hands equally.")'
]
```

Above code block contains the `require` statements for needed libraries and `SQL` statements for creating and loading our data stores. You have to modify these `SQL` statements if you connect to a database other than [SQLite](https://www.sqlite.org/).

Store `SQL` ddl and dml statements in corresponding arrays for easy way to acceess them.
```coffeescript
ddls    = [OUTLAW_DDL,GANG_DDL,HANDEDNESS_DDL]
dmls    = [OUTLAW_DML,GANG_DML,HANDEDNESS_DML]
tables  = ['OUTLAW','GANG','HANDEDNESS']  
```

Create a configuration `object` like the following to access to your database.

```coffeescript
config =
    libs : ['driver/sqlite-jdbc-3.8.11.2.jar']
    className: 'org.sqlite.JDBC'
    url: 'jdbc:sqlite:test.db'
``` 

This config object contains attribute;

* `libs:` SQLite JDBC driver path (relative to your working directory)
* `className:` Name of the class that will be loaded. (check out [this](http://stackoverflow.com/questions/8053095/what-is-the-actual-use-of-class-fornameoracle-jdbc-driver-oracledriver-while) discussion for more info.)
* `url:` jdbc url for acceessing our [SQLite](https://www.sqlite.org/) database

Again, these settings has to be modified for different databases.

Now lets define some methods that demostrates *CRUD* operations.

```coffeescript
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
```

`dropClean` method executes a `DROP TABLE` statement for each `*_DDL` table and returns a promise when all the
statements are fulfilled.

```coffeescript
###
    @Method deleteClean

    Deletes all the records from the tables in our Outlaw DB.
    We can also get and map the number of records deleted for each statement.
    
    @return returns a promise when all the DELETE statements are fulfilled.

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
```

`deleteClean` method executes a `DELETE FROM` statement for all tables in our DB. Returns a promise when all the statements are fulfilled. *In here we can also return the number of records modified for each statement.*

```coffeescript
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
```    
