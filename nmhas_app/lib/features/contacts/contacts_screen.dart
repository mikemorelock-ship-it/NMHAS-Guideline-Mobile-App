import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../protocols/protocols_screen.dart';
import 'models/contact.dart';
import 'repositories/contact_repository.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(selectedScopeProvider);
    final contactsAsync = ref.watch(contactsProvider(scope));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: contactsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppColors.lightGray),
              const SizedBox(height: 16),
              Text(
                'Unable to load contacts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Check your connection and try again',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        data: (contacts) {
          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.contacts, size: 64, color: AppColors.teal),
                  const SizedBox(height: 16),
                  Text(
                    'No contacts yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contacts will appear here once added by an admin',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }
          return _ContactList(contacts: contacts);
        },
      ),
    );
  }
}

class _ContactList extends StatelessWidget {
  const _ContactList({required this.contacts});

  final List<Contact> contacts;

  @override
  Widget build(BuildContext context) {
    // Group contacts by category
    final grouped = <String, List<Contact>>{};
    for (final contact in contacts) {
      grouped.putIfAbsent(contact.category, () => []).add(contact);
    }

    final categories = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final items = grouped[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                category.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.teal,
                      letterSpacing: 1.2,
                    ),
              ),
            ),
            ...items.map((contact) => _ContactTile(contact: contact)),
            if (index < categories.length - 1) const Divider(),
          ],
        );
      },
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.teal.withAlpha(30),
        child: Icon(
          _categoryIcon(contact.category),
          color: AppColors.teal,
        ),
      ),
      title: Text(contact.name),
      subtitle: contact.title != null ? Text(contact.title!) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (contact.phone != null)
            IconButton(
              icon: const Icon(Icons.phone),
              tooltip: contact.phone,
              onPressed: () => _launchPhone(contact.phone!),
            ),
          if (contact.email != null)
            IconButton(
              icon: const Icon(Icons.email_outlined),
              tooltip: contact.email,
              onPressed: () => _launchEmail(contact.email!),
            ),
        ],
      ),
      onTap: contact.notes != null
          ? () => _showContactDetails(context, contact)
          : null,
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'dispatch':
        return Icons.headset_mic;
      case 'medical control':
        return Icons.local_hospital;
      case 'poison control':
        return Icons.warning_amber;
      case 'interpreter':
        return Icons.translate;
      case 'administration':
        return Icons.business;
      default:
        return Icons.person;
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showContactDetails(BuildContext context, Contact contact) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (contact.title != null) ...[
              const SizedBox(height: 4),
              Text(
                contact.title!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (contact.phone != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.phone, size: 20),
                  const SizedBox(width: 12),
                  Text(contact.phone!),
                ],
              ),
            ],
            if (contact.email != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email_outlined, size: 20),
                  const SizedBox(width: 12),
                  Text(contact.email!),
                ],
              ),
            ],
            if (contact.notes != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                contact.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
