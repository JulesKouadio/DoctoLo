import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../data/models/user_model.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../../shared/widgets/agenda_slot_card.dart';
import '../../../../shared/widgets/currency_widgets.dart';
import '../../../../shared/widgets/patient_list_card.dart';
import 'availability_settings_page.dart';
import 'consultation_settings_page.dart';
import 'documents_management_page.dart';
import 'professional_experience_page.dart';
import 'agenda_page.dart';
import 'patients_list_page.dart';
import 'patient_detail_page.dart';
import '../../../settings/presentation/pages/account_settings_page.dart';
import '../../../messages/presentation/pages/doctor_messages_page.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _DashboardPage(),
    const _AgendaPage(),
    const _PatientsPage(),
    const _MessagesPage(),
    const _ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            icon: const Icon(CupertinoIcons.square_grid_2x2),
            activeIcon: const Icon(CupertinoIcons.square_grid_2x2_fill),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.calendar),
            activeIcon: const Icon(CupertinoIcons.calendar),
            label: l10n.agenda,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.person_2),
            activeIcon: const Icon(CupertinoIcons.person_2_fill),
            label: l10n.patients,
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
}

class _DashboardPage extends StatefulWidget {
  const _DashboardPage();

  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  int _totalPatients = 0;
  int _todayAppointments = 0;
  int _waitingAppointments = 0;
  double _monthlyRevenue = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Charger les statistiques depuis Firestore
      final firestore = FirebaseFirestore.instance;

