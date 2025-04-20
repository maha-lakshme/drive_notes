import 'package:drive_notes/auth/auth_service.dart';
import 'package:drive_notes/notes/services/notes_service.dart';

class NoteRepository {
 final NotesService notesService;
final AuthService authService;

 NoteRepository({required this.notesService, required this.authService});

 Future<String> getFolderId() async{
  final accessToken = await authService.getAccessToken();
   if (accessToken == null) {
      throw Exception("User is not authenticated (access token is null).");
    }
 return await notesService.getOrCreateDriveNotesFolder(accessToken);
}

Future<List<Map <String,dynamic>>> fetchNotes() async{
 final folderId = await getFolderId();
 final accessToken = await authService.getAccessToken();
   if (accessToken == null) {
      throw Exception("User is not authenticated (access token is null).");
    }
 return await notesService.listNoteFiles(folderId, accessToken);
}
Future<void> addNote({required String title, required String content}) async{
  final folderId= await getFolderId();
   final accessToken = await authService.getAccessToken();
   if (accessToken == null) {
      throw Exception("User is not authenticated (access token is null).");
    }
  await notesService.createNoteFile(folderId: folderId, noteTitle: title, noteContent: content, accessToken: accessToken);
}
Future<void> editNote({
  required String fileId,
  required String newContent,
  required String newTitle,
}) async {
  final accessToken = await authService.getAccessToken();
  if (accessToken == null) {
    throw Exception("User is not authenticated (access token is null).");
  }
  await notesService.updateNoteFile(
    fileId: fileId,
    newTitle: newTitle,
    newContent: newContent,
    accessToken: accessToken,
  );
}


  Future<void> deleteNote({ required String fileId }) async {
  final accessToken = await authService.getAccessToken();
  if (accessToken == null) {
    throw Exception("User is not authenticated (access token is null).");
  }
  await notesService.deleteNoteFile(
    fileId: fileId,
    accessToken: accessToken,
  );


}
 Future<String> downloadNoteContent(String fileId) async {
  final accessToken = await authService.getAccessToken();
  if (accessToken == null) {
    throw Exception("User is not authenticated (access token is null).");
  }
  return await notesService.downloadNoteContent(fileId, accessToken);
}
  
  }


