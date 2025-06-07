import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runlog/bloc/bloc/running_map_bloc.dart';
import 'package:runlog/bloc/bloc/running_result_bloc.dart';
import 'package:runlog/bloc/event/running_map_event.dart';
import 'package:runlog/firebase_options.dart';
import 'package:runlog/repository/running_result_repository.dart';
import 'package:runlog/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseRepo = RunningResultRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RunningResultBloc(firebaseRepo)),
      ],

      child: MaterialApp.router(
        title: '마라톤 앱',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        
        debugShowCheckedModeBanner: false,
        routerConfig: goRouter,
      ),
    );
  }
}