import 'package:DoctoLo/features/patient/presentation/pages/patient_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import 'professional_verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = AppConstants.rolePatient;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    print('🔵 _handleRegister called');

    if (_formKey.currentState!.validate()) {
      print('✅ Form validation passed');

      if (!_acceptTerms) {
        print('❌ Terms not accepted');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.acceptTerms),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      print('📝 Registration data:');
      print('  - Email: ${_emailController.text.trim()}');
      print('  - First Name: ${_firstNameController.text.trim()}');
      print('  - Last Name: ${_lastNameController.text.trim()}');
      print('  - Role: $_selectedRole');
      print(
        '  - Phone: ${_phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : "null"}',
      );
      print('🚀 Dispatching AuthSignUpRequested event...');

      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          role: _selectedRole,
          phoneNumber: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
        ),
      );
    } else {
      print('❌ Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          print('🔄 RegisterPage state changed: ${state.runtimeType}');

          if (state is AuthError) {
            print('❌ AuthError: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AuthAuthenticated) {
            print('✅ AuthAuthenticated: User registered successfully');
            print('   User ID: ${state.user.id}');
            print('   Email: ${state.user.email}');
            print('   Role: ${state.user.role}');

            // Si c'est un professionnel de santé, rediriger vers la page de vérification
            if (state.user.role == AppConstants.roleDoctor) {
              print(
                '🩺 Professional user detected, navigating to verification page',
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfessionalVerificationPage(userId: state.user.id),
                ),
              );
            } else {
              // Pour les patients, naviguer vers la page d'accueil
              print('👤 Patient user detected, navigating to home page');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatientHomePage(),
                ),
              );
            }
          } else if (state is AuthLoading) {
            print('⏳ AuthLoading: Registration in progress...');
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final l10n = AppLocalizations.of(context)!;
          final deviceType = context.deviceType;
          final adaptive = AdaptiveValues(context);

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  adaptive.spacing(mobile: 24, tablet: 32, desktop: 48),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: adaptive.maxFormWidth,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          Text(
                            l10n.createAccount,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: deviceType == DeviceType.desktop
                                      ? 32
                                      : null,
                                ),
                          ),
                          SizedBox(
                            height: adaptive.spacing(mobile: 8, desktop: 12),
                          ),
                          Text(
                            l10n.joinDoctolo,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: deviceType == DeviceType.desktop
                                      ? 18
                                      : null,
                                ),
                          ),
                          SizedBox(
                            height: adaptive.spacing(
                              mobile: 32,
                              tablet: 40,
                              desktop: 48,
                            ),
                          ),

                          // Role Selection
                          Text(
                            l10n.iAmA,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: deviceType == DeviceType.desktop
                                      ? 18
                                      : null,
                                ),
                          ),
                          SizedBox(
                            height: adaptive.spacing(mobile: 12, desktop: 16),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _RoleCard(
                                  title: l10n.patient,
                                  icon: CupertinoIcons.person,
                                  isSelected:
                                      _selectedRole == AppConstants.rolePatient,
                                  onTap: () {
                                    setState(() {
                                      _selectedRole = AppConstants.rolePatient;
                                    });
                                  },
                                  deviceType: deviceType,
                                ),
                              ),
                              SizedBox(
                                width: adaptive.spacing(
                                  mobile: 12,
                                  desktop: 16,
                                ),
                              ),
                              Expanded(
                                child: _RoleCard(
                                  title: l10n.doctor,
                                  icon: CupertinoIcons.bag_badge_plus,
                                  isSelected:
                                      _selectedRole == AppConstants.roleDoctor,
                                  onTap: () {
                                    setState(() {
                                      _selectedRole = AppConstants.roleDoctor;
                                    });
                                  },
                                  deviceType: deviceType,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: adaptive.spacing(mobile: 24, desktop: 32),
                          ),

                          // First Name
                          TextFormField(
                            controller: _firstNameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            style: TextStyle(
                              fontSize: deviceType == DeviceType.desktop
                                  ? 16
                                  : 14,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.firstName,
                              prefixIcon: const Icon(CupertinoIcons.person),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: deviceType == DeviceType.desktop
                                    ? 20
                                    : 16,
                                horizontal: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.firstName;
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: adaptive.spacing(mobile: 16, desktop: 20),
                          ),

                          // Last Name
                          TextFormField(
                            controller: _lastNameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            style: TextStyle(
                              fontSize: deviceType == DeviceType.desktop
                                  ? 16
                                  : 14,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.lastName,
                              prefixIcon: const Icon(CupertinoIcons.person),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: deviceType == DeviceType.desktop
                                    ? 20
                                    : 16,
                                horizontal: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.lastName;
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: adaptive.spacing(mobile: 16, desktop: 20),
                          ),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
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
                              if (value == null || value.isEmpty) {
                                return l10n.email;
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return l10n.email;
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: adaptive.spacing(mobile: 16, desktop: 20),
                          ),

                          // Phone
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            style: TextStyle(
                              fontSize: deviceType == DeviceType.desktop
                                  ? 16
                                  : 14,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.phoneNumber,
                              hintText: '+33 6 12 34 56 78',
                              prefixIcon: const Icon(CupertinoIcons.phone),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: deviceType == DeviceType.desktop
                                    ? 20
                                    : 16,
                                horizontal: 16,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: adaptive.spacing(mobile: 16, desktop: 20),
                          ),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
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
                                return l10n.password;
                              }
                              if (value.length < 6) {
                                return l10n.password;
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: adaptive.spacing(mobile: 16, desktop: 20),
                          ),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleRegister(),
                            style: TextStyle(
                              fontSize: deviceType == DeviceType.desktop
                                  ? 16
                                  : 14,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.confirmPassword,
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
                                  _obscureConfirmPassword
                                      ? CupertinoIcons.eye
                                      : CupertinoIcons.eye_slash,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.confirmPassword;
                              }
                              if (value != _passwordController.text) {
                                return l10n.confirmPassword;
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: adaptive.spacing(mobile: 16, desktop: 20),
                          ),

                          // Terms and Conditions
                          Row(
                            children: [
                              Checkbox(
                                value: _acceptTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptTerms = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _acceptTerms = !_acceptTerms;
                                    });
                                  },
                                  child: Text(
                                    l10n.acceptTerms,
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
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: adaptive.spacing(mobile: 24, desktop: 32),
                          ),

                          // Register Button
                          ElevatedButton(
                            onPressed: isLoading ? null : _handleRegister,
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
                                    l10n.register,
                                    style: TextStyle(
                                      fontSize: deviceType == DeviceType.desktop
                                          ? 17
                                          : 16,
                                      fontWeight: FontWeight.w600,
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

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final DeviceType deviceType;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: deviceType == DeviceType.desktop ? 24 : 20,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey[50],
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: deviceType == DeviceType.desktop ? 40 : 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(height: deviceType == DeviceType.desktop ? 12 : 8),
            Text(
              title,
              style: TextStyle(
                fontSize: deviceType == DeviceType.desktop ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
