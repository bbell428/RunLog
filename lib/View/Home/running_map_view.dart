import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:runlog/bloc/bloc/running_map_bloc.dart';
import 'package:runlog/bloc/event/running_map_event.dart';
import 'package:runlog/bloc/state/running_map_state.dart';
import 'package:runlog/confirm_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class RunningMapView extends StatefulWidget {
  const RunningMapView({super.key});

  @override
  State<RunningMapView> createState() => _RunningMapViewState();
}

class _RunningMapViewState extends State<RunningMapView> {
  final mapController = MapController();

  double distance2 = 0.0; // 거리 할당
  late Duration duration2; // 시간 할당

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('런닝')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: BlocConsumer<RunningMapBloc, RunningMapState>(
              listener: (context, state) {
                if (state is RunningMapLoaded || state is RunningInProgress) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final pos =
                        (state is RunningMapLoaded)
                            ? state.currentPosition
                            : (state as RunningInProgress).currentPosition;
                    mapController.move(pos, 16.0);
                  });
                }
              },
              builder: (context, state) {
                if (state is RunningMapLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is RunningMapError) {
                  return Center(child: Text(state.message));
                } else if (state is RunningMapLoaded ||
                    state is RunningInProgress) {
                  final pos =
                      (state is RunningMapLoaded)
                          ? state.currentPosition
                          : (state as RunningInProgress).currentPosition;
                  final path = (state is RunningInProgress) ? state.path : [];

                  return Stack(
                    children: [
                      FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter: pos,
                          initialZoom: 16.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.runlog',
                          ),
                          if (path.isNotEmpty)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: path.whereType<LatLng>().toList(),
                                  strokeWidth: 4.0,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: pos,
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
                          onPressed: () => mapController.move(pos, 16.0),
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                      if (state is RunningInProgress)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "거리: ${state.distance.toStringAsFixed(1)} m",
                              ),
                              Text(
                                "시간: ${state.duration.inMinutes}분 ${state.duration.inSeconds % 60}초",
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }

                return const SizedBox();
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: BlocBuilder<RunningMapBloc, RunningMapState>(
              builder: (context, state) {
                if (state is! RunningMapLoaded && state is! RunningInProgress) {
                  return const SizedBox();
                }

                final bloc = context.read<RunningMapBloc>();
                final current =
                    (state is RunningMapLoaded)
                        ? state.currentPosition
                        : (state as RunningInProgress).currentPosition;
                const double delta = 0.0001;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("방향 버튼으로 위치 이동"),
                    const SizedBox(height: 16),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<RunningMapBloc, RunningMapState>(
              builder: (context, state) {
                final isRunning = state is RunningInProgress;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!isRunning)
                      ElevatedButton(
                        onPressed: () {
                          context.read<RunningMapBloc>().add(StartRunning());
                        },
                        child: const Text("런닝 시작"),
                      ),
                    if (isRunning)
                      ElevatedButton(
                        onPressed: () async {
                          final shouldStop = showConfirmDialog(
                            context: context,
                            title: '런닝 종료',
                            content: '정말 종료하시겠습니까?',
                            cancelText: '취소',
                            confirmText: '종료',
                          );

                          if (shouldStop == true) {
                            final runningState =
                                context.read<RunningMapBloc>().state;
                            if (runningState is RunningInProgress) {
                              context.push(
                                '/runningResult',
                                extra: {
                                  'distance': runningState.distance,
                                  'duration': runningState.duration,
                                },
                              );
                            }
                            context.read<RunningMapBloc>().add(StopRunning());
                          }
                        },
                        child: const Text("런닝 종료"),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
