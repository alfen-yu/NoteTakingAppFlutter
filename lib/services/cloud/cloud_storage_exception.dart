class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotCreateNoteException extends CloudStorageException {}
class CouldNotRetrieveNotesException extends CloudStorageException {}
class CouldNotUpdateNoteException extends CloudStorageException {}
class CouldNotDeleteNoteException extends CloudStorageException {}