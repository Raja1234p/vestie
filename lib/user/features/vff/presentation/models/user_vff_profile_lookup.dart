import 'package:vestie/user/features/vff/presentation/models/user_vff_profile_ui_model.dart';

/// Maps a “My VFFs” connection id to mocked profile payloads (swap for API lookup).
UserVffProfileUiModel lookupUserVffProfileForConnection(
  String connectionId, {
  bool outboundRequestPending = false,
}) {
  switch (connectionId) {
    case 'olivia':
      return outboundRequestPending
          ? UserVffProfileUiModel.demoOliviaRequestSent()
          : UserVffProfileUiModel.demoOliviaInitial();
    case 'julian':
      return UserVffProfileUiModel.demoJulianLee();
    default:
      return UserVffProfileUiModel.demoJulianLee();
  }
}
