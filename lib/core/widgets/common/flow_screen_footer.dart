import 'dart:math' as math;



import 'package:flutter/material.dart';



import '../../constants/app_dimens.dart';



/// Bottom inset shared by [FlowScreenFooter] and scroll-only flow screens.

class FlowScreenFooterInsets {

  FlowScreenFooterInsets._();



  /// Horizontal gutter for pinned flow footers (matches [AppDimens.postAuthFlowScrollPadding]).

  static double horizontal(BuildContext context) => AppDimens.p20;



  static double bottom(BuildContext context) {

    final mq = MediaQuery.of(context);

    final systemBottom = math.max(mq.viewPadding.bottom, mq.padding.bottom);

    return math.max(AppDimens.v24, systemBottom + AppDimens.v8);

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


