import 'package:drive_notes/notes/providers/notes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditNote extends ConsumerStatefulWidget {
  final String fileId;
  final String? intialTitle;
  final String intialContent; 

  const EditNote({
    Key? key,
    required this.fileId,
    this.intialTitle,
    required this.intialContent,
  }) : super(key: key);

  @override
  _EditNoteState createState() => _EditNoteState();
}

class _EditNoteState extends ConsumerState<EditNote> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;
  late final TextEditingController _titleController;
  bool _isSaving = false;
  bool _isLoadingContent = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the passed values.
    _contentController = TextEditingController(text: widget.intialContent);
    _titleController = TextEditingController(text: widget.intialTitle ?? '');

    if (widget.intialContent.isEmpty) {
      _isLoadingContent = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchNoteContent();
      });
    }
  }

  Future<void> _fetchNoteContent() async {
    try {
      final noteRepository = ref.read(notesRepositoryProvider);
      final downloadedContent = await noteRepository.downloadNoteContent(widget.fileId);
      setState(() {
        _contentController.text = downloadedContent;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading note content: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoadingContent = false;
      });
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final noteRepository = ref.read(notesRepositoryProvider);
      // Now pass both the new title and new content.
      await noteRepository.editNote(
        fileId: widget.fileId,
        newContent: _contentController.text.trim(),
        newTitle: _titleController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      print (e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error updating note"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Note"),
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
      body: _isLoadingContent
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (widget.intialTitle != null) ...[
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: "Title",
                                        border:InputBorder.none,

                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a title.";
                          }
                          return null;
                        },
                      ),
                    ],
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
