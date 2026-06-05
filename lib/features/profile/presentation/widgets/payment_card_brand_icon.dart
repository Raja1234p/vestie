import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';

/// Visa / Mastercard brand mark — uses Figma-export SVGs (flutter_svg compatible).
class PaymentCardBrandIcon extends StatelessWidget {
  final CardBrand brand;
  final double? width;
  final double? height;

  const PaymentCardBrandIcon({
    super.key,
    required this.brand,
    this.width,
    this.height,
  });

  static String assetFor(CardBrand brand) {
    switch (brand) {
      case CardBrand.visa:
        return AppAssets.paymentVisa;
      case CardBrand.mastercard:
      case CardBrand.other:
        return AppAssets.paymentMastercard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetFor(brand),
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
