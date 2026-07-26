import 'dart:async';
import 'package:flutter/material.dart';

enum StatusType { info, success, error, loading }

class StatusBanner extends StatefulWidget {
  final String message;
  final StatusType type;
  final Duration autoClear;
  final VoidCallback? onDismiss;

  const StatusBanner({
    super.key,
    required this.message,
    this.type = StatusType.info,
    this.autoClear = const Duration(seconds: 3),
    this.onDismiss,
  });

  @override
  State<StatusBanner> createState() => _StatusBannerState();
}

class _StatusBannerState extends State<StatusBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoClear.inMilliseconds > 0 && widget.type != StatusType.loading) {
      _timer = Timer(widget.autoClear, () {
        if (mounted) widget.onDismiss?.call();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _getColor() {
    switch (widget.type) {
      case StatusType.success:
        return Colors.green;
      case StatusType.error:
        return Colors.red;
      case StatusType.loading:
        return Colors.teal;
      case StatusType.info:
        return Colors.teal;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case StatusType.success:
        return Icons.check_circle;
      case StatusType.error:
        return Icons.error;
      case StatusType.loading:
        return Icons.hourglass_top;
      case StatusType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getColor().withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          if (widget.type == StatusType.loading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(_getIcon(), color: _getColor(), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.message,
              style: TextStyle(color: _getColor(), fontWeight: FontWeight.w500),
            ),
          ),
          if (widget.onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: widget.onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
