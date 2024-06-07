import 'dart:async';

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

  // get user
  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabase();

    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results
          .first); // first row that was read from the user tables after checking the email address
    }
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    final db = _getDatabase();
    await fetchNote(id: note.id);

    final updatesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedColumn: 0,
    });

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await fetchNote(id: note.id);
    }
  }

  Future<Iterable<DatabaseNote>> fetchAllNotes() async {
    final db = _getDatabase();
    final notes = await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  // fetches a single notes based on id
  Future<DatabaseNote> fetchNote({required int id}) async {
    final db = _getDatabase();
    final notes =
        await db.query(noteTable, limit: 1, where: 'id = ?', whereArgs: [id]);

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      return DatabaseNote.fromRow(notes.first);
    }
  }

  // delete all the notes
  Future<int> deleteAllNotes() async {
    final db = _getDatabase();
    return await db.delete(noteTable);
  }

  // function to delete notes
  Future<void> deleteNote({required int id}) async {
    final db = _getDatabase();
    final deletedCount =
        await db.delete(noteTable, where: 'id = ?', whereArgs: [id]);

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabase();
    final dbUser = await getUser(email: owner.email);

    // make sure owner exists in the database with the correct id
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';
    // create the note
    final noteID = await db.insert(noteTable, {
      uidColumn: owner.id,
      textColumn: text,
      isSyncedColumn: 1,
    });

    final note =
        DatabaseNote(id: noteID, uid: owner.id, text: text, isSynced: true);

    return note;
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
