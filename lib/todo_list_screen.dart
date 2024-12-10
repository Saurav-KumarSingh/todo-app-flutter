import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ToDoListScreen extends StatefulWidget {
  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _toDoList = [];
  List<Map<String, dynamic>> _filteredToDoList = [];

  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final CollectionReference _tasksCollection =
  FirebaseFirestore.instance.collection('tasks');

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _searchController.addListener(_filterToDoList);
  }

  Future<void> _fetchTasks() async {
    final snapshot = await _tasksCollection
        .where('userId', isEqualTo: userId) // Fetch tasks for the current user
        .get();
    setState(() {
      _toDoList = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
      _filteredToDoList = List.from(_toDoList);
    });
  }

  Future<void> _addToDoItem(String task) async {
    final newTask = {'task': task, 'userId': userId}; // Store userId with task
    final docRef = await _tasksCollection.add(newTask);
    setState(() {
      _toDoList.add({'id': docRef.id, ...newTask});
      _filteredToDoList.add({'id': docRef.id, ...newTask});
    });
  }

  Future<void> _updateToDoItem(String id, String task) async {
    await _tasksCollection.doc(id).update({'task': task});
    _fetchTasks();
  }

  Future<void> _removeToDoItem(String id) async {
    await _tasksCollection.doc(id).delete();
    _fetchTasks();
  }

  void _filterToDoList() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      _filteredToDoList = _toDoList
          .where((task) =>
          task['task'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search tasks",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          // Task List
          Expanded(
            child: _filteredToDoList.isEmpty
                ? Center(
              child: Text(
                "No tasks yet! Tap the + button to add a task.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _filteredToDoList.length,
              itemBuilder: (context, index) {
                final task = _filteredToDoList[index];
                return Card(
                  child: ListTile(
                    title: Text(task['task']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _textController.text = task['task'];
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Edit Task"),
                                  content: TextField(
                                    controller: _textController,
                                    decoration: InputDecoration(hintText: "Edit your task"),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _updateToDoItem(task['id'], _textController.text);
                                        Navigator.pop(context);
                                      },
                                      child: Text("Update"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeToDoItem(task['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Add Task"),
                content: TextField(
                  controller: _textController,
                  decoration: InputDecoration(hintText: "Enter your task"),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      _addToDoItem(_textController.text);
                      _textController.clear();
                      Navigator.pop(context);
                    },
                    child: Text("Add"),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
