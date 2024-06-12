import 'dart:async';
import 'package:dartbasics/services/crud/crud_exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

// a crud service that works with our database
class NotesService {

  static final NotesService _shared = NotesService._sharedInstance(); // private initializer of this class
  NotesService._sharedInstance(); 
  // creation of a singleton 
  factory NotesService() => _shared;

  // database from the sqlite library

  // variables with an _ are private variables and need a getter to access them
  Database? _db;
  List<DatabaseNote> _notes = []; // when the list changes we need to tell the UI that something is changed

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  // control a stream of a list of database notes
  // broadcast is used to detect changes multiple times
  final _notesStreamController = StreamController<List<DatabaseNote>>.broadcast();

  // getter for getting all the notes 
  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<void> _cacheNotes() async {
    final allNotes = await fetchAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _isDbOpen();
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
    await _isDbOpen();
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

  Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) async {
    await _isDbOpen();
    final db = _getDatabase();

    // make sure the note exists
    await fetchNote(id: note.id);



    final updatesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedColumn: 0,
    });

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote =  await fetchNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> fetchAllNotes() async {
    await _isDbOpen();
    final db = _getDatabase();
    final notes = await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  // fetches a single note based on id
  Future<DatabaseNote> fetchNote({required int id}) async {
    await _isDbOpen();
    final db = _getDatabase();
    final notes =
        await db.query(noteTable, limit: 1, where: 'id = ?', whereArgs: [id]);

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else { 
      final note =  DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note; 
    }
  }

  // delete all the notes
  Future<int> deleteAllNotes() async {
    await _isDbOpen();
    final db = _getDatabase();
    final numberOfDeletions =  await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }

  // function to delete notes
  Future<void> deleteNote({required int id}) async {
    await _isDbOpen();
    final db = _getDatabase();
    final deletedCount =
        await db.delete(noteTable, where: 'id = ?', whereArgs: [id]);

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      final count = _notes.length;
      _notes.removeWhere((note) => note.id == id);
      if (_notes.length != count) {
        _notesStreamController.add(_notes);
      }
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _isDbOpen();
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

    _notes.add(note);
    _notesStreamController.add(_notes);

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
    await _isDbOpen();
    final db = _getDatabase();
    final deletedCount = await db.delete(userTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);

    // throws an error if it is called on a non-existing email
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<void> _isDbOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty pass
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
      await _cacheNotes(); // read all the notes inside the list and the stream
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
