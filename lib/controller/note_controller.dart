import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/note_model.dart';
import '../db_helper/db_helper.dart';

class NoteController extends GetxController {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  var notes = <Note>[].obs;

  @override
  void onInit() {
    getAllNotes();
    super.onInit();
  }

  bool isEmpty() {
    return notes.isEmpty;
  }

  void deleteNoteFromDB(int id) async {
    await DBHelper().delete(id);
    getAllNotes();
  }

  void updateNoteInDB(Note note) async {
    await DBHelper().update(note);
    getAllNotes();
    Get.back();
  }

  void getAllNotes() async {
    notes.value = await DBHelper().getNoteList();
    update();
  }

  void refreshPage() async {
    getAllNotes();
  }
  
  void addNoteToDB() async {
    await DBHelper().insert(
      Note(
        title: titleController.text,
        content: contentController.text,
      ),
    );
    titleController.clear();
    contentController.clear();
    getAllNotes();
    Get.back();
  }
}