      // Nombre total de patients (patients qui ont au moins un RDV actif avec ce docteur)
      // On exclut les rendez-vous annulés ('cancelled')
      final appointmentsSnapshot = await firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: userId)
          .get();

      final uniquePatientIds = <String>{};
      for (var doc in appointmentsSnapshot.docs) {
        final status = doc.data()['status'];
        // Ne compter que les rendez-vous actifs (pas annulés)
        if (status != 'cancelled' && status != 'canceled') {
          final patientId = doc.data()['patientId'];
          if (patientId != null) uniquePatientIds.add(patientId);
        }
      }

      // Rendez-vous d'aujourd'hui
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final todayAppointmentsSnapshot = await firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: userId)
          .where(
            'startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
          )
          .where('startTime', isLessThan: Timestamp.fromDate(todayEnd))
          .get();

      // Rendez-vous en attente (status = 'pending')
      final waitingAppointmentsSnapshot = await firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      // Revenus du mois en cours
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 1);

      final monthAppointmentsSnapshot = await firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .where(
            'startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart),
          )
          .where('startTime', isLessThan: Timestamp.fromDate(monthEnd))
          .get();

      double revenue = 0;
      for (var doc in monthAppointmentsSnapshot.docs) {
        final fee = doc.data()['fee'];
        if (fee != null) revenue += (fee as num).toDouble();
      }

      if (mounted) {
        setState(() {
          _totalPatients = uniquePatientIds.length;
          _todayAppointments = todayAppointmentsSnapshot.docs.length;
          _waitingAppointments = waitingAppointmentsSnapshot.docs.length;
          _monthlyRevenue = revenue;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement stats dashboard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatRevenue(double revenue) {
    if (revenue >= 1000000) {
      return '${(revenue / 1000000).toStringAsFixed(1)}M';
    } else if (revenue >= 1000) {
      return '${(revenue / 1000).toStringAsFixed(1)}K';
    } else {
      return revenue.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserModel? user;
        if (state is AuthAuthenticated) {
          user = state.user;
        }

        return CustomScrollView(
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
                    '${l10n.welcomeBack} Dr. ${user?.lastName ?? ''}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.dashboard,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
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
              padding: EdgeInsets.all(getProportionateScreenWidth(16)),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: CupertinoIcons.person_2_fill,
                          title: l10n.patients,
                          value: _isLoading ? '...' : '$_totalPatients',
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PatientsListPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: CupertinoIcons.calendar,
                          title: l10n.today,
                          value: _isLoading ? '...' : '$_todayAppointments',
                          color: AppColors.secondary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AgendaPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: CupertinoIcons.clock,
                          title: l10n.waiting,
                          value: _isLoading ? '...' : '$_waitingAppointments',
                          color: AppColors.warning,
                          onTap: () {
                            // TODO: Créer et naviguer vers WaitingRoomPage
                            // Navigator.push(context, MaterialPageRoute(builder: (_) => WaitingRoomPage()));
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          iconWidget: const CurrencyIcon(
                            size: 24,
                            color: AppColors.accent,
                          ),
                          title: l10n.revenue,
                          value: _isLoading
                              ? '...'
                              : _formatRevenue(_monthlyRevenue),
                          color: AppColors.accent,
                          onTap: () {
                            // TODO: Créer et naviguer vers RevenueStatsPage
                            // Navigator.push(context, MaterialPageRoute(builder: (_) => RevenueStatsPage()));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: CupertinoIcons.add_circled,
                          title: l10n.newPatient,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: CupertinoIcons.videocam_fill,
                          title: l10n.telemedicine,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Today's Appointments
                  SectionHeader(
                    title: l10n.todaysAppointments,
                    actionText: l10n.viewAgenda,
                    onActionTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AgendaPage(),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),

                  // Afficher les rendez-vous du jour depuis Firestore
                  if (user != null)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('appointments')
                          .where('doctorId', isEqualTo: user.id)
                          .where('status', isEqualTo: 'scheduled')
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

                        if (!snapshot.hasData) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(
                                getProportionateScreenWidth(32.0),
                              ),
                              child: Text('Aucun rendez-vous pour ce jour'),
                            ),
                          );
                        }

                        // Filtrer les rendez-vous d'aujourd'hui
                        final now = DateTime.now();
                        final todayStart = DateTime(
                          now.year,
                          now.month,
                          now.day,
                        );
                        final todayEnd = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          23,
                          59,
                          59,
                        );

                        final todayAppointments = snapshot.data!.docs.where((
                          doc,
                        ) {
                          final appointment =
                              doc.data() as Map<String, dynamic>;
                          final date = (appointment['date'] as Timestamp)
                              .toDate();
                          return date.isAfter(todayStart) &&
                              date.isBefore(todayEnd);
                        }).toList();

                        if (todayAppointments.isEmpty) {
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
                                    'Aucun rendez-vous pour ce jour',
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
                          children: todayAppointments.map((doc) {
                            final appointment =
                                doc.data() as Map<String, dynamic>;
                            final timeSlot = appointment['timeSlot'] ?? '';
                            final patientName =
                                appointment['patientName'] ?? 'Patient';
                            final type = appointment['type'] ?? 'Consultation';
                            final appointmentId = doc.id;

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: getProportionateScreenHeight(8),
                              ),
                              child: AgendaSlotCard(
                                time: timeSlot,
                                patientName: patientName,
                                appointmentType: type,
                                isCompleted: false,
                                onTap: () {
                                  // TODO: Créer AppointmentDetailsPage et naviguer
                                },
                                onMarkComplete: () async {
                                  // Marquer comme terminé
                                  await FirebaseFirestore.instance
                                      .collection('appointments')
                                      .doc(appointmentId)
                                      .update({'status': 'completed'});

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Rendez-vous marqué comme terminé',
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  const SizedBox(height: 24),

                  // Recent Patients
                  SectionHeader(
                    title: l10n.recentPatients,
                    actionText: l10n.viewAll,
                    onActionTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PatientsListPage(),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),

                  // Afficher les patients récents depuis Firestore
                  if (user != null)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('appointments')
                          .where('doctorId', isEqualTo: user.id)
                          .where('status', whereIn: ['scheduled', 'completed'])
                          .orderBy('date', descending: true)
                          .limit(5)
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

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(
                                getProportionateScreenWidth(32.0),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    CupertinoIcons.person_2,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucun patient récent',
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

                        // Récupérer les patients uniques
                        final Map<String, Map<String, dynamic>> uniquePatients =
                            {};
                        for (var doc in snapshot.data!.docs) {
                          final appointment =
                              doc.data() as Map<String, dynamic>;
                          final patientId = appointment['patientId'];
                          if (patientId != null &&
                              !uniquePatients.containsKey(patientId)) {
                            uniquePatients[patientId] = appointment;
                          }
                        }

                        if (uniquePatients.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(
                                getProportionateScreenWidth(32.0),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    CupertinoIcons.person_2,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucun patient récent',
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
                          children: uniquePatients.entries.take(3).map((entry) {
                            final patientId = entry.key;
                            final appointment = entry.value;
                            final patientName =
                                appointment['patientName'] ?? 'Patient';
                            final lastVisitDate =
                                (appointment['date'] as Timestamp).toDate();
                            final formattedLastVisit = DateFormat(
                              'dd MMM yyyy',
                              'fr_FR',
                            ).format(lastVisitDate);

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: getProportionateScreenHeight(8),
                              ),
                              child: PatientListCard(
                                patientName: patientName,
                                patientId: patientId,
                                lastVisit: formattedLastVisit,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PatientDetailPage(
                                        patientId: patientId,
                                        patientName: patientName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(getProportionateScreenWidth(16)),
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
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: getProportionateScreenHeight(12),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder pages
class _AgendaPage extends StatelessWidget {
  const _AgendaPage();

  @override
  Widget build(BuildContext context) {
    return const AgendaPage();
  }
}

class _PatientsPage extends StatelessWidget {
  const _PatientsPage();

  @override
  Widget build(BuildContext context) {
    return const PatientsListPage();
  }
}

class _MessagesPage extends StatelessWidget {
  const _MessagesPage();

  @override
  Widget build(BuildContext context) {
    return const DoctorMessagesPage();
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserModel? user;
        String? doctorId;

        if (state is AuthAuthenticated) {
          user = state.user;
          // TODO: Récupérer le doctorId depuis Firestore
          // Pour l'instant on utilise userId
          doctorId = user.id;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.profile),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: ListView(
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            children: [
              // Section Paramètres professionnels
              Text(
                l10n.professionalSettings,
                style: TextStyle(
                  fontSize: getProportionateScreenHeight(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          CupertinoIcons.clock,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(l10n.myAvailability),
                      subtitle: Text(l10n.defineWorkHours),
                      trailing: const Icon(CupertinoIcons.right_chevron),
                      onTap: () {
                        if (doctorId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AvailabilitySettingsPage(
                                doctorId: doctorId!,
                                userId: user!.id,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.accent.withOpacity(0.1),
                        child: Icon(
                          CupertinoIcons.bag_badge_plus,
                          color: AppColors.accent,
                        ),
                      ),
                      title: Text(l10n.consultationTypes),
                      subtitle: Text(l10n.physicalTeleconsultationPrices),
                      trailing: const Icon(CupertinoIcons.right_chevron),
                      onTap: () {
                        if (doctorId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConsultationSettingsPage(
                                doctorId: doctorId!,
                                userId: user!.id,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.withOpacity(0.1),
                        child: const Icon(
                          CupertinoIcons.book,
                          color: Colors.purple,
                        ),
                      ),
                      title: Text(l10n.professionalExperience),
                      subtitle: Text(l10n.studiesExperienceCertifications),
                      trailing: const Icon(CupertinoIcons.right_chevron),
                      onTap: () {
                        if (doctorId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ProfessionalExperiencePage(),
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.secondary.withOpacity(0.1),
                        child: Icon(
                          CupertinoIcons.folder_fill,
                          color: AppColors.secondary,
                        ),
                      ),
                      title: Text(l10n.cvAndDiplomas),
                      subtitle: Text(l10n.manageDocuments),
                      trailing: const Icon(CupertinoIcons.right_chevron),
                      onTap: () {
                        if (doctorId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DocumentsManagementPage(
                                doctorId: doctorId!,
                                userId: user!.id,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Compte
              Text(
                l10n.myAccount,
                style: TextStyle(
                  fontSize: getProportionateScreenHeight(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: const Icon(CupertinoIcons.person),
                      ),
                      title: Text(user?.fullName ?? l10n.user),
                      subtitle: Text(user?.email ?? ''),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(CupertinoIcons.settings),
                      title: Text(l10n.accountSettings),
                      trailing: const Icon(CupertinoIcons.right_chevron),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountSettingsPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        CupertinoIcons.square_arrow_right,
                        color: Colors.red[700],
                      ),
                      title: Text(
                        l10n.logout,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                      onTap: () {
                        context.read<AuthBloc>().add(AuthSignOutRequested());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
