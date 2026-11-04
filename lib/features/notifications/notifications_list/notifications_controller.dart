import 'package:mystore/core/network/api_exception.dart';
import 'package:mystore/core/utils/app_snackbar.dart';
import 'package:mystore/features/notifications/mark_read/mark_read_model.dart';
import 'package:mystore/features/notifications/mark_read/mark_read_service.dart';
import 'package:mystore/features/notifications/notification_model.dart';
import 'package:get/get.dart';
import 'notifications_list_model.dart';
import 'notifications_list_service.dart';

class NotificationsController extends GetxController {
  static const int _perPage = 15;

  final NotificationsListService _notificationsService =
      NotificationsListService();
  final MarkReadService _markReadService = MarkReadService();

  // false يعني "الكل"
  var unreadOnly = false.obs;

  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;

  // رسالة فشل تحميل الصفحة الأولى، تظهر مع زر إعادة المحاولة
  var errorMessage = RxnString();

  int _page = 1;
  int _lastPage = 1;
  bool get hasMore => _page < _lastPage;

  // رقم آخر طلب، حتى نتجاهل رد فلتر قديم إن بدّل الزبون الفلتر بسرعة
  int _requestId = 0;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  void selectUnreadOnly(bool value) {
    if (unreadOnly.value == value) return;
    unreadOnly.value = value;
    fetchNotifications();
  }

  // تحميل الصفحة الأولى من جديد (عند الفتح، وتبديل الفلتر، والسحب للتحديث)
  Future<void> fetchNotifications() async {
    final int request = ++_requestId;

    try {
      isLoading.value = true;
      errorMessage.value = null;

      NotificationsListModel result = await _notificationsService
          .getNotifications(
            unreadOnly: unreadOnly.value,
            page: 1,
            perPage: _perPage,
          );
      if (request != _requestId) return;

      notifications.value = result.notifications;
      _page = result.meta.currentPage;
      _lastPage = result.meta.lastPage;
    } on ApiException catch (e) {
      if (request != _requestId) return;
      errorMessage.value = e.displayMessage;
    } finally {
      if (request == _requestId) isLoading.value = false;
    }
  }

  // الصفحة التالية عند الوصول لآخر القائمة
  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore) return;
    final int request = _requestId;

    try {
      isLoadingMore.value = true;

      NotificationsListModel result = await _notificationsService
          .getNotifications(
            unreadOnly: unreadOnly.value,
            page: _page + 1,
            perPage: _perPage,
          );
      if (request != _requestId) return;

      notifications.addAll(result.notifications);
      _page = result.meta.currentPage;
      _lastPage = result.meta.lastPage;
    } on ApiException catch (e) {
      if (request == _requestId) AppSnackbar.apiError(e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  // عند فتح الإشعار. يبقى في القائمة بشكل المقروء حتى لو كان الفلتر "غير المقروءة"
  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      MarkReadModel result = await _markReadService.markAsRead(
        notification.id,
      );

      final int index = notifications.indexWhere(
        (item) => item.id == notification.id,
      );
      if (index != -1) notifications[index] = result.notification;
    } on ApiException {
      // فشل التعليم لا يمنع الزبون من شيء، ويبقى الإشعار غير مقروء ليعاد لاحقاً
    }
  }
}
