import 'package:drive_notes/notes/providers/notes_providers.dart';
import 'package:drive_notes/notes/screens/notes_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/note_repository.dart';

class CreateNoteScreen extends ConsumerStatefulWidget {
  const CreateNoteScreen({Key? key}) : super(key: key);

  @override
  _CreateNoteScreenState createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends ConsumerState<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Call your NoteRepository to add the new note.
      final noteRepository = ref.read(notesRepositoryProvider);
      await noteRepository.addNote(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      );

      // Saved, return to the previous screen.
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (err) {
      print("--- error in saving the note ----" + err.toString());
      // Show error if something goes wrong.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error saving note"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a Scaffold with an AppBar and a form in the body.
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title text field.
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a title.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              const Divider(thickness: 1),
              const SizedBox(height: 12),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration.collapsed(
                    hintText: "Start typing your note...",
                  ),
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter some content.";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
