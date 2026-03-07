import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';

/// Tracks Firestore connectivity by listening to snapshot metadata.
/// When snapshots come fromCache only, we assume the device is offline.
final connectivityProvider =
    StreamProvider<bool>((ref) {
  // Firestore doesn't expose a direct connectivity stream, but we can
  // observe enableNetwork/disableNetwork effects via snapshot metadata.
  // A simpler approach: use a lightweight document listener.
  final controller = StreamController<bool>();

  final sub = FirebaseFirestore.instance
      .collection('_connectivity')
      .doc('ping')
      .snapshots(includeMetadataChanges: true)
      .listen((snapshot) {
    // hasPendingWrites == false && fromCache == true means we're offline
    final isOnline = !snapshot.metadata.isFromCache;
    controller.add(isOnline);
  }, onError: (_) {
    controller.add(false);
  });

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});

/// A banner that appears at the top of the screen when the device is offline.
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);

    return connectivity.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => _OfflineBanner(),
      data: (isOnline) => isOnline ? const SizedBox.shrink() : _OfflineBanner(),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.gold,
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 16, color: AppColors.gray),
          const SizedBox(width: 8),
          Text(
            'Offline — using cached data',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.gray,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
