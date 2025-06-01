import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:runlog/design.dart';

class RunningMapView extends StatefulWidget {
  const RunningMapView({super.key});

  @override
  State<RunningMapView> createState() => _RunningMapViewState();
}

class _RunningMapViewState extends State<RunningMapView> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스 꺼져있을 때
      print('위치 서비스가 비활성화되어 있습니다.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 거부한 경우
        print('위치 권한이 거부되었습니다.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 영구적으로 거부한 경우: 설정으로 유도
      print('위치 권한이 영구적으로 거부되었습니다. 설정에서 허용해주세요.');
      await Geolocator.openAppSettings(); // 설정 앱으로 이동
      return;
    }

    // 위치 권한 OK → 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    // 위치 바뀔때마다 지도 중심을 내 위치로 이동 (줌 레벨 16: 길거리 수준)
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition!, 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('런닝')),
      body: Column(
        children: [
          Container(
            height: Design.screenHeight(context) * 0.4,
            color: Colors.grey.shade200,
            child:
                _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                      // 처음 위치를 나에게 중심으로 설정
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition!,
                        zoom: 16,
                      ),
                      // 지도 생성 시 컨트롤러 저장
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      // 위치 점, 오른쪽 아래 내 위치 버튼 표시
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                    ),
          ),

          // 지도 아래에 다른 위젯
          Expanded(child: Center(child: Text('이것 저것 넣을 수 있습니다 밑에'))),
        ],
      ),
    );
  }
}
