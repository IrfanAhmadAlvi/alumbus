// lib/src/providers/directory_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/directory_service.dart';

class DirectoryProvider with ChangeNotifier {
  final DirectoryService _directoryService = DirectoryService();

  List<Alum> _alumni = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Alum> get alumni => _alumni;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAlumni() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _alumni = await _directoryService.getAlumni();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}