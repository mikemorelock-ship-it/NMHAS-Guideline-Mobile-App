import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../protocols/repositories/protocol_repository.dart';
import '../models/contact.dart';

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  return ContactRepository(ref.watch(firestoreProvider));
});

/// Streams all active contacts, optionally filtered by scope.
final contactsProvider =
    StreamProvider.family<List<Contact>, String?>((ref, scope) {
  return ref.watch(contactRepositoryProvider).watchContacts(scope: scope);
});

class ContactRepository {
  ContactRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('contacts');

  /// Watch all active contacts, optionally filtered by scope.
  /// Contacts with scope "All" are always included.
  Stream<List<Contact>> watchContacts({String? scope}) {
    var query = _collection.where('isActive', isEqualTo: true);

    return query.orderBy('category').orderBy('sortOrder').snapshots().map(
        (snapshot) => snapshot.docs
            .map(Contact.fromFirestore)
            .where(
                (c) => scope == null || c.scope == 'All' || c.scope == scope)
            .toList());
  }
}
