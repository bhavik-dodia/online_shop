import 'package:http/http.dart' as http;

/// Manages api calls.
class APIService {
  static const _baseUrl = 'dae0de8e-ab3b-4aca-9dfc-8e3154d1f2d5.mock.pstmn.io';

  /// Generates a request for fetching products.
  static makeGetRequest() {
    return http
        .get(Uri.https(_baseUrl, 'v1/products_list'))
        .onError((error, stackTrace) => throw error);
  }

  /// Generates a request for placing an order.
  static makePostRequest(Map<String, dynamic> data) {
    return http
        .post(Uri.https(_baseUrl, 'v1/place_order', data))
        .onError((error, stackTrace) => throw error);
  }
}
