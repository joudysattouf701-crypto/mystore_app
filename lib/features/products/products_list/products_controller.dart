import 'package:mystore/core/network/api_exception.dart';
import 'package:mystore/core/utils/app_snackbar.dart';
import 'package:mystore/features/products/categories/categories_model.dart';
import 'package:mystore/features/products/categories/categories_service.dart';
import 'package:mystore/features/products/product_details/product_details_model.dart';
import 'package:get/get.dart';
import 'products_list_model.dart';
import 'products_list_service.dart';

class ProductsController extends GetxController {
  static const int _perPage = 15;

  final CategoriesService _categoriesService = CategoriesService();
  final ProductsListService _productsService = ProductsListService();

  var categories = <CategoryModel>[].obs;

  // null يعني "الكل"
  var selectedCategoryId = Rxn<int>();

  var products = <ProductModel>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;

  // رسالة فشل تحميل الصفحة الأولى، تظهر مع زر إعادة المحاولة
  var errorMessage = RxnString();

  int _page = 1;
  int _lastPage = 1;
  bool get hasMore => _page < _lastPage;

  // رقم آخر طلب، حتى نتجاهل رد تصنيف قديم إن بدّل الزبون التصنيف بسرعة
  int _requestId = 0;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    fetchProducts();
  }

  // فشل التصنيفات لا يمنع عرض المنتجات، فقط يختفي شريط التصنيفات
  Future<void> loadCategories() async {
    try {
      categories.value = await _categoriesService.getCategories();
    } on ApiException {
      // نبقي القائمة الحالية
    }
  }

  void selectCategory(int? categoryId) {
    if (selectedCategoryId.value == categoryId) return;
    selectedCategoryId.value = categoryId;
    fetchProducts();
  }

  // تحميل الصفحة الأولى من جديد (عند الفتح، وتبديل التصنيف، والسحب للتحديث)
  Future<void> fetchProducts() async {
    final int request = ++_requestId;

    try {
      isLoading.value = true;
      errorMessage.value = null;

      ProductsListModel result = await _productsService.getProducts(
        categoryId: selectedCategoryId.value,
        page: 1,
        perPage: _perPage,
      );
      if (request != _requestId) return;

      products.value = result.products;
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

      ProductsListModel result = await _productsService.getProducts(
        categoryId: selectedCategoryId.value,
        page: _page + 1,
        perPage: _perPage,
      );
      if (request != _requestId) return;

      products.addAll(result.products);
      _page = result.meta.currentPage;
      _lastPage = result.meta.lastPage;
    } on ApiException catch (e) {
      if (request == _requestId) AppSnackbar.apiError(e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([loadCategories(), fetchProducts()]);
  }
}
