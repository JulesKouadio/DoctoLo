import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../shared/widgets/currency_widgets.dart';
import '../../../appointment/presentation/pages/video_call_page.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late final ValueNotifier<List<Map<String, dynamic>>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  bool _isLoading = true;
  final _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadAppointments();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: _currentUserId)
          .get();

      final Map<DateTime, List<Map<String, dynamic>>> events = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['date'] as Timestamp;
        final date = timestamp.toDate();
        final dateOnly = DateTime(date.year, date.month, date.day);

        if (events[dateOnly] == null) {
          events[dateOnly] = [];
        }
        events[dateOnly]!.add({...data, 'id': doc.id});
      }

      setState(() {
        _events = events;
        _isLoading = false;
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    } catch (e) {
      print('❌ Erreur chargement rendez-vous: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    return _events[dateOnly] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'telemedicine':
      case 'téléconsultation':
        return CupertinoIcons.videocam_fill;
      case 'home':
      case 'domicile':
        return CupertinoIcons.house_fill;
      case 'cabinet':
      case 'office':
      default:
        return CupertinoIcons.building_2_fill;
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'telemedicine':
      case 'téléconsultation':
        return 'Téléconsultation';
      case 'home':
      case 'domicile':
        return 'À domicile';
      case 'cabinet':
      case 'office':
        return 'Au cabinet';
      default:
        return type;
    }
  }

  bool _isTelemedicine(String type) {
    return type.toLowerCase() == 'telemedicine' ||
        type.toLowerCase() == 'téléconsultation';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myAgenda),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.refresh),
            onPressed: _loadAppointments,
            tooltip: l10n.refresh,
          ),
          PopupMenuButton<CalendarFormat>(
            icon: const Icon(CupertinoIcons.square_grid_3x2),
            tooltip: l10n.format,
            onSelected: (format) {
              setState(() => _calendarFormat = format);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: CalendarFormat.month,
                child: Text(l10n.month),
              ),
              PopupMenuItem(
                value: CalendarFormat.twoWeeks,
                child: Text(l10n.twoWeeks),
              ),
              PopupMenuItem(value: CalendarFormat.week, child: Text(l10n.week)),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout(
              mobile: _buildMobileLayout(),
              tablet: _buildTabletLayout(),
              desktop: _buildDesktopLayout(),
            ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Flexible(flex: 0, child: _buildCalendar()),
        const Divider(height: 1),
        Expanded(child: _buildAppointmentsList()),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Flexible(flex: 0, child: _buildCalendar()),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            child: _buildAppointmentsGrid(2),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildCalendar()),
        const VerticalDivider(width: 1),
        Expanded(flex: 3, child: _buildAppointmentsList(isDesktop: true)),
      ],
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        locale: AppLocalizations.of(context)!.localeCode,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          outsideDaysVisible: false,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: getProportionateScreenHeight(18),
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: const Icon(
            CupertinoIcons.left_chevron,
            color: AppColors.primary,
          ),
          rightChevronIcon: const Icon(
            CupertinoIcons.right_chevron,
            color: AppColors.primary,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.grey[700]),
          weekendStyle: TextStyle(color: AppColors.error),
        ),
        onDaySelected: _onDaySelected,
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildAppointmentsList({bool isDesktop = false}) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: _selectedEvents,
      builder: (context, events, _) {
        if (events.isEmpty) {
          return _buildEmptyState();
        }

        // Trier les événements par heure
        events.sort((a, b) {
          final timeA = a['timeSlot'] as String;
          final timeB = b['timeSlot'] as String;
          return timeA.compareTo(timeB);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(getProportionateScreenWidth(16)),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.calendar,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat(
                      'EEEE d MMMM yyyy',
                      l10n.localeCode,
                    ).format(_selectedDay!),
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(12),
                      vertical: getProportionateScreenHeight(6),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${events.length} RDV',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: getProportionateScreenHeight(13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(16),
                ),
                itemCount: events.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _AppointmentTimelineCard(
                    appointment: events[index],
                    isFirst: index == 0,
                    isLast: index == events.length - 1,
                    onTap: () => _showAppointmentDetails(events[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentsGrid(int crossAxisCount) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: _selectedEvents,
      builder: (context, events, _) {
        if (events.isEmpty) {
          return _buildEmptyState();
        }

        events.sort(
          (a, b) =>
              (a['timeSlot'] as String).compareTo(b['timeSlot'] as String),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat(
                    'EEEE d MMMM yyyy',
                    AppLocalizations.of(context)!.localeCode,
                  ).format(_selectedDay!),
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                ),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return _AppointmentCard(
                    appointment: events[index],
                    onTap: () => _showAppointmentDetails(events[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.calendar_badge_plus,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noAppointmentsForDate,
            style: TextStyle(
              fontSize: getProportionateScreenHeight(18),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('d MMMM yyyy', l10n.localeCode).format(_selectedDay!),
            style: TextStyle(
              fontSize: getProportionateScreenHeight(14),
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          final status = appointment['status'] as String;
          final type = appointment['type'] as String;
          final timeSlot = appointment['timeSlot'] as String;
          final patientName = appointment['patientName'] as String;
          final reason = appointment['reason'] as String? ?? '';
          final fee = appointment['fee'] as double;

          return ListView(
            controller: scrollController,
            padding: EdgeInsets.all(getProportionateScreenWidth(24)),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // En-tête
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      type == 'telemedicine'
                          ? CupertinoIcons.videocam_fill
                          : CupertinoIcons.plus_circle,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patientName,
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusLabel(status),
                            style: TextStyle(
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.w600,
                              fontSize: getProportionateScreenHeight(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Détails
              _DetailRow(
                icon: CupertinoIcons.calendar,
                label: 'Date',
                value: DateFormat(
                  'EEEE d MMMM yyyy',
                  l10n.localeCode,
                ).format(_selectedDay!),
              ),
              _DetailRow(
                icon: CupertinoIcons.clock,
                label: 'Heure',
                value: timeSlot,
              ),
              _DetailRow(
                icon: _getTypeIcon(type),
                label: 'Type',
                value: _getTypeLabel(type),
              ),
              _DetailRowWithCurrency(
                icon: CupertinoIcons.money_dollar,
                label: 'Tarif',
                amount: fee,
              ),

              if (reason.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Motif de consultation',
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(getProportionateScreenWidth(12)),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(reason),
                ),
              ],

              const SizedBox(height: 32),

              // Actions
              if (status == 'pending') ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _cancelAppointment(appointment);
                        },
                        icon: const Icon(CupertinoIcons.xmark_circle),
                        label: const Text('Refuser'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: EdgeInsets.symmetric(
                            vertical: getProportionateScreenHeight(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _confirmAppointment(appointment);
                        },
                        icon: const Icon(CupertinoIcons.checkmark_circle),
                        label: const Text('Confirmer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: getProportionateScreenHeight(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (status == 'confirmed' && _isTelemedicine(type)) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _startVideoCall(appointment);
                  },
                  icon: const Icon(CupertinoIcons.videocam),
                  label: const Text('Démarrer la téléconsultation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: getProportionateScreenHeight(14),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmé';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  Future<void> _confirmAppointment(Map<String, dynamic> appointment) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointment['id'])
          .update({
            'status': 'confirmed',
            'confirmedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rendez-vous confirmé'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _loadAppointments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _cancelAppointment(Map<String, dynamic> appointment) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser le rendez-vous'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Souhaitez-vous refuser ce rendez-vous ?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Raison (optionnelle)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointment['id'])
            .update({
              'status': 'cancelled',
              'cancellationReason': reasonController.text,
              'cancelledAt': FieldValue.serverTimestamp(),
            });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rendez-vous refusé'),
              backgroundColor: Colors.orange,
            ),
          );
        }

        _loadAppointments();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }

  Future<void> _startVideoCall(Map<String, dynamic> appointment) async {
    String? videoCallId = appointment['videoCallId'] as String?;
    final appointmentId = appointment['id'] as String;
    final patientName = appointment['patientName'] as String;

    // Si pas de videoCallId, en créer un et le sauvegarder
    if (videoCallId == null || videoCallId.isEmpty) {
      try {
        videoCallId = const Uuid().v4();
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointmentId)
            .update({
              'videoCallId': videoCallId,
              'callInitiatedAt': FieldValue.serverTimestamp(),
              'callInitiatedBy': 'doctor',
            });

        // Créer une notification pour le patient
        final patientId = appointment['patientId'] as String?;
        if (patientId != null) {
          await FirebaseFirestore.instance.collection('notifications').add({
            'userId': patientId,
            'type': 'teleconsultation_started',
            'title': 'Téléconsultation démarrée',
            'message':
                'Le Dr. ${appointment['doctorName'] ?? 'votre médecin'} vous attend pour votre téléconsultation',
            'appointmentId': appointmentId,
            'videoCallId': videoCallId,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur de création de la session: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallPage(
          channelName: videoCallId!,
          appointmentId: appointmentId,
          userName: patientName,
          isDoctor: true,
        ),
      ),
    ).then((_) {
      // Recharger les rendez-vous après la fin de la consultation
      _loadAppointments();
    });
  }
}

class _AppointmentTimelineCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _AppointmentTimelineCard({
    required this.appointment,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'telemedicine':
      case 'téléconsultation':
        return CupertinoIcons.videocam_fill;
      case 'home':
      case 'domicile':
        return CupertinoIcons.house_fill;
      case 'cabinet':
      case 'office':
      default:
        return CupertinoIcons.building_2_fill;
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'telemedicine':
      case 'téléconsultation':
        return 'Téléconsultation';
      case 'home':
      case 'domicile':
        return 'À domicile';
      case 'cabinet':
      case 'office':
        return 'Au cabinet';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = appointment['status'] as String;
    final type = appointment['type'] as String;
    final timeSlot = appointment['timeSlot'] as String;
    final patientName = appointment['patientName'] as String;
    final statusColor = _getStatusColor(status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  border: Border.all(color: statusColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    timeSlot.split('-')[0],
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: getProportionateScreenHeight(12),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.grey[300],
                  margin: EdgeInsets.symmetric(
                    vertical: getProportionateScreenHeight(4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Carte
          Expanded(
            child: Container(
              padding: EdgeInsets.all(getProportionateScreenWidth(12)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getTypeIcon(type),
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          patientName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: getProportionateScreenHeight(16),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(8),
                          vertical: getProportionateScreenHeight(4),
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusLabel(status),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: getProportionateScreenHeight(11),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.clock,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeSlot,
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(13),
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        _getTypeIcon(type),
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTypeLabel(type),
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(13),
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmé';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback onTap;

  const _AppointmentCard({required this.appointment, required this.onTap});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'telemedicine':
      case 'téléconsultation':
        return CupertinoIcons.videocam_fill;
      case 'home':
      case 'domicile':
        return CupertinoIcons.house_fill;
      case 'cabinet':
      case 'office':
      default:
        return CupertinoIcons.building_2_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = appointment['status'] as String;
    final type = appointment['type'] as String;
    final timeSlot = appointment['timeSlot'] as String;
    final patientName = appointment['patientName'] as String;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(getProportionateScreenWidth(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(10),
                      vertical: getProportionateScreenHeight(4),
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(status),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: getProportionateScreenHeight(11),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(_getTypeIcon(type), color: AppColors.primary, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                patientName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: getProportionateScreenHeight(16),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(CupertinoIcons.clock, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    timeSlot,
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(13),
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmé';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: getProportionateScreenHeight(16)),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(12),
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRowWithCurrency extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;

  const _DetailRowWithCurrency({
    required this.icon,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: getProportionateScreenHeight(16)),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(12),
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                CurrencyText(
                  amount: amount,
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
