import 'package:flutter/material.dart';

class OfflineSyncBanner extends StatelessWidget {
  final int pendingCount;
  final bool isSyncing;
  final VoidCallback onSyncPressed;

  const OfflineSyncBanner({
    super.key,
    required this.pendingCount,
    required this.isSyncing,
    required this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingCount == 0 && !isSyncing) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_sync, color: Color(0xFFD97706)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$pendingCount Offline Transaction(s) Queued',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF92400E),
                  ),
                ),
                const Text(
                  'Encrypted locally. Tap to sync with banking gateway.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: isSyncing ? null : onSyncPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: isSyncing
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Sync Now', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
