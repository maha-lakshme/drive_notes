
import 'package:dio/dio.dart';
import 'package:drive_notes/auth/auth_service.dart';
import 'package:drive_notes/notes/services/note_repository.dart';
import 'package:drive_notes/notes/services/notes_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref){return Dio();});

final authProvider = Provider<AuthService>((ref) {
  return AuthService();
},);

final notesServiceProvider = Provider<NotesService>((ref) {
  final dio = ref.watch(dioProvider);
  return NotesService(dio);
},);

final notesRepositoryProvider = Provider<NoteRepository>((ref) {
  final notesService = ref.watch(notesServiceProvider);
  final authService = ref.watch(authProvider);
  return NoteRepository(notesService: notesService, authService: authService);
},);