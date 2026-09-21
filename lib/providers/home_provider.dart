import 'package:gts/models/response/health_response.dart';
import '../core/constants/endpoints.dart';
import '../core/network/api_helper.dart';
import '../models/base_class/base_notifier.dart';
import '../services/navigation_services.dart';

class HomeProvider extends BaseNotifier {
  final ApiHelper _apiHelper = ApiHelper();

  HealthResponse? _healthResponse;
  HealthResponse? get healthResponse => _healthResponse;
  HomeProvider() {
    Future.microtask(() => checkHealth());
  }

  Future<bool?> checkHealth() async {
    final response = await runSafely<HealthResponse>(
      () => _apiHelper.get<HealthResponse>(
        endpoint: ApiEndpoints.health,
        fromJson: (json) => HealthResponse.fromJson(json),
      ),
      onError: (error) {
        NavigationService.showError(title: "Error", message: error.message);
      },
      notify: true,
    );

    if (response?.success ?? false) {
      _healthResponse = response?.data;
      return true;
    }

    return false;
  }
}
