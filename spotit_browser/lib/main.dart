import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'services/browser_backend.dart';
import 'services/audio_player_service.dart';
import 'blocs/search_bloc.dart';
import 'blocs/player_bloc.dart';
import 'ui/home_screen.dart';
import 'ui/player_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late BrowserBackend browserBackend;
  late AudioPlayerService audioPlayerService;

  @override
  void initState() {
    super.initState();
    browserBackend = BrowserBackend();
    audioPlayerService = AudioPlayerService();
    
    // Initialize browser in background
    browserBackend.init().then((_) {
      print('Browser initialized successfully');
    }).catchError((e) {
      print('Failed to initialize browser: $e');
    });
  }

  @override
  void dispose() {
    browserBackend.close();
    audioPlayerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SearchBloc(browserBackend),
        ),
        BlocProvider(
          create: (context) => PlayerBloc(browserBackend, audioPlayerService),
        ),
      ],
      child: MaterialApp(
        title: 'Spotit Browser',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.green,
          scaffoldBackgroundColor: Colors.black,
        ),
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const HomeScreen(),
      bottomNavigationBar: const PlayerWidget(),
    );
  }
}
