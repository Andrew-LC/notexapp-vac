import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/note_controller.dart';
import '../model/note_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark, // Set dark theme
        primaryColor: Colors.black, // Set primary color
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black.withOpacity(0.8), // Set app bar background color with opacity
        ),
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.white), // Set text color
          bodyText2: TextStyle(color: Colors.white), // Set text color
        ),
      ),
      unknownRoute: GetPage(name: '/notfound', page: () => const UnknownRoutePage()),
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/newnote', page: () => const NewNotePage()),
        GetPage(name: '/editnote', page: () => const EditNotePage()),
      ],
    );
  }
}

class Notes extends StatelessWidget {
  final List<Note> notes;
  const Notes({Key? key, required this.notes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NoteController controller = Get.put(NoteController()); // Initialize NoteController
    if (notes.isEmpty) {
      return Center(
        child: const Text(
          "No notes found",
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: notes.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            Get.toNamed("/editnote", arguments: index); // Pass index as argument
          },
          child: Dismissible(
            key: Key(notes[index].id.toString()),
            onDismissed: (direction) {
              controller.deleteNoteFromDB(notes[index].id!);
            },
            background: Container(
              color: Colors.red,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 30,
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
            ),
            child: Card(
              color: Colors.black.withOpacity(0.8),
              child: ListTile(
                title: Text(
                  notes[index].title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  notes[index].content!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          )
        );
      },
    );
  }
}



class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NoteController controller = Get.put(NoteController()); // Initialize NoteController

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "NotexApp",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: const Icon(
          Icons.note,
          color: Colors.white,
        ),
        backgroundColor: Colors.black.withOpacity(0.8),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 8), // Add spacing between SearchBar and Notes
          Expanded(
            child: GetBuilder<NoteController>(
              builder: (_) => Notes(notes: controller.notes),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed("/newnote");
          controller.refreshPage();
        },
        tooltip: 'Add new note',
        child: const Icon(Icons.note_add),
      ),
    );
  }
}

class NewNotePage extends StatelessWidget {
  const NewNotePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NoteController controller = Get.put(NoteController()); // Initialize NoteController
    controller.titleController.text = "";
    controller.contentController.text = "";
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
          ),
          child: Column(
            children: [
              _buildTextField(
                controller: controller.titleController,
                hintText: 'Title',
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: controller.contentController,
                hintText: 'Type note here...',
                fontSize: 22,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.addNoteToDB();
          controller.refreshPage();
        },
        label: const Text(
          "Save Note",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        icon: const Icon(
          Icons.save,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.normal,
    required TextEditingController controller,
    keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      cursorColor: Colors.purple,
      cursorWidth: 4.0,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        border: InputBorder.none,
      ),
      autofocus: true,
      maxLines: null,
      keyboardType: keyboardType,
    );
  }
}


class EditNotePage extends StatelessWidget {
  const EditNotePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NoteController controller = Get.put(NoteController()); // Initialize NoteController
    final int index = Get.arguments ?? 0; // Get index from arguments
    controller.titleController.text = controller.notes[index].title!;
    controller.contentController.text = controller.notes[index].content!;
    // final Note note = Get.find<NoteController>().notes[index]; // Get note by index
    // controller.titleController.text = note.title; // Populate title field
    // controller.contentController.text = note.content; // Populate content field
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note ${controller.notes[index].title!}'), // Display note index in title
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
          ),
          child: Column(
            children: [
              _buildTextField(
                controller: controller.titleController,
                hintText: 'Title',
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
              _buildTextField(
                controller: controller.contentController,
                hintText: 'Type note here...',
                fontSize: 22,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.updateNoteInDB(
            Note(
              id: controller.notes[index].id,
              title: controller.titleController.text,
              content: controller.contentController.text,
            ),
          );
        },
        label: const Text(
          "Update Note",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        icon: const Icon(
          Icons.save,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.normal,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      cursorColor: Colors.purple,
      cursorWidth: 4.0,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        border: InputBorder.none,
      ),
      autofocus: true,
      maxLines: null,
    );
  }
}


class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('404 - Page not found'),
            ElevatedButton(
              onPressed: () {
                Get.offAllNamed('/');
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
