import 'package:dartbasics/services/crud/crud_exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

// a crud service that works with our database
class NotesService {
  // database from the sqlite library
  Database? _db; // private variable

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabase();
    // checking if the user with the same email even exists
    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);

    // checks if the list is not empty first, we need to make sure that the user does not exist in the database
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final uid = await db.insert(userTable, {emailColumn: email.toLowerCase()});

    return DatabaseUser(id: uid, email: email);
  }

  // get database or throw and exception
  Database _getDatabase() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  // deletes the user from the table
  Future<void> deleteUser({required String email}) async {
    final db = _getDatabase();
    final deletedCount = await db.delete(userTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);

    // throws an error if it is called on a non-existing email
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  // we need an async function that opens our database
  // after it has opened the database its going to store it somewhere in our notes service
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      // gets the directory, joins the path of our database and the the directory, opens the database, then assigns it to our local database
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, database);
      final db =
          await openDatabase(dbPath); // creates the db if it doesn't exist
      _db = db;

      // creation of the tables
      await db.execute(createUserTable);
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  // closing the database
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }
}

// Database Class for users
@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() =>
      'Person, ID = $id, email = $email'; // function overloading for toString function
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;
  // operator overloading for == operator, used for comparing classes of the same type
  @override
  int get hashCode => id
      .hashCode; // the id converts into a hash node so that it can store in maps
}

// Database Class for Notes
class DatabaseNote {
  final int id;
  final int uid;
  final String text;
  final bool isSynced; // synced with cloud database

  const DatabaseNote(
      {required this.id,
      required this.uid,
      required this.text,
      required this.isSynced});

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        uid = map[uidColumn] as int,
        text = map[textColumn] as String,
        isSynced = (map[isSyncedColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID = $id, UserID = $uid, isSyncedWithCloud = $isSynced, Text = $text';
  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;
  @override
  int get hashCode => id.hashCode;
}

const database = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const uidColumn = 'user_id';
const textColumn = 'text';
const isSyncedColumn = 'is_synced';

// creates the user table too if the db didn't exist initially
const createUserTable = '''CREATE TABLE "User" IF NOT EXISTS (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);''';

// creates the note table too if the db didn't exist initially
const createNoteTable = '''CREATE TABLE "Note" IF NOT EXISTS (
	"id"	INTEGER NOT NULL,
	"uid"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_synced"	INTEGER NOT NULL DEFAULT 0,
	FOREIGN KEY("uid") REFERENCES "User"("id"),
	PRIMARY KEY("id" AUTOINCREMENT)
);''';