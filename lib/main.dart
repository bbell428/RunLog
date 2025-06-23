import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:runlog/repository/background/service_initializer.dart';
import 'package:runlog/bloc/bloc/auth_bloc.dart';
import 'package:runlog/bloc/bloc/running_result_bloc.dart';
import 'package:runlog/bloc/bloc/weather_bloc.dart';
import 'package:runlog/bloc/bloc/workout_result_bloc.dart';
import 'package:runlog/bloc/event/auth_event.dart';
import 'package:runlog/bloc/event/weather_event.dart';
import 'package:runlog/firebase_options.dart';
import 'package:runlog/repository/running_result_repository.dart';
import 'package:runlog/repository/weather_repository.dart';
import 'package:runlog/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('ko_KR', null);
  await dotenv.load(fileName: 'assets/.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseRepo = FirebaseRunningRepository();
    final WeatherRepository weatherRepository = WeatherRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => RunningResultBloc(firebaseRepo)),
        BlocProvider(create: (context) => AuthBloc()..add(AppStarted())),
        // BlocProvider(create: (context) => RunningMapBloc()..add(GetCurrentLocationRequested())),
        BlocProvider(create: (context) => WorkoutResultBloc(FirebaseRunningRepository())),
        BlocProvider(create: (context) => WeatherBloc(weatherRepository)..add(FetchWeather())),
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