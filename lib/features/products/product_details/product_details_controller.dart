import 'package:mystore/core/network/api_exception.dart';
import 'package:get/get.dart';
import 'product_details_model.dart';
import 'product_details_service.dart';

class ProductDetailsController extends GetxController {
  final int productId;

  ProductDetailsController({required this.productId, ProductModel? initial}) {
    product.value = initial;
  }

  final ProductDetailsService _detailsService = ProductDetailsService();

  var product = Rxn<ProductModel>();
  var isLoading = false.obs;
  var errorMessage = RxnString();

  var notFound = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProduct();
  }

  Future<void> fetchProduct() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      product.value = await _detailsService.getProduct(productId);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        notFound.value = true;
      } else if (product.value == null) {
        errorMessage.value = e.displayMessage;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
