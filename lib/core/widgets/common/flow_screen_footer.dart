import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';

/// Bottom inset shared by [FlowScreenFooter] and scroll-only flow screens.
class FlowScreenFooterInsets {
  FlowScreenFooterInsets._();

  /// Horizontal gutter for pinned flow footers (matches [AppDimens.postAuthFlowScrollPadding]).
  static double horizontal(BuildContext context) => AppDimens.p20;

  /// Pinned footers and short scroll tails (default min [AppDimens.v24]).
  static double bottom(BuildContext context) =>
      scrollTail(context, designMinimum: AppDimens.v16);

  /// Scroll content tail: design gap + system nav bar / home indicator inset.
  static double scrollTail(
    BuildContext context, {
    double? designMinimum,
  }) {
    final mq = MediaQuery.of(context);
    final systemBottom = math.max(mq.viewPadding.bottom, mq.padding.bottom);
    final min = designMinimum ?? AppDimens.v24;
    return math.max(min, systemBottom + AppDimens.v8);
  }

  static EdgeInsets footerPadding(BuildContext context) {
    return EdgeInsets.fromLTRB(
      horizontal(context),
      0,
      horizontal(context),
      bottom(context),
    );
  }

  /// List body when there is no pinned footer button (safe-area bottom inset).
  static EdgeInsets listPadding(
    BuildContext context, {
    double top = 0,
    double? horizontal,
  }) {
    final h = horizontal ?? FlowScreenFooterInsets.horizontal(context);
    return EdgeInsets.fromLTRB(h, top, h, bottom(context));
  }
}

/// Pinned footer inset for flow screens (Android nav bar + iOS home indicator).
class FlowScreenFooter extends StatelessWidget {
  final Widget child;

  const FlowScreenFooter({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: FlowScreenFooterInsets.footerPadding(context),
      child: child,
    );
  }
}
