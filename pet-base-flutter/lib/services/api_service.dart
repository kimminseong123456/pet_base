import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/dashboard_model.dart';
import '../models/device.dart';
import '../models/health_record.dart';
import '../models/measurement_window.dart';

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<DashboardModel> fetchDashboard({int dogId = ApiConfig.dogId}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/dashboard/$dogId');
    final response = await _client.get(uri).timeout(ApiConfig.requestTimeout);
    if (response.statusCode != 200) {
      throw ApiException('\uB300\uC2DC\uBCF4\uB4DC \uC870\uD68C \uC2E4\uD328: HTTP ${response.statusCode}');
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (body is! Map<String, dynamic>) {
      throw ApiException('\uB300\uC2DC\uBCF4\uB4DC \uC751\uB2F5 \uD615\uC2DD\uC774 \uC62C\uBC14\uB974\uC9C0 \uC54A\uC2B5\uB2C8\uB2E4.');
    }
    return DashboardModel.fromJson(body);
  }

  Future<List<MeasurementWindow>> fetchMeasurementWindows({
    int dogId = ApiConfig.dogId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/measurements/windows/$dogId');
    final response = await _client.get(uri).timeout(ApiConfig.requestTimeout);
    if (response.statusCode != 200) {
      throw ApiException('15\uBD84 \uC694\uC57D \uAE30\uB85D \uC870\uD68C \uC2E4\uD328: HTTP ${response.statusCode}');
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    final List<dynamic> rawList;
    if (body is List) {
      rawList = body;
    } else if (body is Map<String, dynamic>) {
      final data = body['items'] ?? body['windows'] ?? body['data'] ?? body['results'];
      rawList = data is List ? data : const [];
    } else {
      rawList = const [];
    }
    return rawList.whereType<Map<String, dynamic>>().map(MeasurementWindow.fromJson).toList();
  }

  Future<HealthRecord> fetchHealthRecord(int recordId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/health-records/$recordId');
    final response = await _client.get(uri).timeout(ApiConfig.requestTimeout);
    if (response.statusCode != 200) {
      throw ApiException('\uC0C1\uD0DC \uC0C1\uC138 \uC870\uD68C \uC2E4\uD328: HTTP ${response.statusCode}');
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (body is! Map<String, dynamic>) {
      throw ApiException('\uC0C1\uD0DC \uC0C1\uC138 \uC751\uB2F5 \uD615\uC2DD\uC774 \uC62C\uBC14\uB974\uC9C0 \uC54A\uC2B5\uB2C8\uB2E4.');
    }
    return HealthRecord.fromJson(body);
  }

  Future<PetDevice> fetchDogDevice({int dogId = ApiConfig.dogId}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/dogs/$dogId/device');
      final response = await _client.get(uri).timeout(ApiConfig.requestTimeout);
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body is Map<String, dynamic>) return PetDevice.fromJson(body);
      }
    } catch (_) {}
    final dash = await fetchDashboard(dogId: dogId);
    return PetDevice(
      deviceId: dash.deviceId ?? 'dog-001',
      model: 'PET BASE Harness',
      firmwareVersion: 'sim-0.1.0',
      batteryPct: dash.batteryPct,
      lastSeenAt: dash.measuredAt,
      isActive: true,
      sqiPpg: dash.sqiPpg,
      sqiRr: dash.sqiRr,
      sqiTemp: dash.sqiTemp,
    );
  }

  void close() => _client.close();
}
