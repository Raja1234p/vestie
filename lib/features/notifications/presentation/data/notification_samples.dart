import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/notification_list_entry.dart';

/// Set to `true` locally to preview the filled list design; production flow uses an
/// empty list until the API is wired.
const bool kOpenNotificationsWithSampleList = true;

/// Debug / design preview only — matches the notification list reference.
const List<NotificationListEntry> kDebugNotificationSamples = [
  NotificationListEntry(
    title: AppStrings.notificationSample1Title,
    body: AppStrings.notificationSample1Body,
    timeLabel: AppStrings.notificationTime3min,
  ),
  NotificationListEntry(
    title: AppStrings.notificationSample2Title,
    body: AppStrings.notificationSample2Body,
    timeLabel: AppStrings.notificationTime12min,
  ),
  NotificationListEntry(
    title: AppStrings.notificationSample3Title,
    body: AppStrings.notificationSample3Body,
    timeLabel: AppStrings.notificationTime1hr,
  ),
  NotificationListEntry(
    title: AppStrings.notificationSample4Title,
    body: AppStrings.notificationSample4Body,
    timeLabel: AppStrings.notificationTime2hr,
  ),
  NotificationListEntry(
    title: AppStrings.notificationSample5Title,
    body: AppStrings.notificationSample5Body,
    timeLabel: AppStrings.notificationTimeYesterday,
  ),
  NotificationListEntry(
    title: AppStrings.notificationSample6Title,
    body: AppStrings.notificationSample6Body,
    timeLabel: AppStrings.notificationTimeYesterday,
  ),
  NotificationListEntry(
    title: AppStrings.notificationSample7Title,
    body: AppStrings.notificationSample7Body,
    timeLabel: AppStrings.notificationTime2days,
  ),
];
