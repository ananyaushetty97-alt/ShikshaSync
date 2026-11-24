import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/mastery_event.dart';
import 'db_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final DbService _db = DbService();
  final Connectivity _connectivity = Connectivity();

  String get _baseUrl => 'https://your-api-gateway-url.execute-api.us-east-1.amazonaws.com/prod';

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  /// Check if device has internet connectivity
  Future<bool> hasConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Sync all unsynced events to backend
  Future<SyncResult> sync() async {
    if (_isSyncing) return SyncResult(success: false, message: 'Already syncing');

    final hasNet = await hasConnectivity();
    if (!hasNet) {
      return SyncResult(success: false, message: 'No internet connection');
    }

    _isSyncing = true;
    try {
      final events = await _db.getUnsyncedEvents();
      if (events.isEmpty) {
        _isSyncing = false;
        return SyncResult(success: true, message: 'Nothing to sync', eventsSynced: 0);
      }

      final payload = events.map((e) => e.toJson()).toList();
      final response = await http.post(
        Uri.parse('$_baseUrl/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'events': payload}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final eventIds = events.map((e) => e.eventId).toList();
        await _db.markEventsSynced(eventIds);
        _isSyncing = false;
        return SyncResult(
          success: true,
          message: 'Synced ${events.length} events',
          eventsSynced: events.length,
        );
      } else {
        _isSyncing = false;
        return SyncResult(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      _isSyncing = false;
      return SyncResult(success: false, message: 'Sync failed: $e');
    }
  }

  /// Fetch lesson pack manifest
  Future<Map<String, dynamic>?> fetchManifest() async {
    final hasNet = await hasConnectivity();
    if (!hasNet) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/manifest'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Manifest fetch failed: $e');
    }
    return null;
  }

  /// Auto-sync on app resume/open
  Future<void> autoSyncIfNeeded() async {
    final hasNet = await hasConnectivity();
    if (hasNet && !_isSyncing) {
      await sync();
    }
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int eventsSynced;

  SyncResult({
    required this.success,
    required this.message,
    this.eventsSynced = 0,
  });
}