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
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      unknownRoute: GetPage(name: '/notfound', page: () => const UnknownRoutePage()),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomePage()),
        GetPage(name: '/newnote', page: () => const NewNotePage()),
        GetPage(name: '/editnote', page: () => const EditNotePage()),
      ],
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search notes',
          border: OutlineInputBorder(),
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

class Notes extends StatelessWidget {
  final List<Note> notes;
  const Notes({Key? key, required this.notes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Center(
        child: const Text("No notes found"),
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
          onLongPress: () {
            // Handle long press
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: Text(
              notes[index].title!,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
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
    print("Notes: ${controller.notes}");

    return Scaffold(
      appBar: AppBar(
        title: const Text("NotexApp"),
      ),
      body: Column(
        children: <Widget>[
          const SearchBar(),
          const SizedBox(height: 8), // Add spacing between SearchBar and Notes
          Expanded(
            child: Notes(notes: controller.notes),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed("/newnote");
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
          Get.back();
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
      cursorColor: Colors.black,
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
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        border: InputBorder.none,
      ),
      autofocus: true,
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
