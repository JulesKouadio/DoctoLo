import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/services/firebase_service.dart';
import 'core/services/hive_service.dart';
import 'core/services/settings_service.dart';
import 'core/l10n/app_localizations.dart';
import 'core/utils/size_config.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/patient/presentation/pages/patient_home_page.dart';
import 'features/doctor/presentation/pages/doctor_home_page.dart';
import 'data/models/user_model.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize date formatting for French locale
  print('🌍 Initializing French locale...');
  await initializeDateFormatting('fr_FR', null);
  print('✅ French locale initialized');

  // Initialize services
  print('🚀 Starting app initialization...');
  try {
    print('🔥 Initializing Firebase...');
    await FirebaseService().initialize();
    print('✅ Firebase initialized successfully');

    print('📦 Initializing Hive...');
    await HiveService().initialize();
    print('✅ Hive initialized successfully');

    print('⚙️ Initializing Settings...');
    await SettingsService().initialize();
    print('✅ Settings initialized successfully');

    print('✅ All services initialized successfully');
  } catch (e, stackTrace) {
    print('❌ Error initializing services: $e');
    print('Stack trace: $stackTrace');
  }

  runApp(const DoctolioApp());
}

class DoctolioApp extends StatelessWidget {
  const DoctolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = SettingsService();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc()..add(AuthCheckRequested()),
        ),
      ],
      child: ValueListenableBuilder<String>(
        valueListenable: settingsService.languageNotifier,
        builder: (context, languageCode, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: ThemeMode.light,
            // Localizations
            locale: Locale(languageCode),
            supportedLocales: const [
              Locale('fr'),
              Locale('en'),
              Locale('es'),
              Locale('ar'),
              Locale('de'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize SizeConfig once when dependencies are available
    SizeConfig().init(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthAuthenticated) {
          return _buildHomePage(state.user);
        }

        return const LoginPage();
      },
    );
  }

  Widget _buildHomePage(UserModel user) {
    if (user.role == AppConstants.roleDoctor) {
      return const DoctorHomePage();
    } else {
      return const PatientHomePage();
    }
  }
}

class _MyHomePageState extends State<StatefulWidget> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('SALUT'),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }
}
