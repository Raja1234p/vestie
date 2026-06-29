import 'package:flutter/material.dart';

/// Attaches a [ScrollController] listener that triggers [onLoadMore] near the end.
class PaginatedScrollListener {
  PaginatedScrollListener({
    required ScrollController controller,
    required this.onLoadMore,
    this.threshold = 200,
  }) : _controller = controller {
    _controller.addListener(_handleScroll);
  }

  final ScrollController _controller;
  final VoidCallback onLoadMore;
  final double threshold;

  void _handleScroll() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (position.maxScrollExtent - position.pixels <= threshold) {
      onLoadMore();
    }
  }

  void dispose() {
    _controller.removeListener(_handleScroll);
  }
}
