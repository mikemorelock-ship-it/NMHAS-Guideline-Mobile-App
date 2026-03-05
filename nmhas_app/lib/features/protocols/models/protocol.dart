import 'package:cloud_firestore/cloud_firestore.dart';

/// A clinical protocol/guideline document.
class Protocol {
  Protocol({
    required this.id,
    required this.title,
    required this.category,
    required this.scope,
    this.content,
    this.pdfUrl,
    required this.version,
    required this.updatedAt,
    this.tags = const [],
    this.isActive = true,
  });

  final String id;
  final String title;
  final String category; // e.g. "Cardiac", "Trauma", "Pediatric", "Medical"
  final String scope; // "MN", "WI", "Air Medical"
  final String? content; // Structured content (future)
  final String? pdfUrl; // PDF download URL (launch phase)
  final int version;
  final DateTime updatedAt;
  final List<String> tags;
  final bool isActive;

  factory Protocol.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Protocol(
      id: doc.id,
      title: data['title'] as String,
      category: data['category'] as String,
      scope: data['scope'] as String,
      content: data['content'] as String?,
      pdfUrl: data['pdfUrl'] as String?,
      version: data['version'] as int? ?? 1,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'scope': scope,
      'content': content,
      'pdfUrl': pdfUrl,
      'version': version,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
      'isActive': isActive,
    };
  }
}
