# Widget Usage Reference

This file tracks reusable widget usage so it is easy to manage refactors and avoid duplication.

## Canonical Shared Widgets

Use these as the main source of truth:

- `lib/core/widgets/common/app_button.dart`
- `lib/core/widgets/common/app_text_field.dart`
- `lib/core/widgets/common/app_loader.dart`
- `lib/core/widgets/common/post_auth_gradient_background.dart`
- `lib/core/widgets/common/post_auth_header.dart`
- `lib/core/widgets/text/app_text.dart` (re-export path; underlying canonical widget is in `common`)

## Compatibility Re-Export Files

These are intentionally thin re-exports to keep old imports working:

- `lib/core/widgets/inputs/app_text_field.dart` -> exports common `AppTextField`
- `lib/core/widgets/text/app_text.dart` -> exports common `AppText`
- `lib/core/widgets/state/app_loader.dart` -> exports common `AppLoader`

## Where Core Widgets Are Used

### `AppButton`
Used in:
- `lib/features/auth/presentation/pages/agreement_screen.dart`
- `lib/features/auth/presentation/widgets/forgot_password_form.dart`
- `lib/features/auth/presentation/widgets/login_form.dart`
- `lib/features/auth/presentation/widgets/register_form.dart`
- `lib/features/auth/presentation/widgets/reset_password_form.dart`
- `lib/features/create_project/presentation/pages/form_helpers.dart`
- `lib/features/create_project/presentation/pages/project_amount_screen.dart`
- `lib/features/home/presentation/widgets/home_empty_view.dart`
- `lib/features/onboarding/presentation/pages/onboarding_screen.dart`
- `lib/features/profile/presentation/pages/edit_profile_screen.dart`
- `lib/features/project_detail/presentation/pages/project_detail_screen.dart`
- `lib/features/wallet/presentation/pages/transaction_amount_screen.dart`
- `lib/features/wallet/presentation/pages/transaction_confirmation_screen.dart`
- `lib/features/wallet/presentation/widgets/wallet_action_buttons.dart`

### `AppTextField`
Used in:
- `lib/features/auth/presentation/widgets/auth_text_field.dart`
- `lib/features/auth/presentation/widgets/forgot_password_form.dart`
- `lib/features/auth/presentation/widgets/login_form.dart`
- `lib/features/auth/presentation/widgets/register_form.dart`
- `lib/features/auth/presentation/widgets/reset_password_form.dart`
- `lib/features/profile/presentation/pages/add_card_screen.dart`

### `AppLoader`
Used in:
- `lib/features/discover/presentation/pages/discover_screen.dart`
- `lib/features/home/presentation/pages/home_screen.dart`
- `lib/features/profile/presentation/pages/edit_profile_screen.dart`
- `lib/features/profile/presentation/pages/payment_methods_screen.dart`
- `lib/features/profile/presentation/pages/transaction_history_screen.dart`

### `AppText`
Used in:
- `lib/features/auth/presentation/pages/verify_screen.dart`
- `lib/features/create_project/presentation/pages/form_helpers.dart`
- `lib/features/create_project/presentation/pages/project_success_screen.dart`
- `lib/features/profile/presentation/pages/profile_screen.dart`
- `lib/features/profile/presentation/pages/tx_filter_bar.dart`
- `lib/features/profile/presentation/widgets/card_detail_sheet.dart`
- `lib/features/profile/presentation/widgets/payment_card_list.dart`
- `lib/features/profile/presentation/widgets/payment_empty_view.dart`
- `lib/features/profile/presentation/widgets/payment_primary_button.dart`
- `lib/features/profile/presentation/widgets/profile_logout_button.dart`
- `lib/features/profile/presentation/widgets/settings_section.dart`
- `lib/features/wallet/presentation/pages/transaction_amount_screen.dart`
- `lib/features/wallet/presentation/pages/transaction_confirmation_screen.dart`
- `lib/features/wallet/presentation/pages/transaction_success_screen.dart`
- `lib/features/wallet/presentation/pages/wallet_screen.dart`
- `lib/features/wallet/presentation/widgets/wallet_overview_card.dart`

### `PostAuthGradientBackground`
Used in:
- `lib/features/create_project/presentation/pages/project_borrowing_screen.dart`
- `lib/features/create_project/presentation/pages/project_details_screen.dart`
- `lib/features/create_project/presentation/pages/project_review_screen.dart`
- `lib/features/dashboard/presentation/pages/dashboard_screen.dart`
- `lib/features/discover/presentation/pages/discover_screen.dart`
- `lib/features/profile/presentation/pages/add_card_screen.dart`
- `lib/features/profile/presentation/pages/edit_profile_screen.dart`
- `lib/features/profile/presentation/pages/key_guidelines_screen.dart`
- `lib/features/profile/presentation/pages/payment_methods_screen.dart`
- `lib/features/profile/presentation/pages/profile_screen.dart`
- `lib/features/profile/presentation/pages/transaction_history_screen.dart`
- `lib/features/project_detail/presentation/pages/borrow_requests_screen.dart`
- `lib/features/project_detail/presentation/pages/project_detail_screen.dart`
- `lib/features/wallet/presentation/pages/transaction_amount_screen.dart`
- `lib/features/wallet/presentation/pages/transaction_confirmation_screen.dart`
- `lib/features/wallet/presentation/pages/wallet_screen.dart`

### `PostAuthHeader`
Used in:
- `lib/features/create_project/presentation/widgets/create_project_header.dart`
- `lib/features/discover/presentation/widgets/discover_header.dart`
- `lib/features/home/presentation/widgets/home_header.dart`
- `lib/features/profile/presentation/widgets/profile_sub_header.dart`
- `lib/features/project_detail/presentation/pages/borrow_requests_screen.dart`
- `lib/features/project_detail/presentation/pages/project_detail_screen.dart`
- `lib/features/wallet/presentation/pages/transaction_amount_screen.dart`
- `lib/features/wallet/presentation/pages/transaction_confirmation_screen.dart`
- `lib/features/wallet/presentation/pages/wallet_screen.dart`

## Home Project Card Split (Phase 4)

Current modular structure:

- `lib/features/home/presentation/widgets/project_card.dart` (main composition)
- `lib/features/home/presentation/widgets/project_card_components.dart` (barrel exports)
- `lib/features/home/presentation/widgets/project_card_chip_widgets.dart`
- `lib/features/home/presentation/widgets/project_card_detail_widgets.dart`
- `lib/features/home/presentation/widgets/project_card_action_button.dart`
- `lib/features/home/presentation/widgets/project_card_formatters.dart`

## Maintenance Rules

- Add new reusable widgets under `lib/core/widgets/common` unless feature-specific.
- If a widget is feature-specific, keep it under that feature's `widgets` folder.
- Avoid duplicate widget names/implementations in different folders.
- When adding a new shared widget, append usage entries to this file.
