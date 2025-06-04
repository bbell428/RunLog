import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:runlog/bloc/event/running_map_event.dart';
import 'package:runlog/bloc/running_map_bloc.dart';
import 'package:runlog/bloc/state/running_map_state.dart';
import 'package:runlog/design.dart';
import 'package:url_launcher/url_launcher.dart';

class RunningMapView extends StatefulWidget {
  const RunningMapView({super.key});

  @override
  State<RunningMapView> createState() => _RunningMapViewState();
}

class _RunningMapViewState extends State<RunningMapView> {
  final mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RunningMapBloc()..add(GetCurrentLocationRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('런닝')),
        body: Column(
          children: [
            Container(
              height: Design.screenHeight(context) * 0.5,
              child: BlocListener<RunningMapBloc, RunningMapState>(
                listener: (context, state) {
                  if (state is RunningMapLoaded) {
                    // 화면이 다 그려진 후에 실행
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      mapController.move(state.currentPosition, 16.0);
                    });
                  }
                },
                child: BlocBuilder<RunningMapBloc, RunningMapState>(
                  builder: (context, state) {
                    if (state is RunningMapLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is RunningMapError) {
                      return Center(child: Text(state.message));
                    } else if (state is RunningMapLoaded) {
                      return Stack(
                        children: [
                          FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              initialCenter: state.currentPosition,
                              initialZoom: 16.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.runlog',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: state.currentPosition,
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
                              RichAttributionWidget(
                                attributions: [
                                  TextSourceAttribution(
                                    'OpenStreetMap contributors',
                                    onTap:
                                        () => launchUrl(
                                          Uri.parse(
                                            'https://openstreetmap.org/copyright',
                                          ),
                                        ),
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
                                mapController.move(state.currentPosition, 16.0);
                              },
                              child: const Icon(Icons.my_location),
                            ),
                          ),
                        ],
                      );
                    }

                    return const SizedBox(); // 초기 상태 등
                  },
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<RunningMapBloc, RunningMapState>(
                builder: (context, state) {
                  if (state is! RunningMapLoaded) return const SizedBox();

                  final bloc = context.read<RunningMapBloc>();
                  final LatLng current = state.currentPosition;
                  const double delta = 0.0001; // 약 10~11m 이동

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("방향 버튼으로 위치 이동"),
                      const SizedBox(height: 16),
                      // 위쪽 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_upward),
                            label: const Text("위로"),
                            onPressed: () {
                              bloc.add(
                                RunningLocationChanged(
                                  LatLng(
                                    current.latitude + delta,
                                    current.longitude,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 좌/우 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text("왼쪽"),
                            onPressed: () {
                              bloc.add(
                                RunningLocationChanged(
                                  LatLng(
                                    current.latitude,
                                    current.longitude - delta,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text("오른쪽"),
                            onPressed: () {
                              bloc.add(
                                RunningLocationChanged(
                                  LatLng(
                                    current.latitude,
                                    current.longitude + delta,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 아래쪽 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_downward),
                            label: const Text("아래로"),
                            onPressed: () {
                              bloc.add(
                                RunningLocationChanged(
                                  LatLng(
                                    current.latitude - delta,
                                    current.longitude,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
