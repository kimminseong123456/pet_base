import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/pet_ui.dart';
import 'wear_guide_screen.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});
  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  final ApiService _api = ApiService();
  late Future<PetDevice> _future;
  @override
  void initState() { super.initState(); _future = _api.fetchDogDevice(); }
  @override
  void dispose() { _api.close(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PetDevice>(
      future: _future,
      builder: (context, snapshot) {
        final device = snapshot.data ?? PetDevice.demo();
        return ScreenScaffold(title: '기기 관리', subtitle: '연결된 웨어러블 기기 상태를 확인할 수 있어요.', showLogo: false, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SoftCard(color: AppColors.mintLight, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.watch_rounded, color: AppColors.brand, size: 42), const SizedBox(width: 12), Expanded(child: Text(device.model, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))), const ActionChipButton(label: '연결됨', icon: Icons.link_rounded)]),
            const SizedBox(height: 16),
            InfoRow(icon: Icons.qr_code_rounded, title: 'device_id', value: device.deviceId),
            InfoRow(icon: Icons.schedule_rounded, title: '마지막 수신', value: device.lastSeenLabel),
            InfoRow(icon: Icons.battery_5_bar_rounded, title: '배터리', value: device.batteryPct == null ? '-' : '${device.batteryPct}%'),
            InfoRow(icon: Icons.memory_rounded, title: '펌웨어', value: device.firmwareVersion),
          ])),
          const SectionTitle('센서 상태'),
          SoftCard(child: Column(children: [
            InfoRow(icon: Icons.favorite_rounded, title: '심박 센서', value: _ok(device.sqiPpg, .80)),
            InfoRow(icon: Icons.air_rounded, title: '호흡/움직임 센서', value: _ok(device.sqiRr, .70)),
            InfoRow(icon: Icons.thermostat_rounded, title: '체온 추정 센서', value: _ok(device.sqiTemp, .60)),
          ])),
          const SectionTitle('기기 정보'),
          SoftCard(child: Column(children: const [
            InfoRow(icon: Icons.wifi_rounded, title: '통신 방식', value: 'Wi‑Fi + MQTT'),
            InfoRow(icon: Icons.inventory_2_rounded, title: '모델', value: 'PET BASE v1'),
            InfoRow(icon: Icons.sensors_rounded, title: '측정 상태', value: '양호'),
          ])),
          const SectionTitle('작업'),
          Wrap(spacing: 10, runSpacing: 10, children: [
            const ActionChipButton(label: '연결 테스트', icon: Icons.network_check_rounded),
            const ActionChipButton(label: '재연결', icon: Icons.refresh_rounded),
            ActionChipButton(label: '착용 가이드 보기', icon: Icons.checkroom_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WearGuideScreen()))),
          ]),
        ]));
      },
    );
  }

  String _ok(double? value, double th) => (value ?? 1) >= th ? '양호' : '점검';
}
