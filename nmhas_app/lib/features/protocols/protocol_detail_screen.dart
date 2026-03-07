import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../core/theme/app_colors.dart';
import 'models/protocol.dart';
import 'repositories/protocol_repository.dart';

/// Provider that fetches a single protocol by ID.
final protocolDetailProvider =
    FutureProvider.family<Protocol?, String>((ref, id) {
  return ref.watch(protocolRepositoryProvider).getProtocol(id);
});

class ProtocolDetailScreen extends ConsumerWidget {
  const ProtocolDetailScreen({super.key, required this.protocolId});

  final String protocolId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final protocolAsync = ref.watch(protocolDetailProvider(protocolId));

    return protocolAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.orangeRed),
              const SizedBox(height: 16),
              Text(
                'Failed to load protocol',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Check your connection and try again',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref.invalidate(protocolDetailProvider(protocolId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (protocol) {
        if (protocol == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 48, color: AppColors.lightGray),
                  const SizedBox(height: 16),
                  Text(
                    'Protocol not found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        }

        return _ProtocolDetailView(protocol: protocol);
      },
    );
  }
}

class _ProtocolDetailView extends StatelessWidget {
  const _ProtocolDetailView({required this.protocol});

  final Protocol protocol;

  @override
  Widget build(BuildContext context) {
    final hasPdf = protocol.pdfUrl != null && protocol.pdfUrl!.isNotEmpty;
    final hasContent = protocol.content != null && protocol.content!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          protocol.title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (hasPdf && hasContent)
            _ViewToggleButton(),
        ],
      ),
      body: hasPdf
          ? _PdfView(pdfUrl: protocol.pdfUrl!)
          : hasContent
              ? _ContentView(protocol: protocol)
              : _EmptyProtocolView(),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // For protocols with both PDF and content, we could add a toggle.
    // For now this is a placeholder — most protocols will have one or the other.
    return const SizedBox.shrink();
  }
}

class _PdfView extends StatefulWidget {
  const _PdfView({required this.pdfUrl});

  final String pdfUrl;

  @override
  State<_PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<_PdfView> {
  late PdfViewerController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = PdfViewerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SfPdfViewer.network(
          widget.pdfUrl,
          controller: _controller,
          canShowScrollHead: true,
          canShowScrollStatus: true,
          onDocumentLoaded: (_) {
            setState(() => _isLoading = false);
          },
          onDocumentLoadFailed: (details) {
            setState(() {
              _isLoading = false;
              _errorMessage = details.description;
            });
          },
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator()),
        if (_errorMessage != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf, size: 48, color: AppColors.orangeRed),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load PDF',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ContentView extends StatelessWidget {
  const _ContentView({required this.protocol});

  final Protocol protocol;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with metadata
          _MetadataChips(protocol: protocol),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          // Protocol content
          SelectableText(
            protocol.content!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 32),
          // Version info
          Text(
            'Version ${protocol.version} · Updated ${_formatDate(protocol.updatedAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.lightGray,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _MetadataChips extends StatelessWidget {
  const _MetadataChips({required this.protocol});

  final Protocol protocol;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(
          avatar: const Icon(Icons.folder_outlined, size: 18),
          label: Text(protocol.category),
        ),
        Chip(
          avatar: const Icon(Icons.location_on_outlined, size: 18),
          label: Text(protocol.scope),
        ),
        ...protocol.tags.map(
          (tag) => Chip(
            avatar: const Icon(Icons.label_outline, size: 18),
            label: Text(tag),
          ),
        ),
      ],
    );
  }
}

class _EmptyProtocolView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: AppColors.teal),
          const SizedBox(height: 16),
          Text(
            'No content available yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This protocol is being prepared',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
