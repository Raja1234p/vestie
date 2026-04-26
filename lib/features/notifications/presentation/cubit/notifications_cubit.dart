import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/notification_samples.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit()
      : super(
          NotificationsState(
            items: kOpenNotificationsWithSampleList
                ? kDebugNotificationSamples
                : const [],
          ),
        );
}
