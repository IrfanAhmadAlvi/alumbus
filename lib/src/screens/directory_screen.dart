import 'package:alumbus/src/models/user_model.dart';
import 'package:alumbus/src/providers/directory_provider.dart';
import 'package:alumbus/src/screens/profile_screen.dart';
import 'package:alumbus/src/widgets/alum_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  // --- STATE TO HOLD THE SEARCH QUERY ---
  String _batchQuery = '';
  final TextEditingController _batchSearchController = TextEditingController();

  @override
  void dispose() {
    _batchSearchController.dispose();
    super.dispose();
  }

  // --- METHOD TO UPDATE THE SEARCH QUERY ---
  void _updateBatchQuery(String batch) {
    setState(() {
      _batchQuery = batch.trim();
    });
  }

  // --- METHOD TO SHOW THE SEARCH DIALOG ---
  Future<void> _showBatchSearchDialog() async {
    // Set the controller's text to the current query before opening
    _batchSearchController.text = _batchQuery;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search by Batch'),
          content: TextField(
            controller: _batchSearchController,
            decoration: const InputDecoration(hintText: "Enter batch number (e.g., 2015)"),
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Clear'),
              onPressed: () {
                // Clear the search query and close the dialog
                _batchSearchController.clear();
                _updateBatchQuery('');
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Search'),
              onPressed: () {
                // When search is tapped, update the query and close the dialog
                _updateBatchQuery(_batchSearchController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text("Alumni Directory"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: "Search by Batch",
            onPressed: _showBatchSearchDialog,
          ),
        ],
      ),
      body: Consumer<DirectoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.alumni.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          }

          if (provider.errorMessage != null) {
            return Center(child: Text("An error occurred: ${provider.errorMessage}"));
          }

          if (provider.alumni.isEmpty) {
            return const Center(child: Text("No alumni found in the directory."));
          }

          // --- CORRECTED LOGIC: Filter the list here inside the build method ---
          final List<Alum> filteredAlumni;
          if (_batchQuery.isEmpty) {
            filteredAlumni = provider.alumni; // If no query, show all
          } else {
            // Otherwise, show the filtered list
            filteredAlumni = provider.alumni
                .where((alum) => alum.batch.toLowerCase() == _batchQuery.toLowerCase())
                .toList();
          }

          if (filteredAlumni.isEmpty) {
            return const Center(child: Text("No alumni found for this batch."));
          }

          return ListView.builder(
            itemCount: filteredAlumni.length,
            itemBuilder: (context, index) {
              final alum = filteredAlumni[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfileScreen(initialAlum: alum),
                  ));
                },
                child: AlumCard(alum: alum),
              );
            },
          );
        },
      ),
    );
  }
}