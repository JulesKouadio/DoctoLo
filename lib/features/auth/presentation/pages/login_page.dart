import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/l10n/app_localizations.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    print('🔵 _handleLogin called');

    if (_formKey.currentState!.validate()) {
      print('✅ Form validation passed');
      print('📝 Login data:');
      print('  - Email: ${_emailController.text.trim()}');
      print('  - Password length: ${_passwordController.text.length}');
      print('🚀 Dispatching AuthSignInRequested event...');

      context.read<AuthBloc>().add(
        AuthSignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    } else {
      print('❌ Form validation failed');
    }
  }

  // Détermine le type d'appareil
  DeviceType _getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) {
      return DeviceType.desktop;
    } else if (width >= 600) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  // Retourne la largeur maximale du formulaire selon l'appareil
  double _getMaxFormWidth(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.desktop:
        return 450;
      case DeviceType.tablet:
        return 500;
      case DeviceType.mobile:
        return double.infinity;
    }
  }

  // Retourne le padding selon l'appareil
  double _getPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.desktop:
        return 48.0;
      case DeviceType.tablet:
        return 32.0;
      case DeviceType.mobile:
        return 24.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final deviceType = _getDeviceType(context);
    final maxFormWidth = _getMaxFormWidth(deviceType);
    final padding = _getPadding(deviceType);

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          print('🔄 LoginPage state changed: ${state.runtimeType}');

          if (state is AuthError) {
            print('❌ AuthError: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
              ),
            );
          } else if (state is AuthAuthenticated) {
            print('✅ AuthAuthenticated: Login successful');
            print('   User ID: ${state.user.id}');
            print('   Email: ${state.user.email}');
            // Navigation gérée dans main.dart
          } else if (state is AuthLoading) {
            print('⏳ AuthLoading: Login in progress...');
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxFormWidth),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo
                          Container(
                            height: deviceType == DeviceType.desktop
                                ? 120
                                : 100,
                            width: deviceType == DeviceType.desktop ? 120 : 100,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/doctolo_icon.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: deviceType == DeviceType.desktop ? 32 : 24,
                          ),

                          // Title
                          Text(
                            l10n.welcomeToDoctolo,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: deviceType == DeviceType.desktop
                                      ? 32
                                      : null,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.loginToContinue,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: deviceType == DeviceType.desktop
                                      ? 18
                                      : null,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: deviceType == DeviceType.desktop ? 56 : 48,
                          ),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            enableSuggestions: false,
                            style: TextStyle(
                              fontSize: deviceType == DeviceType.desktop
                                  ? 16
                                  : 14,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.email,
                              hintText: 'exemple@email.com',
                              prefixIcon: const Icon(CupertinoIcons.mail),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: deviceType == DeviceType.desktop
                                    ? 20
                                    : 16,
                                horizontal: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Veuillez entrer votre email';
                              }
                              if (!RegExp(
                                r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                              ).hasMatch(value.trim())) {
                                return 'Veuillez entrer un email valide';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: deviceType == DeviceType.desktop ? 20 : 16,
                          ),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            autocorrect: false,
                            enableSuggestions: false,
                            onFieldSubmitted: (_) => _handleLogin(),
                            style: TextStyle(
                              fontSize: deviceType == DeviceType.desktop
                                  ? 16
                                  : 14,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              hintText: '••••••••',
                              prefixIcon: const Icon(CupertinoIcons.lock),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: deviceType == DeviceType.desktop
                                    ? 20
                                    : 16,
                                horizontal: 16,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? CupertinoIcons.eye
                                      : CupertinoIcons.eye_slash,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre mot de passe';
                              }
                              if (value.length < 6) {
                                return 'Le mot de passe doit contenir au moins 6 caractères';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                  ),
                                  Text(
                                    l10n.rememberMe,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize:
                                              deviceType == DeviceType.desktop
                                              ? 15
                                              : null,
                                        ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  l10n.forgotPassword,
                                  style: TextStyle(
                                    fontSize: deviceType == DeviceType.desktop
                                        ? 15
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: deviceType == DeviceType.desktop ? 32 : 24,
                          ),

                          // Login Button
                          ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: deviceType == DeviceType.desktop
                                    ? 18
                                    : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: deviceType == DeviceType.desktop
                                        ? 22
                                        : 20,
                                    width: deviceType == DeviceType.desktop
                                        ? 22
                                        : 20,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    l10n.login,
                                    style: TextStyle(
                                      fontSize: deviceType == DeviceType.desktop
                                          ? 17
                                          : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          SizedBox(
                            height: deviceType == DeviceType.desktop ? 20 : 16,
                          ),

                          // Divider
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'OU',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize:
                                            deviceType == DeviceType.desktop
                                            ? 15
                                            : null,
                                      ),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          SizedBox(
                            height: deviceType == DeviceType.desktop ? 20 : 16,
                          ),

                          // Register Button
                          OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterPage(),
                                      ),
                                    );
                                  },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: deviceType == DeviceType.desktop
                                    ? 18
                                    : 16,
                              ),
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              l10n.createAccount,
                              style: TextStyle(
                                fontSize: deviceType == DeviceType.desktop
                                    ? 17
                                    : 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum DeviceType { mobile, tablet, desktop }
