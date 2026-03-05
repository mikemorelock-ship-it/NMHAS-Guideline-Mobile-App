import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/protocol.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  final firestore = FirebaseFirestore.instance;

  // Enable offline persistence (critical for EMS offline-first).
  // Firestore caches all read documents locally by default on mobile.
  // This setting increases the cache size for heavy protocol content.
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  return firestore;
});

final protocolRepositoryProvider = Provider<ProtocolRepository>((ref) {
  return ProtocolRepository(ref.watch(firestoreProvider));
});

/// Streams all active protocols for a given scope, ordered by category.
final protocolsProvider =
    StreamProvider.family<List<Protocol>, String>((ref, scope) {
  return ref.watch(protocolRepositoryProvider).watchProtocols(scope: scope);
});

class ProtocolRepository {
  ProtocolRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('protocols');

  /// Watch all active protocols for a scope, ordered by category then title.
  Stream<List<Protocol>> watchProtocols({required String scope}) {
    return _collection
        .where('scope', isEqualTo: scope)
        .where('isActive', isEqualTo: true)
        .orderBy('category')
        .orderBy('title')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(Protocol.fromFirestore).toList());
  }

  /// Get a single protocol by ID.
  Future<Protocol?> getProtocol(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Protocol.fromFirestore(doc);
  }

  /// Search protocols by title (client-side for offline support).
  Stream<List<Protocol>> searchProtocols({
    required String scope,
    required String query,
  }) {
    // Firestore doesn't support full-text search natively.
    // For now, fetch all protocols for the scope and filter client-side.
    // This works well because the dataset is small (~200-500 protocols)
    // and all docs are cached locally.
    final lowercaseQuery = query.toLowerCase();
    return watchProtocols(scope: scope).map((protocols) => protocols
        .where((p) =>
            p.title.toLowerCase().contains(lowercaseQuery) ||
            p.category.toLowerCase().contains(lowercaseQuery) ||
            p.tags.any((t) => t.toLowerCase().contains(lowercaseQuery)))
        .toList());
  }
}
