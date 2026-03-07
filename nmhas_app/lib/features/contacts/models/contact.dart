import 'package:cloud_firestore/cloud_firestore.dart';

/// A contact entry in the directory (interpreters, poison control, dispatch, etc.).
class Contact {
  Contact({
    required this.id,
    required this.name,
    required this.category,
    this.title,
    this.phone,
    this.email,
    this.notes,
    required this.scope,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String category; // e.g. "Dispatch", "Medical Control", "Poison Control", "Interpreter"
  final String? title;
  final String? phone;
  final String? email;
  final String? notes;
  final String scope; // "MN", "WI", "Air Medical", or "All"
  final int sortOrder;
  final bool isActive;

  factory Contact.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Contact(
      id: doc.id,
      name: data['name'] as String,
      category: data['category'] as String,
      title: data['title'] as String?,
      phone: data['phone'] as String?,
      email: data['email'] as String?,
      notes: data['notes'] as String?,
      scope: data['scope'] as String? ?? 'All',
      sortOrder: data['sortOrder'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'title': title,
      'phone': phone,
      'email': email,
      'notes': notes,
      'scope': scope,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }
}
