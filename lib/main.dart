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
  // print('🌍 Initializing French locale...');
  await initializeDateFormatting('fr_FR', null);
  // print('✅ French locale initialized');

  // Initialize services
  // print('🚀 Starting app initialization...');
  try {
    // print('🔥 Initializing Firebase...');
    await FirebaseService().initialize();
    // print('✅ Firebase initialized successfully');

    // print('📦 Initializing Hive...');
    await HiveService().initialize();
    // print('✅ Hive initialized successfully');

    // print('⚙️ Initializing Settings...');
    await SettingsService().initialize();
    // print('✅ Settings initialized successfully');

    // print('✅ All services initialized successfully');
  } catch (e, stackTrace) {
    // print('❌ Error initializing services: $e');
    // print('Stack trace: $stackTrace');
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
