import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drive_notes/common/utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
class NotesService {
  final Dio _dio;
  final _flutterSecureStorage = const FlutterSecureStorage();
  NotesService(this._dio);
  String? _cachedFolderId;

  Future<String> getOrCreateDriveNotesFolder(String accessToken) async {
  print("----getOrCreateDriveNotesFolder called-----");

  // In-memory cache
  if (_cachedFolderId != null) {
    print("Using in-memory cached folder id: $_cachedFolderId");
    return _cachedFolderId!;
  }

  // Secure storage
  final storedFolderId = await _flutterSecureStorage.read(key: 'driveNotesFolderId');
  if (storedFolderId != null) {
    print("Found stored folder ID: $storedFolderId");

    // Check if folder still exists
    final checkResponse = await _dio.get(
      '$driveApiUrl/files/$storedFolderId',
      queryParameters: {
        'fields': 'id, name, trashed',
      },
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    if (checkResponse.statusCode == 200 && checkResponse.data['trashed'] != true) {
      _cachedFolderId = storedFolderId;
      print("Stored folder ID is valid and not trashed.");
      return storedFolderId;
    } else {
      print("Stored folder ID is invalid or trashed. Ignoring.");
    }
  }

  // Search by name
  const query =
      "name='DriveNotes' and mimeType='application/vnd.google-apps.folder' and trashed=false";
  final response = await _dio.get(
    '$driveApiUrl/files',
    queryParameters: {
      'q': query,
      'spaces': 'drive',
      'fields': 'files(id, name, createdTime)',
      'orderBy': 'createdTime',
    },
    options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
  );

  final files = response.data['files'] as List<dynamic>;
  print("Found folders: $files");

  if (files.isNotEmpty) {
    final folderId = files.first['id'] as String;
    _cachedFolderId = folderId;
    await _flutterSecureStorage.write(key: 'driveNotesFolderId', value: folderId);
    print("Reusing existing folder ID: $folderId");
    return folderId;
  }

  // Create new folder if none found
  return await createDriveNotesFolder(accessToken);
}

  Future<String> createDriveNotesFolder(String accessToken) async {
    print("----Create Drive Notes Folder called-----");

    final data = {
      'name': 'DriveNotes',
      'mimeType': 'application/vnd.google-apps.folder',
    };
    final response = await _dio.post(
      '$driveApiUrl/files',
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ),
    );

    print(' Response from Create Drive---' + response.toString());
    final newFolderId = response.data['id'] as String;
    await _flutterSecureStorage.write(
        key: 'driveNotesFolderId', value: newFolderId);
    return newFolderId;
  }

 Future<List<Map<String, dynamic>>> listNoteFiles(
    String folderId, String accessToken) async {
  print("----listNoteFiles called-----");

  final query = "'$folderId' in parents and mimeType = 'text/plain' and trashed = false";
  final response = await _dio.get(
    '$driveApiUrl/files',
    queryParameters: {
      'q': query,
      'fields': 'files(id, name, modifiedTime)',
    },
    options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
  );

  final files = response.data['files'];
  print("List Note Files Response: $files");

  if (files == null || files.isEmpty) {
    return [];
  }

  return List<Map<String, dynamic>>.from(files);
}


  Future<void> createNoteFile({
    required String folderId,
    required String noteTitle,
    required String noteContent,
    required String accessToken,
  }) async {
    print("----createNoteFile called-----");

    final boundary = "----DriveNotesBoundary";
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'multipart/related; boundary=$boundary',
    };

    final metadata =
        '{"name": "$noteTitle.txt", "mimeType": "text/plain", "parents": ["$folderId"]}';
    final body = '--$boundary\r\n'
        'Content-Type: application/json; charset=UTF-8\r\n\r\n'
        '$metadata\r\n'
        '--$boundary\r\n'
        'Content-Type: text/plain\r\n\r\n'
        '$noteContent\r\n'
        '--$boundary--';

    await _dio.post(
      '$driveApiUploadUrl?uploadType=multipart',
      data: body,
      options: Options(headers: headers),
    );
  }

  // Future<void> updateNoteFile({
  //   required String fileId,
  //   required String newContent,
  //   required String accessToken,
  // }) async {
  //   print("----updateNoteFile called-----");

  //   await _dio.patch(
  //     '$driveApiUploadUrl/$fileId?uploadType=media',
  //     data: newContent,
  //     options: Options(
  //       headers: {
  //         'Authorization': 'Bearer $accessToken',
  //         'Content-Type': 'text/plain',
  //       },
  //     ),
  //   );
  // }
 Future<void> updateNoteFile({
  required String fileId,
  required String newTitle,
  required String newContent,
  required String accessToken,
}) async {
  // Prepare updated metadata.
  final metadata = {
    'name': newTitle,
  };

  // CRLF for line breaks.
  const String CRLF = "\r\n";
  // Define a boundary.
  const String boundary = "foo_bar_baz";

  final multipartBody =
      "--$boundary$CRLF" +
      "Content-Type: application/json; charset=UTF-8$CRLF$CRLF" +
      jsonEncode(metadata) + CRLF +
      "--$boundary$CRLF" +
      "Content-Type: text/plain; charset=UTF-8$CRLF$CRLF" +
      newContent + CRLF +
      "--$boundary--";

  final String url = '$driveUploadUrl/files/$fileId?uploadType=multipart';

  final response = await _dio.patch(
    url,
    data: multipartBody,
    options: Options(
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/related; boundary=$boundary', 
      },
      responseType: ResponseType.json,
    ),
  );
  print("Update note file response: ${response.data}");
}
  Future<void> deleteNoteFile({
  required String fileId,
  required String accessToken,
}) async {
  print("----deleteNoteFile called for fileId: $fileId-----");
  await _dio.delete(
    '$driveApiUrl/files/$fileId',
    options: Options(
      headers: {'Authorization': 'Bearer $accessToken'},
    ),
  );
  print("File deleted successfully.");
}

Future<String> downloadNoteContent(String fileId, String accessToken) async {
  final response = await _dio.get(
    '$driveApiUrl/files/$fileId',
    queryParameters: {
      'alt': 'media', // Request file content.
    },
    options: Options(
      headers: {'Authorization': 'Bearer $accessToken'},
      responseType: ResponseType.plain, // Treat response as plain text.
    ),
  );
  return response.data as String;
}

}
