import 'package:mystore/core/network/api_client.dart';
import 'package:mystore/core/network/api_endpoints.dart';
import 'mark_read_model.dart';

class MarkReadService {
  final ApiClient _api = ApiClient.instance;

  // تحتاج توكن. التكرار لا يغيّر وقت القراءة الأول، وإشعار مستخدم آخر يرجع 404
  Future<MarkReadModel> markAsRead(int id) async {
    final response = await _api.patch(ApiEndpoints.notificationRead(id));

    return MarkReadModel.fromJson(response);
  }
}
