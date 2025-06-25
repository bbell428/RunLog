// 📁 view/workout_view.dart (평균 페이스 및 날짜 표시 추가)

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runlog/bloc/bloc/auth_bloc.dart';
import 'package:runlog/bloc/state/auth_state.dart';
import 'package:runlog/bloc/bloc/workout_result_bloc.dart';
import 'package:runlog/bloc/event/workout_result_event.dart';
import 'package:runlog/bloc/state/workout_result_state.dart';

class WorkoutResultView extends StatefulWidget {
  const WorkoutResultView({super.key});

  @override
  State<WorkoutResultView> createState() => WorkoutResultViewState();
}

class WorkoutResultViewState extends State<WorkoutResultView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<WorkoutResultBloc>().add(
        LoadWorkoutResults(authState.user.uid),
      );
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(
    DateTime day,
    Map<DateTime, List<Map<String, dynamic>>> data,
  ) {
    final normalized = DateTime(day.year, day.month, day.day);
    return data[normalized] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기록')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<WorkoutResultBloc, WorkoutResultState>(
          builder: (context, state) {
            if (state is WorkoutResultLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is WorkoutResultError) {
              return Center(child: Text(state.message));
            } else if (state is WorkoutResultLoaded) {
              final resultMap = state.results;
              final selectedEvents =
                  _selectedDay != null
                      ? _getEventsForDay(_selectedDay!, resultMap)
                      : [];

              return Column(
                children: [
                  TableCalendar(
                    locale: 'ko-KR',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: '월간',
                    },
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: (day) => _getEventsForDay(day, resultMap),
                    rowHeight: 38, // 달력 크기
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isNotEmpty) {
                          return Positioned(
                            bottom: -1,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  Divider(),
                  if (selectedEvents.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: selectedEvents.length,
                        itemBuilder: (context, index) {
                          final record = selectedEvents[index];
                          final duration = Duration(
                            seconds: record['duration'],
                          );
                          final distance = record['distance'];
                          final formattedPace = record['formattedPace'];
                          final recordTime = record['recordTime'];
                          return Dismissible(
                            key: ValueKey(record['recordTime']),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              color: Colors.red,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('삭제 확인'),
                                      content: const Text('이 기록을 삭제하시겠습니까?'),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(false),
                                          child: const Text('취소'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
                                          child: const Text('삭제'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            onDismissed: (_) {
                              final authState = context.read<AuthBloc>().state;
                              if (authState is Authenticated) {
                                final docId =
                                    "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}_${record['recordTime'].toString().substring(0, 5)}";

                                context.read<WorkoutResultBloc>().add(
                                  DeleteWorkoutResult(
                                    uid: authState.user.uid,
                                    docId: docId,
                                  ),
                                );
                              }
                            },
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(recordTime),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (distance >= 1000)
                                      Text(
                                        '거리: ${(distance / 1000).toStringAsFixed(2)}km',
                                      )
                                    else
                                      Text(
                                        '거리: ${distance.toStringAsFixed(0)}m',
                                      ),
                                    Text(
                                      '시간: ${duration.inMinutes}분 ${duration.inSeconds % 60}초',
                                    ),
                                    Text('평균 페이스: $formattedPace'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
