import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:runlog/design.dart';
import 'package:url_launcher/url_launcher.dart';

class RunningMapView extends StatefulWidget {
  const RunningMapView({super.key});

  @override
  State<RunningMapView> createState() => _RunningMapViewState();
}

class _RunningMapViewState extends State<RunningMapView> {
  LatLng? _currentPosition; // 현재 위치를 저장할 변수
  final mapController = MapController(); // 지도 제어 컨트롤러 (내 위치 버튼을 위함)

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // 현재 위치를 얻는 함수
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('위치 서비스가 비활성화되어 있습니다.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('위치 권한이 거부되었습니다.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('위치 권한이 영구적으로 거부되었습니다. 설정에서 허용해주세요.');
      await Geolocator.openAppSettings();
      return;
    }

    // 권한이 있는 경우 → 현재 위치 얻기
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 위치 정보 저장하고 UI 다시 그림
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('런닝')),
      // 아직 위치 정보를 못 받았을 경우 → 로딩 표시
      body: Column(
        children: [
          Container(
            height: Design.screenHeight(context) * 0.5,
            color: Colors.grey.shade200,
            child:
                _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : Stack(
                      children: [
                        FlutterMap(
                          mapController: mapController,
                          options: MapOptions(
                            initialCenter: _currentPosition!,
                            initialZoom: 16.0, // 초기 확대 수준
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.runlog',
                            ),
                            // 마커 레이어: 지도 위에 핀 표시
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _currentPosition!,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                            // Attribution 위젯: 오픈스트리트맵 라이선스 출처 표시
                            RichAttributionWidget(
                              attributions: [
                                TextSourceAttribution(
                                  'OpenStreetMap contributors',
                                  onTap:
                                      () => launchUrl(
                                        Uri.parse(
                                          'https://openstreetmap.org/copyright',
                                        ),
                                      ), // (external)
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          top: 16,
                          right: 10,
                          child: FloatingActionButton(
                            mini: true,
                            onPressed: () {
                              if (_currentPosition != null) {
                                mapController.move(_currentPosition ?? LatLng(0, 0), 16.0);
                              }
                            },
                            child: const Icon(Icons.my_location),
                          ),
                        ),
                      ],
                    ),
          ),
          Expanded(child: Center(child: Text('이것 저것 넣을 수 있습니다 밑에'))),
        ],
      ),
    );
  }
}
