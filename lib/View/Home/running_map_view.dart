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

  // 지도 리셋 방지(자동 이동 해제) - 러닝 시작 시, 지도 건들면 리셋
  bool shouldAutoCenter = true;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          showExitDialog(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('러닝')),
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: BlocConsumer<RunningMapBloc, RunningMapState>(
                listener: (context, state) {
                  if (state is RunningMapLoaded ||
                      state is RunningInProgress && shouldAutoCenter) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final pos =
                          (state is RunningMapLoaded)
                              ? state.currentPosition
                              : (state as RunningInProgress).currentPosition;
                      mapController.move(pos, 18.0);
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
                            initialZoom: 18.0,
                            onPositionChanged: (position, bool hasGesture) {
                              if (hasGesture) {
                                setState(() {
                                  shouldAutoCenter = false;
                                });
                              }
                            },
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
                            onPressed: () {
                              mapController.move(pos, 18.0);
                              shouldAutoCenter = true;
                            },
                            child: const Icon(Icons.my_location),
                          ),
                        ),
                        if (state is RunningInProgress)
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "거리: ${state.distance.toStringAsFixed(1)} m",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "시간: ${state.duration.inMinutes}분 ${state.duration.inSeconds % 60}초",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // 러닝 시작 및 종료 버튼
                        if (state is RunningMapLoaded ||
                            state is RunningInProgress)
                          Positioned(
                            bottom: 24,
                            left: 24,
                            right: 24,
                            child: Center(
                              child: BlocBuilder<
                                RunningMapBloc,
                                RunningMapState
                              >(
                                builder: (context, state) {
                                  final isRunning = state is RunningInProgress;

                                  return ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                      backgroundColor:
                                          isRunning ? Colors.red : Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 6,
                                    ),
                                    icon: Icon(
                                      isRunning ? Icons.stop : Icons.play_arrow,
                                    ),
                                    label: Text(
                                      isRunning ? '러닝 종료' : '러닝 시작',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    onPressed: () async {
                                      if (!isRunning) {
                                        context.read<RunningMapBloc>().add(
                                          StartRunning(),
                                        );
                                      } else {
                                        final shouldStop =
                                            await showConfirmDialog(
                                              context: context,
                                              title: '러닝 종료',
                                              content: '정말 종료하시겠습니까?',
                                              cancelText: '취소',
                                              confirmText: '종료',
                                            );
                                        if (shouldStop) {
                                          final runningState =
                                              context
                                                  .read<RunningMapBloc>()
                                                  .state;
                                          if (runningState
                                              is RunningInProgress) {
                                            context.read<RunningMapBloc>().add(
                                              StopRunning(),
                                            );

                                            await Future.delayed(
                                              const Duration(milliseconds: 100),
                                            );

                                            context.push(
                                              '/runningResult',
                                              extra: {
                                                'distance':
                                                    runningState.distance,
                                                'duration':
                                                    runningState.duration,
                                              },
                                            );
                                          }
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
