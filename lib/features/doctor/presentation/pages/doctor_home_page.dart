import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/hive_service.dart';
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
import '../../../appointment/presentation/pages/video_call_page.dart';

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
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/doctolo_icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'DoctoLo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(CupertinoIcons.square_grid_2x2),
          selectedIcon: const Icon(CupertinoIcons.square_grid_2x2_fill),
          label: Text(l10n.dashboard),
        ),
        NavigationRailDestination(
          icon: const Icon(CupertinoIcons.calendar),
          selectedIcon: const Icon(CupertinoIcons.calendar),
          label: Text(l10n.agenda),
        ),
        NavigationRailDestination(
          icon: const Icon(CupertinoIcons.person_2),
          selectedIcon: const Icon(CupertinoIcons.person_2_fill),
          label: Text(l10n.patients),
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

  final HiveService _hiveService = HiveService();
  static const String _dashboardCacheKey = 'dashboard_stats';

  @override
  void initState() {
    super.initState();
    _loadFromCacheThenFirebase();
    _setupFirebaseListener();
  }

  /// Charge d'abord depuis le cache Hive, puis met à jour depuis Firebase
  Future<void> _loadFromCacheThenFirebase() async {
    // 1. Charger depuis Hive (rapide)
    final cachedStats = _hiveService.getCachedData(_dashboardCacheKey);
    if (cachedStats != null && cachedStats is Map) {
      if (mounted) {
        setState(() {
          _totalPatients = cachedStats['totalPatients'] ?? 0;
          _todayAppointments = cachedStats['todayAppointments'] ?? 0;
          _waitingAppointments = cachedStats['waitingAppointments'] ?? 0;
          _monthlyRevenue = (cachedStats['monthlyRevenue'] ?? 0).toDouble();
          _isLoading = false;
        });
      }
    }

    // 2. Mettre à jour depuis Firebase
    await _loadDashboardStats();
  }

  /// Configure un listener Firebase pour les mises à jour en temps réel
  void _setupFirebaseListener() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Écouter les changements dans les rendez-vous
    FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
          // Recharger les stats quand les RDV changent
          _loadDashboardStats();
        });
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

        // Sauvegarder dans le cache Hive pour le prochain chargement
        await _hiveService.cacheData(_dashboardCacheKey, {
          'totalPatients': uniquePatientIds.length,
          'todayAppointments': todayAppointmentsSnapshot.docs.length,
          'waitingAppointments': waitingAppointmentsSnapshot.docs.length,
          'monthlyRevenue': revenue,
          'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        }, ttl: const Duration(hours: 24));
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

  /// Affiche un dialogue pour créer un nouveau patient non enregistré
  Future<void> _showNewPatientDialog(
    BuildContext context,
    UserModel? user,
  ) async {
    if (user == null) return;

    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau Patient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enregistrez un patient qui n\'a pas pris rendez-vous',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motif de consultation',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (lastNameController.text.isEmpty ||
                  firstNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir le nom et le prénom'),
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: const Text('Créer la consultation'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final patientId = const Uuid().v4();
        final appointmentId = const Uuid().v4();
        final now = DateTime.now();

        // Créer un rendez-vous immédiat pour ce patient non enregistré
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointmentId)
            .set({
              'id': appointmentId,
              'patientId': patientId,
              'patientName':
                  '${firstNameController.text} ${lastNameController.text}',
              'patientPhone': phoneController.text,
              'isUnregisteredPatient': true,
              'doctorId': user.id,
              'doctorName': '${user.firstName} ${user.lastName}',
              'date': Timestamp.fromDate(now),
              'timeSlot': DateFormat('HH:mm').format(now),
              'type': 'cabinet',
              'status': 'in_progress',
              'reason': reasonController.text,
              'fee': 0,
              'createdAt': FieldValue.serverTimestamp(),
            });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Consultation créée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          // Recharger les stats
          _loadDashboardStats();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }

  /// Démarre la prochaine téléconsultation confirmée
  Future<void> _startNextTeleconsultation(
    BuildContext context,
    UserModel? user,
  ) async {
    if (user == null) return;

    try {
      // Chercher la prochaine téléconsultation confirmée
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: user.id)
          .where('status', whereIn: ['confirmed', 'scheduled'])
          .where('type', whereIn: ['telemedicine', 'téléconsultation'])
          .orderBy('date')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune téléconsultation programmée'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final appointment = snapshot.docs.first.data();
      final appointmentId = snapshot.docs.first.id;
      String? videoCallId = appointment['videoCallId'] as String?;

      // Créer un videoCallId si nécessaire
      if (videoCallId == null || videoCallId.isEmpty) {
        videoCallId = const Uuid().v4();
        await snapshot.docs.first.reference.update({
          'videoCallId': videoCallId,
          'callInitiatedAt': FieldValue.serverTimestamp(),
          'callInitiatedBy': 'doctor',
        });

        // Notifier le patient
        final patientId = appointment['patientId'] as String?;
        if (patientId != null) {
          await FirebaseFirestore.instance.collection('notifications').add({
            'userId': patientId,
            'type': 'teleconsultation_started',
            'title': 'Téléconsultation démarrée',
            'message':
                'Dr. ${user.lastName} vous attend pour votre téléconsultation',
            'appointmentId': appointmentId,
            'videoCallId': videoCallId,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCallPage(
              channelName: videoCallId!,
              appointmentId: appointmentId,
              userName: appointment['patientName'] ?? 'Patient',
              isDoctor: true,
            ),
          ),
        ).then((_) => _loadDashboardStats());
      }
    } catch (e) {
      // Afficher l'erreur complète pour debug (notamment le lien de création d'index Firebase)
      print('❌ Erreur téléconsultation: $e');
      print(
        '🔗 Si c\'est une erreur d\'index, copiez le lien ci-dessus pour créer l\'index Firebase',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = context.isDesktop;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserModel? user;
        if (state is AuthAuthenticated) {
          user = state.user;
        }

        // Si desktop, utiliser le nouveau layout
        if (isDesktop) {
          return _buildDesktopLayout(context, l10n, user);
        }

        // Layout mobile
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
                          onTap: () => _showNewPatientDialog(context, user),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: CupertinoIcons.videocam_fill,
                          title: l10n.telemedicine,
                          onTap: () =>
                              _startNextTeleconsultation(context, user),
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

  // ===== LAYOUT DESKTOP =====

  // SOLUTION : Remplacez la méthode _buildDesktopLayout par celle-ci

  Widget _buildDesktopLayout(
    BuildContext context,
    AppLocalizations l10n,
    UserModel? user,
  ) {
    return CustomScrollView(
      slivers: [
        // Header Desktop - VERSION CORRIGÉE
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 80, // Remplace expandedHeight
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${l10n.welcomeBack} Dr. ${user?.lastName ?? ''}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'EEEE d MMMM yyyy',
                        'fr_FR',
                      ).format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(CupertinoIcons.bell),
                      iconSize: 24,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        user?.lastName.substring(0, 1).toUpperCase() ?? 'D',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Contenu (reste identique)
        SliverPadding(
          padding: const EdgeInsets.all(32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Colonne gauche (70%)
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        // Stats 2x2
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 2.5,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _DesktopStatCard(
                              icon: CupertinoIcons.person_2_fill,
                              title: l10n.patients,
                              value: _isLoading ? '...' : '$_totalPatients',
                              subtitle: 'Patients actifs',
                              color: AppColors.primary,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PatientsListPage(),
                                ),
                              ),
                            ),
                            _DesktopStatCard(
                              icon: CupertinoIcons.calendar,
                              title: l10n.today,
                              value: _isLoading ? '...' : '$_todayAppointments',
                              subtitle: 'Rendez-vous',
                              color: AppColors.secondary,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AgendaPage(),
                                ),
                              ),
                            ),
                            _DesktopStatCard(
                              icon: CupertinoIcons.clock,
                              title: l10n.waiting,
                              value: _isLoading
                                  ? '...'
                                  : '$_waitingAppointments',
                              subtitle: 'En attente',
                              color: AppColors.warning,
                              onTap: () {},
                            ),
                            _DesktopStatCard(
                              iconWidget: const CurrencyIcon(
                                size: 28,
                                color: AppColors.accent,
                              ),
                              title: l10n.revenue,
                              value: _isLoading
                                  ? '...'
                                  : _formatRevenue(_monthlyRevenue),
                              subtitle: 'Ce mois',
                              color: AppColors.accent,
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Rendez-vous du jour
                        _buildDesktopSection(
                          title: l10n.todaysAppointments,
                          actionText: l10n.viewAgenda,
                          onActionTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AgendaPage(),
                            ),
                          ),
                          child: _buildTodayAppointments(user),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Colonne droite (30%)
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        // Actions rapides
                        _buildDesktopSection(
                          title: 'Actions rapides',
                          child: Column(
                            children: [
                              _DesktopQuickActionCard(
                                icon: CupertinoIcons.add_circled_solid,
                                title: l10n.newPatient,
                                subtitle: 'Enregistrer un nouveau patient',
                                color: AppColors.primary,
                                onTap: () =>
                                    _showNewPatientDialog(context, user),
                              ),
                              const SizedBox(height: 12),
                              _DesktopQuickActionCard(
                                icon: CupertinoIcons.videocam_fill,
                                title: l10n.telemedicine,
                                subtitle: 'Démarrer une téléconsultation',
                                color: AppColors.secondary,
                                onTap: () =>
                                    _startNextTeleconsultation(context, user),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Patients récents
                        _buildDesktopSection(
                          title: l10n.recentPatients,
                          actionText: l10n.viewAll,
                          onActionTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PatientsListPage(),
                            ),
                          ),
                          child: _buildRecentPatients(user),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopSection({
    required String title,
    String? actionText,
    VoidCallback? onActionTap,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            if (actionText != null && onActionTap != null)
              TextButton(
                onPressed: onActionTap,
                child: Text(actionText, style: const TextStyle(fontSize: 14)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  // StreamBuilder pour les rendez-vous (Desktop)
  Widget _buildTodayAppointments(UserModel? user) {
    if (user == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: user.id)
          .where('status', isEqualTo: 'scheduled')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData) {
          return _buildEmptyState(
            icon: CupertinoIcons.calendar,
            message: 'Aucun rendez-vous',
          );
        }

        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

        final todayAppointments = snapshot.data!.docs.where((doc) {
          final appointment = doc.data() as Map<String, dynamic>;
          final date = (appointment['date'] as Timestamp).toDate();
          return date.isAfter(todayStart) && date.isBefore(todayEnd);
        }).toList();

        if (todayAppointments.isEmpty) {
          return _buildEmptyState(
            icon: CupertinoIcons.calendar,
            message: 'Aucun rendez-vous pour aujourd\'hui',
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todayAppointments.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Colors.grey[200]),
            itemBuilder: (context, index) {
              final doc = todayAppointments[index];
              final appointment = doc.data() as Map<String, dynamic>;
              final timeSlot = appointment['timeSlot'] ?? '';
              final patientName = appointment['patientName'] ?? 'Patient';
              final type = appointment['type'] ?? 'Consultation';
              final appointmentId = doc.id;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      timeSlot,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  patientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  type,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(CupertinoIcons.checkmark_circle),
                  color: AppColors.success,
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('appointments')
                        .doc(appointmentId)
                        .update({'status': 'completed'});
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  // StreamBuilder pour les patients (Desktop)
  Widget _buildRecentPatients(UserModel? user) {
    if (user == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: user.id)
          .where('status', whereIn: ['scheduled', 'completed'])
          .orderBy('date', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: CupertinoIcons.person_2,
            message: 'Aucun patient récent',
          );
        }

        final Map<String, Map<String, dynamic>> uniquePatients = {};
        for (var doc in snapshot.data!.docs) {
          final appointment = doc.data() as Map<String, dynamic>;
          final patientId = appointment['patientId'];
          if (patientId != null && !uniquePatients.containsKey(patientId)) {
            uniquePatients[patientId] = appointment;
          }
        }

        if (uniquePatients.isEmpty) {
          return _buildEmptyState(
            icon: CupertinoIcons.person_2,
            message: 'Aucun patient récent',
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: uniquePatients.entries.take(4).length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Colors.grey[200]),
            itemBuilder: (context, index) {
              final entry = uniquePatients.entries.elementAt(index);
              final patientId = entry.key;
              final appointment = entry.value;
              final patientName = appointment['patientName'] ?? 'Patient';
              final lastVisitDate = (appointment['date'] as Timestamp).toDate();
              final formattedLastVisit = DateFormat(
                'dd MMM yyyy',
                'fr_FR',
              ).format(lastVisitDate);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    patientName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  patientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  'Dernière visite: $formattedLastVisit',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: const Icon(CupertinoIcons.right_chevron, size: 16),
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
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
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
                fontSize: getProportionateScreenHeight(15),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGETS DESKTOP
class _DesktopStatCard extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DesktopStatCard({
    this.icon,
    this.iconWidget,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: iconWidget ?? Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              CupertinoIcons.right_chevron,
              size: 16,
              color: color.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopQuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DesktopQuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.right_chevron, size: 16, color: color),
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
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final maxWidth = isDesktop ? 700.0 : (isTablet ? 600.0 : double.infinity);

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
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ListView(
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
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
                                  builder: (context) =>
                                      AvailabilitySettingsPage(
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
                                  builder: (context) =>
                                      ConsultationSettingsPage(
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
                            backgroundColor: AppColors.secondary.withOpacity(
                              0.1,
                            ),
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
                                builder: (context) =>
                                    const AccountSettingsPage(),
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
                            context.read<AuthBloc>().add(
                              AuthSignOutRequested(),
                            );
                          },
                        ),
                      ],
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
