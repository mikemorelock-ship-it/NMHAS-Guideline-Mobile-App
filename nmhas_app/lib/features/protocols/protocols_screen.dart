import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import 'models/protocol.dart';
import 'repositories/protocol_repository.dart';

/// Currently selected scope (MN, WI, Air Medical).
final selectedScopeProvider = StateProvider<String>((ref) => 'MN');

/// Search query for filtering protocols client-side.
final protocolSearchQueryProvider = StateProvider<String>((ref) => '');

class ProtocolsScreen extends ConsumerWidget {
  const ProtocolsScreen({super.key});

  static const _scopes = ['MN', 'WI', 'Air Medical'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(selectedScopeProvider);
    final protocolsAsync = ref.watch(protocolsProvider(scope));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Protocols'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search protocols',
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ProtocolSearchDelegate(ref: ref, scope: scope),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String>(
              segments: _scopes
                  .map((s) => ButtonSegment(value: s, label: Text(s)))
                  .toList(),
              selected: {scope},
              onSelectionChanged: (selected) {
                ref.read(selectedScopeProvider.notifier).state = selected.first;
              },
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return null;
                }),
              ),
            ),
          ),
        ),
      ),
      body: protocolsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppColors.lightGray),
              const SizedBox(height: 16),
              Text(
                'Unable to load protocols',
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
        data: (protocols) {
          if (protocols.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books, size: 64, color: AppColors.teal),
                  const SizedBox(height: 16),
                  Text(
                    'No protocols yet for $scope',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Protocols will appear here once added by an admin',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }
          return _ProtocolList(protocols: protocols);
        },
      ),
    );
  }
}

class _ProtocolList extends StatelessWidget {
  const _ProtocolList({required this.protocols});

  final List<Protocol> protocols;

  @override
  Widget build(BuildContext context) {
    // Group protocols by category
    final grouped = <String, List<Protocol>>{};
    for (final protocol in protocols) {
      grouped.putIfAbsent(protocol.category, () => []).add(protocol);
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
            ...items.map((protocol) => ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(protocol.title),
                  subtitle: protocol.tags.isNotEmpty
                      ? Text(protocol.tags.join(', '))
                      : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.go('/protocols/${protocol.id}');
                  },
                )),
            if (index < categories.length - 1) const Divider(),
          ],
        );
      },
    );
  }
}

/// Search delegate that filters protocols by title, category, and tags.
class _ProtocolSearchDelegate extends SearchDelegate<String?> {
  _ProtocolSearchDelegate({required this.ref, required this.scope});

  final WidgetRef ref;
  final String scope;

  @override
  String get searchFieldLabel => 'Search protocols...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.lightGray),
            const SizedBox(height: 16),
            Text(
              'Search by title, category, or tag',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final protocolsAsync = ref.watch(protocolsProvider(scope));

    return protocolsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('Unable to search')),
      data: (protocols) {
        final lowerQuery = query.toLowerCase();
        final filtered = protocols.where((p) {
          return p.title.toLowerCase().contains(lowerQuery) ||
              p.category.toLowerCase().contains(lowerQuery) ||
              p.tags.any((t) => t.toLowerCase().contains(lowerQuery));
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 48, color: AppColors.lightGray),
                const SizedBox(height: 16),
                Text(
                  'No protocols match "$query"',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final protocol = filtered[index];
            return ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(protocol.title),
              subtitle: Text(protocol.category),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                close(context, null);
                context.go('/protocols/${protocol.id}');
              },
            );
          },
        );
      },
    );
  }
}
