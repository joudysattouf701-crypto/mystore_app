import 'package:mystore/core/network/api_client.dart';
import 'package:mystore/core/network/api_endpoints.dart';
import 'notifications_list_model.dart';

class NotificationsListService {
  final ApiClient _api = ApiClient.instance;

  // تحتاج توكن، والسيرفر يرجع للزبون إشعاراته فقط
  Future<NotificationsListModel> getNotifications({
    bool unreadOnly = false,
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _api.get(
      ApiEndpoints.notifications,
      query: {
        if (unreadOnly) "unread": '1',
        "page": '$page',
        "per_page": '$perPage',
      },
    );

    return NotificationsListModel.fromJson(response);
  }
}
