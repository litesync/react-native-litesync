# react-native-octodb

OctoDB Native Plugin for React Native (Android and iOS)

This is a fork of [react-native-sqlite-storage](https://github.com/andpor/react-native-sqlite-storage)

Main differences:

* Links to the OctoDB native library
* Query parameters are not only strings

Features:

  1. iOS and Android supported via identical JavaScript API
  2. Android in pure Java and Native modes
  3. SQL transactions
  4. JavaScript interface via plain callbacks or Promises
  5. Pre-populated SQLite database import from application bundle and sandbox (for dbs that do not use OctoDB)

There are sample apps provided in test directory that can be used in with the AwesomeProject generated by React Native. All you have to do is to copy one of those files into your AwesomeProject replacing index.ios.js

The library has been tested with React 16.2 (and earlier) and XCode 7,8,9 - it works fine out of the box without any need for tweaks or code changes. For XCode 7,8 vs. XCode 6 the only difference is that sqlite ios library name suffix is tbd instead of dylib

# Installation

```
npm install --save react-native-octodb
```

Then follow the instructions for your platform to link `react-native-octodb` into your project

## iOS

### React Native 0.60 and above

Run:

```
cd ios && pod install && cd ..
```

### React Native 0.59 and below

Check the [instructions](instructions/INSTALL.md)


## Android

### React Native 0.60 and above

There are no extra steps

### React Native 0.59 and below

Check the [instructions](instructions/INSTALL.md)


## How to Use

Add this line to "require" the module on your `App.js`:

```
var SQLite = require('react-native-octodb')
```

Then add code to use the SQLite API in your `App.js` file. Here is some sample code:

```javascript
errorCB(err) {
  console.log("SQL Error: " + err);
},

successCB() {
  console.log("SQL executed fine");
},

openCB() {
  console.log("Database OPENED");
},

var db = SQLite.openDatabase("test.db", "1.0", "Test Database", 200000, openCB, errorCB);
db.transaction((tx) => {
  tx.executeSql('SELECT * FROM Employees a, Departments b WHERE a.department = b.department_id', [], (tx, results) => {
    console.log("Query completed");

    // Get rows with Web SQL Database spec compliance
    var len = results.rows.length;
    for (let i = 0; i < len; i++) {
      let row = results.rows.item(i);
      console.log(`Employee name: ${row.name}, Dept Name: ${row.deptName}`);
    }

    // Alternatively, you can use the non-standard raw method
    /*
    let rows = results.rows.raw(); // shallow copy of rows Array
    rows.map(row => console.log(`Employee name: ${row.name}, Dept Name: ${row.deptName}`));
    */
  });
});
```

For full working example see [test/index.ios.callback.js](test/index.ios.callback.js). Please
note that Promise based API is now supported as well with full examples in the working
React Native app under [test/index.ios.promise.js](test/index.ios.promise.js)


## Opening a database

Opening a database is slightly different between iOS and Android. Where as on Android the location of the database file is fixed, there are three choices of where the database file can be located on iOS. The 'location' parameter you provide to `openDatabase` call indicated where you would like the file to be created. This parameter is neglected on Android.

The default location on iOS is a no-sync location as mandated by Apple

To open a database in default no-sync location (affects iOS *only*):

```js
SQLite.openDatabase({name: 'my.db', location: 'default'}, successcb, errorcb);
```

To specify a different location (affects iOS *only*):

```js
SQLite.openDatabase({name: 'my.db', location: 'Library'}, successcb, errorcb);
```

where the `location` option may be set to one of the following choices:

- `default`: `Library/LocalDatabase` subdirectory - *NOT* visible to iTunes and *NOT* backed up by iCloud
- `Library`: `Library` subdirectory - backed up by iCloud, *NOT* visible to iTunes
- `Documents`: `Documents` subdirectory - visible to iTunes and backed up by iCloud
- `Shared`:  app group's shared container - *see next section*

The original webSql style `openDatabase` still works and the location will implicitly default to 'default' option:

```js
SQLite.openDatabase("myDatabase.db", "1.0", "Demo", -1);
```

## Opening a database in an App Group's Shared Container (iOS)

If you have an iOS app extension which needs to share access to the same DB instance as your main app, you must use the shared container of a registered app group.

Assuming you have already set up an app group and turned on the "App Groups" entitlement of both the main app and app extension, setting them to the same app group name, the following extra steps must be taken:

#### Step 1 - supply your app group name in all needed `Info.plist`s

In both `ios/MY_APP_NAME/Info.plist` and `ios/MY_APP_EXT_NAME/Info.plist` (along with any other app extensions you may have), you simply need to add the `AppGroupName` key to the main dictionary with your app group name as the string value:

```xml
<plist version="1.0">
<dict>
  <!-- ... -->
  <key>AppGroupName</key>
  <string>MY_APP_GROUP_NAME</string>
  <!-- ... -->
</dict>
</plist>
```

#### Step 2 - set shared database location

When calling `SQLite.openDatabase` in your React Native code, you need to set the `location` param to `'Shared'`:

```js
SQLite.openDatabase({name: 'my.db', location: 'Shared'}, successcb, errorcb);
```

## Importing a pre-populated database

This is **NOT** supported if the database uses OctoDB, because the database will be downloaded from the primary node(s) at the first run.

But as this library also supports normal SQLite databases, you can import an existing pre-populated database file into your application. 

On this case follow the instructions at the [original repo](https://github.com/andpor/react-native-sqlite-storage)


## Attaching another database

Sqlite3 offers the capability to attach another database to an existing database instance, i.e. for making cross database JOINs available.
This feature allows to SELECT and JOIN tables over multiple databases with only one statement and only one database connection.
To archieve this, you need to open both databases and to call the attach() method of the destination (or master) database to the other ones.

```js
let dbMaster, dbSecond;

dbSecond = SQLite.openDatabase({name: 'second'},
  (db) => {
    dbMaster = SQLite.openDatabase({name: 'master'},
      (db) => {
        dbMaster.attach( "second", "second", () => console.log("Database attached successfully"), () => console.log("ERROR"))
      },
      (err) => console.log("Error on opening database 'master'", err)
    );
  },
  (err) => console.log("Error on opening database 'second'", err)
);
```

The first argument of `attach()` is the name of the database, which is used in `SQLite.openDatabase()`. The second argument is the alias, that is used to query on tables of the attached database.

The following statement would select data from the master database and include the "second" database within a simple SELECT/JOIN statement:

```sql
SELECT * FROM user INNER JOIN second.subscriptions s ON s.user_id = user.id
```

To detach a database, just use the detach()-method:

```js
dbMaster.detach( 'second', successCallback, errorCallback );
```

There is also Promise support available for attach() and detach(), as shown in the example application under the
directory "examples".


### Promises

To enable promises, run:

```javascript
SQLite.enablePromise(true);
```


## Known Issues

1. React Native does not distinguish between integers and doubles. Only a Numeric type is available on the interface point. You can check [the original issue](https://github.com/facebook/react-native/issues/4141)

The current solution is to cast the bound value in the SQL statement as shown here:

```sql
INSERT INTO products (name,qty,price) VALUES (?, cast(? as integer), cast(? as real))
```
