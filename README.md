# nodejdbc
JDBC API wrapper for nodejs

A promise based JDBC wrapper for nodejs. Uses [bluebird](https://github.com/petkaantonov/bluebird) for promise integration and [node-java](https://github.com/joeferner/node-java) for calling java methods.

One of the good things about java is its standard JDBC API. JDBC API provides a standard way for the client applications to access a data source. It has interface methods that enable clients to perform DDL(Data Definition Language) or DML(Data Manipulation Language) operations on the target data source. JDBC is oriented towards relational database systems. 

nodejdbc tries to wrap JDBC API and provide a consistent way of accessing relational database systems. nodejdbc API also tries to extend JDBC API by introducing new methods

## Installation

`npm install nodejdbc`

## Building

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

Our example datasource contains data about the famous outlaws of the **Wild West**

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

**DROP**
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

**DELETE**
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

**CREATE**
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

`create` method executes a `CREATE TABLE {TABLE_NAME} ( ... )` for the tables in our Outlaw DB. Returns a promise when all the statements are fulfilled.

**INSERT**
```coffeescript
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
```

`load` method executes a `INSERT` statements on our datastores and loads demo data. Returns promise when all the
statements are fulfilled.


**SELECT**
```coffeescript
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
```

`read` method executes a sample `SELECT` statement and returns a promise that resolves to an array
containing all the records returned by the given sample query. 

Now lets call these methods to execute some test stuff...

Call the following to execute drop , create and load operations in order.
```coffeescript
# Drop -> Create -> Insert
dropClean().then(create).then(load)
```
If it is the first time you execute this script or in other words; if the tables do not exist in db yet
you will see some exception messages on the screen, these messages can be ignored.

drop, clean, load, delete which means eventually we will get set of empty tables
```coffeescript
# Drop -> Create -> Insert -> Delete
dropClean().then(create).then(load).then(deleteClean)
```

Execute a sample `SELECT` statement. we can also modify our `read` method so that it accepts sql statements
and returns result like `read(sql)`

```coffeescript
# Read
read().then (result) ->
    console.log result
```

# Stored Procedure Call

It is time to call stored procedures. For that section 
you can use any database that allows you to write stored procedures. 
Make sure you have the appropriate JDBC driver and able to connect to your database and have the 
the necessary permissions granted to your user.

The following example shows how to call a procedure in oracle db. To start with; we can create
a package that will contain the procedures ,we will be calling using `NodeJDBC`  

Without too much detail, 
example oracle db configuration is like;

* jdbc url: jdbc:oracle:thin:@//win:1521/orcl 
* user name : demo
* password  : demo

The name of our package will be `PKG_OUTLAW`  

and the package spec. for `DEMO.PKG_OUTLAW` is;

```sql
create or replace package DEMO.PKG_OUTLAW
as
    procedure PRC_FLIP_COIN(guess in varchar2, result out varchar2, message out varchar2);
end;

```

package body of `DEMO.PKG_OUTLAW` is;

```sql
create or replace package body DEMO.PKG_OUTLAW
IS
    
    -- procedure PRC_FLIP_COIN
    -- Flips a coin and returns result and the message 
    -- 
    -- @param [in] [varchar2] guess your guess it can be either 'Heads' or 'Tails' (case insensitve)
    -- @param [out][varchar2] result result of the coin toss. can be 'Heads' or 'Tails'
    -- @param [out][varchar2] message text about game result
    procedure PRC_FLIP_COIN(guess in varchar2, result out varchar2, message out varchar2)
    is
        one_two int;  
        type result_set IS TABLE OF VARCHAR2(5);
        heads_tails result_set := result_set('HEADS','TAILS');
    begin
        
        if not ( upper(guess) member of heads_tails )
        then  
            result  := 'Upright';
            message := 'Please pass only "HEADS" or "TAILS" as input';
            return;
        end if;
        
        one_two := round(dbms_random.value) + 1;
        result  := initcap(heads_tails(one_two));
        message := case upper(result) when upper(guess) then 'Nice Shot! You Win' else 'Sorry! You Lost' end;
        
    end;

end;

```

This is a simple coin toss example.The procedure `PRC_FLIP_COIN` takes three arguments 

* `guess in varchar2`    input parameter guess, which can be either 'Heads' or 'Tails' (case insensitve)
* `result out varchar2`  output parameter result, can be 'Heads' or 'Tails'
* `message out varchar2` output parameter message, text about game result

Afer you have compiled the package successfuly. You can test the `PRC_FLIP_COIN` in `plsq` with
```sql
declare 
    result  varchar2(100);
    message varchar2(100);
begin
  DEMO.PKG_OUTLAW.PRC_FLIP_COIN('Heads',result,message);
  
  dbms_output.put_line('Result : ' || result);
  dbms_output.put_line('Message: ' || message);
  
end;
``` 

Now, we can write the above script with `NodeJDBC` like;

```coffeescript
config =
    libs : ['test/lib/ojdbc7.jar']
    className: 'oracle.jdbc.driver.OracleDriver'
    url: 'jdbc:oracle:thin:@//win:1521/orcl',
    username: 'demo',
    password: 'demo'

nodejdbc = new NodeJDBC(config)

nodejdbc.getConnection().then (connection) ->    
    call = '{call demo.pkg_outlaw.prc_flip_coin(?,?,?)}'
    connection.prepareCall(call).then (statement) ->
        statement.setString 1, 'Heads'
        statement.registerOutParameter 2,'VARCHAR'
        statement.registerOutParameter 3,'VARCHAR'
        statement.executeUpdate().then ()->
            console.log "Result : #{statement.getString 2 }"
            console.log "Message: #{statement.getString 3 }"
            connection.close()
```  

If you are lucky, this should print

```bash
Result : Heads
Message: Nice Shot! You Win 
```







These examples are also available in the repository on a single file [test.coffee](https://github.com/blue-color/nodejdbc/blob/master/test.coffee)

# API Docs
API docs are located under `doc` folder. Thanks to [codo](https://github.com/coffeedoc/codo)
to generate API docs just run;
```bash
make docs
```

# Tests
Unit tests are located under test folder. You'll need [mocha](https://github.com/mochajs/mocha) to execute  unit tests. Run the tests with
```bash
make build
make test
```
Make sure you have the followind `test/lib/sqlite-jdbc-3.8.11.2.jar` .


# Getting Help
Use [issues](https://github.com/blue-color/nodejdbc/issues) with appropriate labels for;
* Bugs
* Feature requests
* Questions

# License

Copyright (c) 2014-2015, BlueColor

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.




