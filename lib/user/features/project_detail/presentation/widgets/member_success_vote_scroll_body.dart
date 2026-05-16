import 'package:flutter/material.dart';

import '../models/member_success_vote_ui_data.dart';
import 'member_success_vote_body.dart';

/// Scrolls only when [MemberSuccessVoteBody] is taller than the viewport.
class MemberSuccessVoteScrollBody extends StatefulWidget {
  final MemberSuccessVoteUiData data;
  final MemberSuccessVoteChoice choice;

  const MemberSuccessVoteScrollBody({
    super.key,
    required this.data,
    required this.choice,
  });

  @override
  State<MemberSuccessVoteScrollBody> createState() =>
      _MemberSuccessVoteScrollBodyState();
}

class _MemberSuccessVoteScrollBodyState extends State<MemberSuccessVoteScrollBody> {
  final GlobalKey _contentKey = GlobalKey();
  double _maxHeight = 0;
  bool _needsScroll = true;

  @override
  void didUpdateWidget(covariant MemberSuccessVoteScrollBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.choice != widget.choice) {
      _scheduleMeasure();
    }
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollNeeded());
  }

  void _updateScrollNeeded() {
    if (!mounted) return;
    final box = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || _maxHeight <= 0) return;

    final needsScroll = box.size.height > _maxHeight;
    if (needsScroll != _needsScroll) {
      setState(() => _needsScroll = needsScroll);
    }
  }

  Widget _voteBody() {
    return MemberSuccessVoteBody(
      key: _contentKey,
      data: widget.data,
      choice: widget.choice,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight != _maxHeight) {
          _maxHeight = constraints.maxHeight;
          _scheduleMeasure();
        }

        if (_needsScroll) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: _voteBody(),
          );
        }

        return Align(
          alignment: Alignment.topCenter,
          child: _voteBody(),
        );
      },
    );
  }
}
