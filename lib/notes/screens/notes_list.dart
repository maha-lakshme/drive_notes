import 'package:dio/dio.dart';
import 'package:drive_notes/auth/auth_service.dart';
import 'package:drive_notes/notes/models/note_model.dart';
import 'package:drive_notes/notes/providers/notes_providers.dart';
import 'package:drive_notes/notes/screens/create_note_screen.dart';
import 'package:drive_notes/notes/screens/edit_note.dart';
import 'package:drive_notes/notes/services/note_repository.dart';
import 'package:drive_notes/notes/services/notes_service.dart';
import 'package:drive_notes/themes/theme_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final notesListProvider = FutureProvider<List<Note>>((ref) async {
  final notesRepo = ref.watch(notesRepositoryProvider);
  final notes = await notesRepo.fetchNotes();
  print(notes.map((data) => Note.fromJson(data)).toList());
  return notes.map((data) => Note.fromJson(data)).toList();
});

class NotesList extends ConsumerWidget {
  const NotesList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch our FutureProvider to display notes.
    final notesAsync = ref.watch(notesListProvider);
    final themeMode = ref.watch(themeProvider);    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drive Notes"),
        actions: [
          // The switch toggles between dark and light mode.
          Switch(
            value: themeMode == ThemeMode.dark,
            onChanged: (isDark) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No notes found yet. Create your first note using the + button below!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    note.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      note.content.length > 100
                          ? "${note.content.substring(0, 100)}..."
                          : note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  onTap: () async {
                    // Navigate to the edit note screen.

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditNote(
                          fileId: note.id,
                          intialTitle: note.title,
                          intialContent: note.content,
                        ),
                      ),
                    );
                    if (result == true) {
                      ref.refresh(notesListProvider);
                    }
                  },
                  onLongPress: () async {
                    final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Delete Note"),
                            content: const Text(
                                "Are you sure you want to delete this note?"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text("Delete"),
                              ),
                            ],
                          );
                        });
                    if (confirm == true) {
                      try {
                        // Delete the note using the repository.
                        await ref
                            .read(notesRepositoryProvider)
                            .deleteNote(fileId: note.id);
                        // Refresh the list after deletion.
                        ref.refresh(notesListProvider);
                      } catch (err) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error deleting note: $err"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load notes.\nError: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(notesListProvider),
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          print("Create Note");
          // Navigate to the note creation screen.
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
          );
          // If a note was created, refresh the list.
          if (result == true) {
            ref.refresh(notesListProvider);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Note"),
      ),
    );
  }
}


// final dioProvider = Provider<Dio> ((ref) {
//   return Dio();
// },);

// final noteServiceProvider = Provider<NotesService>((ref) {
//   final dio = ref.watch(dioProvider);
// return NotesService(dio);
// });

// final authServiceProvider = Provider<AuthService>((ref){
// return AuthService();
// });

// final notesRepositoryProvider = Provider<NoteRepository>((ref){
//   final noteServices = ref.watch(noteServiceProvider);
//   final authService = ref.watch(authServiceProvider);
// return NoteRepository(notesService: noteServices, authSrvice: authService);
// });