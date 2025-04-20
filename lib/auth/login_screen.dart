import 'package:drive_notes/auth/auth_provider.dart';
import 'package:drive_notes/notes/screens/notes_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authStateProvider);

// if user already logged in
    if (isLoggedIn) {
      //Navigate to NoteList      
      Future.microtask(() {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => NotesList(),
          ),
        );
      });
      //Show a progress indicator unitl the navigation is done
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In"),
        centerTitle: true,
        elevation: 4,
        leading: IconButton(
            onPressed: Navigator.of(context).pop, icon: Icon(Icons.arrow_back)),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: isLoggedIn
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => NotesList(),
                      ));
                      print("already logged in");
                    },
                    child: Text("Go to Notes"))
                : ElevatedButton(
                    onPressed: () async {
                      await ref.read(authStateProvider.notifier).login();
                    },
                    child: Text("Sign in with Google")),
          ),
        ),
      ),
    );
  }
}
