import 'package:flutter/material.dart';

import '../models/success_vote_cast_choice.dart';
import '../models/success_vote_cast_copy.dart';
import '../models/success_vote_cast_ui_data.dart';
import 'success_vote_cast_body.dart';

/// Scrolls only when [SuccessVoteCastBody] is taller than the viewport.
class SuccessVoteCastScrollBody extends StatefulWidget {
  final SuccessVoteCastUiData data;
  final SuccessVoteCastCopy copy;
  final SuccessVoteCastChoice choice;

  const SuccessVoteCastScrollBody({
    super.key,
    required this.data,
    required this.copy,
    required this.choice,
  });

  @override
  State<SuccessVoteCastScrollBody> createState() =>
      _SuccessVoteCastScrollBodyState();
}

class _SuccessVoteCastScrollBodyState extends State<SuccessVoteCastScrollBody> {
  final GlobalKey _contentKey = GlobalKey();
  double _maxHeight = 0;
  bool _needsScroll = true;

  @override
  void didUpdateWidget(covariant SuccessVoteCastScrollBody oldWidget) {
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
    return SuccessVoteCastBody(
      key: _contentKey,
      data: widget.data,
      copy: widget.copy,
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

        return Align(alignment: Alignment.topCenter, child: _voteBody());
      },
    );
  }
}

/// @deprecated Use [SuccessVoteCastScrollBody].
typedef MemberSuccessVoteScrollBody = SuccessVoteCastScrollBody;
