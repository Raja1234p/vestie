import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_distribution_ui_data.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';

/// Breakdown table — MEMBER / CONTRIBUTED / SHARE / RECEIVES (Figma).
class InvestmentDistributionBreakdownTable extends StatelessWidget {
  final List<DistributionMemberRowUi> members;

  const InvestmentDistributionBreakdownTable({
    super.key,
    required this.members,
  });

  static final Map<int, TableColumnWidth> _columnWidths = {
    0: const FlexColumnWidth(1.25),
    1: const FlexColumnWidth(1.25),
    2: const FlexColumnWidth(0.85),
    3: const FlexColumnWidth(1.05),
  };

  /// Matches [FlexColumnWidth] ratios for the header [Row].
  static const List<int> _columnFlex = [125, 125, 85, 105];

  static EdgeInsets get _tableHorizontalPadding =>
      EdgeInsets.symmetric(horizontal: AppDimens.p12);

  static EdgeInsets get _valueVerticalPadding =>
      EdgeInsets.symmetric(vertical: AppDimens.v12);

  static Alignment _alignmentForColumn(int columnIndex) {
    return switch (columnIndex) {
      0 || 1 => Alignment.centerLeft,
      _ => Alignment.centerRight,
    };
  }

  static TextStyle get _headerStyle => GoogleFonts.lato(
    fontSize: 10.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral1200,
    height: 1.2,
  );

  static TextStyle _valueStyle({
    Color color = AppColors.grey800,
    FontWeight fontWeight = FontWeight.w600,
  }) => GoogleFonts.lato(
    fontSize: 12.sp,
    fontWeight: fontWeight,
    color: color,
    height: 1.2,
  );

  BorderRadius get _borderRadius => BorderRadius.circular(AppRadius.r12);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: _borderRadius,
        side: const BorderSide(color: AppColors.neutral500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _headerBand(),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.neutral500.withValues(alpha: 0.5),
          ),
          Padding(
            padding: _tableHorizontalPadding,
            child: Table(
              columnWidths: _columnWidths,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: AppColors.neutral500.withValues(alpha: 0.5),
                ),
              ),
              children: members.map(_dataRow).toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }

  /// Full-bleed purple bar; text inset matches data rows below.
  Widget _headerBand() {
    return Container(
      height: 40.h,
      width: double.infinity,
      color: AppColors.purple100,
      padding: _tableHorizontalPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < 4; i++)
            Expanded(flex: _columnFlex[i], child: _headerLabelWidget(i)),
        ],
      ),
    );
  }

  Widget _headerLabelWidget(int columnIndex) {
    return Align(
      alignment: _alignmentForColumn(columnIndex),
      child: AppText(
        _headerLabel(columnIndex),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _headerStyle,
      ),
    );
  }

  String _headerLabel(int columnIndex) {
    return switch (columnIndex) {
      0 => AppStrings.investmentDistributionColMember,
      1 => AppStrings.investmentDistributionColContributed,
      2 => AppStrings.investmentDistributionColShare,
      _ => AppStrings.investmentDistributionColReceives,
    };
  }

  TableRow _dataRow(DistributionMemberRowUi member) {
    return TableRow(
      children: [
        _valueCell(member.name, columnIndex: 0),
        _valueCell(
          '\$${InvestmentReturnsUiData.formatMoney(member.contributedUsd)}',
          columnIndex: 1,
        ),
        _valueCell(member.shareLabel, columnIndex: 2),
        _valueCell(
          '\$${InvestmentReturnsUiData.formatMoney(member.receivesUsd)}',
          columnIndex: 3,
          color: AppColors.green900,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }

  Widget _valueCell(
    String text, {
    required int columnIndex,
    Color color = AppColors.grey800,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return Padding(
      padding: _valueVerticalPadding,
      child: Align(
        alignment: _alignmentForColumn(columnIndex),
        child: AppText(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _valueStyle(color: color, fontWeight: fontWeight),
        ),
      ),
    );
  }
}
