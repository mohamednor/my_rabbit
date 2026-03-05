import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:my_rabbit/services/ad_service.dart';
import 'package:my_rabbit/services/game_state_service.dart';
import 'package:my_rabbit/services/audio_service.dart';
import 'package:my_rabbit/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await MobileAds.instance.initialize();
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  runApp(const MyRabbitApp());
}

class MyRabbitApp extends StatelessWidget {
  const MyRabbitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameStateService()..loadState()),
        Provider(create: (_) => AdService()..initialize()),
        Provider(create: (_) => AudioService()),
      ],
      child: MaterialApp(
        title: 'My Rabbit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.pink,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
