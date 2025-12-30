import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/utils/responsive.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../data/models/user_model.dart';
import '../../../../shared/widgets/quick_search_card.dart';
import '../../../../shared/widgets/appointment_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../search/presentation/pages/search_professional_page.dart';
import '../../../appointment/presentation/pages/appointments_list_page.dart';
import '../../../settings/presentation/pages/account_settings_page.dart';
import '../../../pharmacy/presentation/pages/on_duty_pharmacies_page.dart';
import '../../../messages/presentation/pages/conversations_list_page.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomePage(),
    const _AppointmentsPage(),
    const _MedicalRecordsPage(),
    const _MessagesPage(),
    const _ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Sur desktop, utiliser une navigation latérale au lieu de la barre du bas
    if (context.isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _buildNavigationRail(context, l10n),
            const VerticalDivider(width: 1),
            Expanded(child: _pages[_currentIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.house),
            activeIcon: const Icon(CupertinoIcons.house_fill),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.calendar),
            activeIcon: const Icon(CupertinoIcons.calendar),
            label: l10n.appointments,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.folder_fill),
            activeIcon: const Icon(CupertinoIcons.folder_fill),
            label: l10n.medicalRecords,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.chat_bubble_fill),
            activeIcon: const Icon(CupertinoIcons.chat_bubble_fill),
            label: l10n.messages,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.person),
            activeIcon: const Icon(CupertinoIcons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context, AppLocalizations l10n) {
    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      labelType: NavigationRailLabelType.all,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primary.withOpacity(0.15),
      selectedIconTheme: const IconThemeData(color: AppColors.primary),
      unselectedIconTheme: IconThemeData(color: Colors.grey[600]),
      selectedLabelTextStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: Colors.grey[600],
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(CupertinoIcons.house),
          selectedIcon: const Icon(CupertinoIcons.house_fill),
          label: Text(l10n.home),
        ),
        NavigationRailDestination(
          icon: const Icon(CupertinoIcons.calendar),
          selectedIcon: const Icon(CupertinoIcons.calendar),
          label: Text(l10n.appointments),
        ),
        NavigationRailDestination(
          icon: const Icon(CupertinoIcons.folder_fill),
          selectedIcon: const Icon(CupertinoIcons.folder_fill),
          label: Text(l10n.medicalRecords),
        ),
        NavigationRailDestination(
          icon: const Icon(CupertinoIcons.chat_bubble_fill),
          selectedIcon: const Icon(CupertinoIcons.chat_bubble_fill),
          label: Text(l10n.messages),
        ),
        NavigationRailDestination(
          icon: const Icon(CupertinoIcons.person),
          selectedIcon: const Icon(CupertinoIcons.person),
          label: Text(l10n.profile),
        ),
      ],
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserModel? user;
        if (state is AuthAuthenticated) {
          user = state.user;
        }

        final responsive = ResponsiveSize(context);

        return ResponsiveLayout(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.white,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour 👋',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      user?.fullName ?? 'Utilisateur',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.bell),
                    onPressed: () {},
                  ),
                ],
              ),

              SliverPadding(
                padding: responsive.padding(
                  mobile: EdgeInsets.all(getProportionateScreenWidth(16)),
                  tablet: EdgeInsets.all(getProportionateScreenWidth(24)),
                  desktop: EdgeInsets.all(getProportionateScreenWidth(32)),
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Quick Search Card
                    QuickSearchCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SearchProfessionalPage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: responsive.height(
                        mobile: 24,
                        tablet: 28,
                        desktop: 32,
                      ),
                    ),

                    // Quick Stats
                    if (user != null)
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('appointments')
                            .where('patientId', isEqualTo: user.id)
                            .where(
                              'status',
                              whereIn: ['pending', 'scheduled', 'completed'],
                            )
                            .snapshots(),
                        builder: (context, appointmentsSnapshot) {
                          final appointmentsCount = appointmentsSnapshot.hasData
                              ? appointmentsSnapshot.data!.docs.length
                              : 0;

                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('prescriptions')
                                .where('patientId', isEqualTo: user!.id)
                                .snapshots(),
                            builder: (context, prescriptionsSnapshot) {
                              final prescriptionsCount =
                                  prescriptionsSnapshot.hasData
                                  ? prescriptionsSnapshot.data!.docs.length
                                  : 0;

                              return Row(
                                children: [
                                  Expanded(
                                    child: StatCard(
                                      title: 'Rendez-vous',
                                      value: '$appointmentsCount',
                                      icon: CupertinoIcons.calendar,
                                      color: AppColors.primary,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AppointmentsListPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: responsive.width(
                                      mobile: 12,
                                      tablet: 16,
                                      desktop: 20,
                                    ),
                                  ),
                                  Expanded(
                                    child: StatCard(
                                      title: 'Ordonnances',
                                      value: '$prescriptionsCount',
                                      icon: CupertinoIcons.doc_text,
                                      color: AppColors.accent,
                                      onTap: () {
                                        // TODO: Créer et naviguer vers PrescriptionsListPage
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: CupertinoIcons.videocam_fill,
                            title: 'Téléconsultation',
                            color: AppColors.accent,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: CupertinoIcons.bag,
                            title: 'Pharmacies',
                            color: AppColors.secondary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const OnDutyPharmaciesPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Upcoming Appointments
                    SectionHeader(
                      title: 'Prochains rendez-vous',
                      actionText: 'Voir tout',
                      onActionTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppointmentsListPage(),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 12),

                    // Afficher les rendez-vous depuis Firestore
                    if (user != null)
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('appointments')
                            .where('patientId', isEqualTo: user.id)
                            .where(
                              'status',
                              whereIn: ['scheduled', 'confirmed'],
                            ) // Rendez-vous confirmés
                            .orderBy('date')
                            .limit(3)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(
                                  getProportionateScreenWidth(16.0),
                                ),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(
                                  getProportionateScreenWidth(32.0),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      CupertinoIcons.calendar,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Aucun rendez-vous prévu',
                                      style: TextStyle(
                                        fontSize: getProportionateScreenHeight(
                                          16,
                                        ),
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: snapshot.data!.docs.map((doc) {
                              final appointment =
                                  doc.data() as Map<String, dynamic>;
                              final date = (appointment['date'] as Timestamp)
                                  .toDate();
                              final formattedDate = DateFormat(
                                'dd MMMM yyyy',
                                'fr_FR',
                              ).format(date);
                              final formattedTime = appointment['time'] ?? '';

                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: getProportionateScreenHeight(12),
                                ),
                                child: FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(appointment['doctorId'])
                                      .get(),
                                  builder: (context, doctorSnapshot) {
                                    if (!doctorSnapshot.hasData) {
                                      return const SizedBox.shrink();
                                    }

                                    final doctorData =
                                        doctorSnapshot.data!.data()
                                            as Map<String, dynamic>?;
                                    final doctorName = doctorData != null
                                        ? 'Dr. ${doctorData['firstName']} ${doctorData['lastName']}'
                                        : 'Docteur';

                                    return FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('doctors')
                                          .doc(appointment['doctorId'])
                                          .get(),
                                      builder: (context, specialtySnapshot) {
                                        final specialtyData =
                                            specialtySnapshot.data?.data()
                                                as Map<String, dynamic>?;
                                        final specialty =
                                            specialtyData?['specialty'] ??
                                            'Médecin';

                                        return AppointmentCard(
                                          doctorName: doctorName,
                                          specialty: specialty,
                                          date: formattedDate,
                                          time: formattedTime,
                                          onTap: () {
                                            // TODO: Créer AppointmentDetailsPage et naviguer
                                          },
                                          onCancel: () async {
                                            // Demander la raison de l'annulation
                                            final reasonController =
                                                TextEditingController();
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                  'Annuler le rendez-vous',
                                                ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      'Êtes-vous sûr de vouloir annuler ce rendez-vous ?',
                                                    ),
                                                    const SizedBox(height: 16),
                                                    TextField(
                                                      controller:
                                                          reasonController,
                                                      decoration: const InputDecoration(
                                                        labelText:
                                                            'Motif d\'annulation (optionnel)',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                      maxLines: 3,
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text('Retour'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                    child: const Text(
                                                      'Annuler le RDV',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirmed == true) {
                                              // Annuler le rendez-vous
                                              await FirebaseFirestore.instance
                                                  .collection('appointments')
                                                  .doc(doc.id)
                                                  .update({
                                                    'status': 'cancelled',
                                                    'cancellationReason':
                                                        reasonController.text,
                                                    'cancelledAt':
                                                        FieldValue.serverTimestamp(),
                                                    'cancelledBy': 'patient',
                                                  });

                                              // Créer une notification pour le docteur
                                              await FirebaseFirestore.instance
                                                  .collection('notifications')
                                                  .add({
                                                    'userId':
                                                        appointment['doctorId'],
                                                    'type':
                                                        'appointment_cancelled',
                                                    'title':
                                                        'Rendez-vous annulé',
                                                    'message':
                                                        '${appointment['patientName']} a annulé le rendez-vous du $formattedDate à $formattedTime',
                                                    'reason':
                                                        reasonController
                                                            .text
                                                            .isNotEmpty
                                                        ? reasonController.text
                                                        : null,
                                                    'appointmentId': doc.id,
                                                    'isRead': false,
                                                    'createdAt':
                                                        FieldValue.serverTimestamp(),
                                                  });

                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Rendez-vous annulé',
                                                    ),
                                                    backgroundColor:
                                                        Colors.orange,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    const SizedBox(height: 24),

                    // Specialties
                    SectionHeader(
                      title: 'Spécialités populaires',
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _SpecialtyCard(
                            icon: CupertinoIcons.heart,
                            title: 'Cardiologue',
                            onTap: () {},
                          ),
                          _SpecialtyCard(
                            icon: CupertinoIcons.smiley,
                            title: 'Psychologue',
                            onTap: () {},
                          ),
                          _SpecialtyCard(
                            icon: CupertinoIcons.smiley,
                            title: 'Dermatologue',
                            onTap: () {},
                          ),
                          _SpecialtyCard(
                            icon: CupertinoIcons.person_2,
                            title: 'Pédiatre',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(getProportionateScreenWidth(16)),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: getProportionateScreenHeight(12),
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecialtyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SpecialtyCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: EdgeInsets.only(right: getProportionateScreenWidth(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: getProportionateScreenHeight(11),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder pages
class _AppointmentsPage extends StatelessWidget {
  const _AppointmentsPage();

  @override
  Widget build(BuildContext context) {
    return const AppointmentsListPage(isDoctorView: false);
  }
}

class _MedicalRecordsPage extends StatelessWidget {
  const _MedicalRecordsPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.medicalRecords)),
      body: Center(child: Text(l10n.medicalRecords)),
    );
  }
}

class _MessagesPage extends StatelessWidget {
  const _MessagesPage();

  @override
  Widget build(BuildContext context) {
    return const ConversationsListPage(isDoctor: false);
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final maxWidth = isDesktop ? 700.0 : (isTablet ? 600.0 : double.infinity);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserModel? user;
        if (state is AuthAuthenticated) {
          user = state.user;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.profile),
            backgroundColor: AppColors.primary,
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ListView(
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
                children: [
                  // Info utilisateur
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              user?.firstName[0].toUpperCase() ?? 'U',
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(40),
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.fullName ?? 'Utilisateur',
                            style: TextStyle(
                              fontSize: getProportionateScreenHeight(24),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              fontSize: getProportionateScreenHeight(16),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Menu
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(CupertinoIcons.settings),
                          title: Text(l10n.accountSettings),
                          subtitle: Text(l10n.language),
                          trailing: const Icon(CupertinoIcons.right_chevron),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AccountSettingsPage(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(CupertinoIcons.person),
                          title: Text(l10n.personalInfo),
                          trailing: const Icon(CupertinoIcons.right_chevron),
                          onTap: () {
                            // TODO: Créer PersonalInfoPage et naviguer
                            // Navigator.push(context, MaterialPageRoute(builder: (_) => PersonalInfoPage()));
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(CupertinoIcons.bell_fill),
                          title: Text(l10n.notifications),
                          trailing: const Icon(CupertinoIcons.right_chevron),
                          onTap: () {
                            // TODO: Créer NotificationsSettingsPage et naviguer
                            // Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsSettingsPage()));
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(CupertinoIcons.lock_shield),
                          title: Text(l10n.privacy),
                          trailing: const Icon(CupertinoIcons.right_chevron),
                          onTap: () {
                            // TODO: Créer PrivacySettingsPage et naviguer
                            // Navigator.push(context, MaterialPageRoute(builder: (_) => PrivacySettingsPage()));
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Déconnexion
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        CupertinoIcons.square_arrow_right,
                        color: Colors.red[700],
                      ),
                      title: Text(
                        'Déconnexion',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                      onTap: () {
                        context.read<AuthBloc>().add(AuthSignOutRequested());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
