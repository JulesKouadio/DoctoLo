import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import 'package:intl/intl.dart';
import 'video_call_page.dart';

class AppointmentsListPage extends StatefulWidget {
  final bool isDoctorView; // true si vue médecin, false si vue patient

  const AppointmentsListPage({super.key, this.isDoctorView = false});

  @override
  State<AppointmentsListPage> createState() => _AppointmentsListPageState();
}

class _AppointmentsListPageState extends State<AppointmentsListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _userIdField => widget.isDoctorView ? 'doctorId' : 'patientId';

  Stream<QuerySnapshot> _getAppointmentsStream(String status) {
    Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where(_userIdField, isEqualTo: _currentUserId);

    if (status != 'all') {
      query = query.where('status', isEqualTo: status);
    }

    return query.orderBy('date', descending: false).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isDoctorView ? l10n.myConsultations : l10n.myAppointments,
        ),
        elevation: 0,
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: context.isMobile,
          tabs: [
            Tab(text: l10n.all),
            Tab(text: l10n.pending),
            Tab(text: l10n.confirmed),
            Tab(text: l10n.completed),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AppointmentsList(
            stream: _getAppointmentsStream('all'),
            isDoctorView: widget.isDoctorView,
            emptyMessage: l10n.noAppointments,
          ),
          _AppointmentsList(
            stream: _getAppointmentsStream('pending'),
            isDoctorView: widget.isDoctorView,
            emptyMessage: l10n.noPendingAppointments,
          ),
          _AppointmentsList(
            stream: _getAppointmentsStream('scheduled'),
            isDoctorView: widget.isDoctorView,
            emptyMessage: l10n.noConfirmedAppointments,
          ),
          _AppointmentsList(
            stream: _getAppointmentsStream('completed'),
            isDoctorView: widget.isDoctorView,
            emptyMessage: l10n.noCompletedAppointments,
          ),
        ],
      ),
    );
  }
}

class _AppointmentsList extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  final bool isDoctorView;
  final String emptyMessage;

  const _AppointmentsList({
    required this.stream,
    required this.isDoctorView,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.exclamationmark_circle,
                  size: 60,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text('Erreur: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final appointments = snapshot.data?.docs ?? [];

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(18),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ResponsivePadding(
          child: ResponsiveLayout(
            mobile: _buildMobileList(context, appointments),
            tablet: _buildTabletGrid(context, appointments),
            desktop: _buildDesktopGrid(context, appointments),
          ),
        );
      },
    );
  }

  Widget _buildMobileList(
    BuildContext context,
    List<QueryDocumentSnapshot> appointments,
  ) {
    return ListView.separated(
      itemCount: appointments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final appointment = appointments[index].data() as Map<String, dynamic>;
        return _AppointmentCard(
          appointment: appointment,
          isDoctorView: isDoctorView,
        );
      },
    );
  }

  Widget _buildTabletGrid(
    BuildContext context,
    List<QueryDocumentSnapshot> appointments,
  ) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index].data() as Map<String, dynamic>;
        return _AppointmentCard(
          appointment: appointment,
          isDoctorView: isDoctorView,
        );
      },
    );
  }

  Widget _buildDesktopGrid(
    BuildContext context,
    List<QueryDocumentSnapshot> appointments,
  ) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.3,
      ),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index].data() as Map<String, dynamic>;
        return _AppointmentCard(
          appointment: appointment,
          isDoctorView: isDoctorView,
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final bool isDoctorView;

  const _AppointmentCard({
    required this.appointment,
    required this.isDoctorView,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'scheduled':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'scheduled':
        return 'Confirmé';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  IconData _getTypeIcon(String type) {
    if (type == 'telemedicine') {
      return CupertinoIcons.videocam_fill;
    }
    return CupertinoIcons.plus_circle;
  }

  String _getTypeLabel(String type) {
    if (type == 'telemedicine') {
      return 'Téléconsultation';
    }
    return 'Au cabinet';
  }

  @override
  Widget build(BuildContext context) {
    final status = appointment['status'] as String;
    final type = appointment['type'] as String;
    final date = (appointment['date'] as Timestamp).toDate();
    final timeSlot = appointment['timeSlot'] as String;
    final fee = appointment['fee'] as double;
    final name = isDoctorView
        ? appointment['patientName']
        : 'Dr. ${appointment['doctorName']}';
    final specialty = appointment['specialty'] as String? ?? '';
    final reason = appointment['reason'] as String? ?? '';

    final dateFormatter = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final formattedDate = dateFormatter.format(date);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showAppointmentDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(getProportionateScreenWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
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
                  Icon(_getTypeIcon(type), color: AppColors.primary, size: 24),
                ],
              ),
              const SizedBox(height: 16),

              // Nom et spécialité
              Text(
                name,
                style: TextStyle(
                  fontSize: getProportionateScreenHeight(18),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (specialty.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  specialty,
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(14),
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),

              // Date et heure
              Row(
                children: [
                  Icon(
                    CupertinoIcons.calendar,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(13),
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(CupertinoIcons.clock, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    timeSlot,
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(13),
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Type et tarif
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getTypeLabel(type),
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(12),
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${fee.toStringAsFixed(0)}€',
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(18),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              // Actions rapides
              if (status == 'pending' || status == 'scheduled') ...[
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (status == 'pending' && isDoctorView)
                      TextButton.icon(
                        onPressed: () => _confirmAppointment(context),
                        icon: const Icon(
                          CupertinoIcons.check_mark_circled,
                          size: 18,
                        ),
                        label: const Text('Confirmer'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () => _cancelAppointment(context),
                      icon: const Icon(CupertinoIcons.xmark_circle, size: 18),
                      label: const Text('Annuler'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                    if (status == 'scheduled' && type == 'telemedicine')
                      TextButton.icon(
                        onPressed: () => _startVideoCall(context),
                        icon: const Icon(CupertinoIcons.videocam, size: 18),
                        label: const Text('Rejoindre'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAppointmentDetails(BuildContext context) {
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
          final date = (appointment['date'] as Timestamp).toDate();
          final dateFormatter = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
          final formattedDate = dateFormatter.format(date);
          final status = appointment['status'] as String;
          final type = appointment['type'] as String;
          final timeSlot = appointment['timeSlot'] as String;
          final fee = appointment['fee'] as double;
          final name = isDoctorView
              ? appointment['patientName']
              : 'Dr. ${appointment['doctorName']}';
          final specialty = appointment['specialty'] as String? ?? '';
          final reason = appointment['reason'] as String? ?? '';

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

              // Titre
              Text(
                'Détails du rendez-vous',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // Informations principales
              _DetailItem(
                icon: CupertinoIcons.person,
                label: isDoctorView ? 'Patient' : 'Médecin',
                value: name,
              ),
              if (specialty.isNotEmpty)
                _DetailItem(
                  icon: CupertinoIcons.bag_badge_plus,
                  label: 'Spécialité',
                  value: specialty,
                ),
              _DetailItem(
                icon: CupertinoIcons.calendar,
                label: 'Date',
                value: formattedDate,
              ),
              _DetailItem(
                icon: CupertinoIcons.clock,
                label: 'Heure',
                value: timeSlot,
              ),
              _DetailItem(
                icon: _getTypeIcon(type),
                label: 'Type',
                value: _getTypeLabel(type),
              ),
              _DetailItem(
                icon: CupertinoIcons.money_euro,
                label: 'Tarif',
                value: '${fee.toStringAsFixed(0)}€',
              ),
              _DetailItem(
                icon: CupertinoIcons.info_circle,
                label: 'Statut',
                value: _getStatusLabel(status),
                valueColor: _getStatusColor(status),
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

              // Bouton de démarrage de la téléconsultation
              if (status == 'scheduled' &&
                  type.toLowerCase().contains('téléconsultation')) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _startVideoCall(context);
                    },
                    icon: const Icon(CupertinoIcons.videocam),
                    label: const Text('Démarrer la consultation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(16)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  void _startVideoCall(BuildContext context) {
    final videoCallId = appointment['videoCallId'] as String?;
    final appointmentId = appointment['id'] as String;
    final otherUserName = isDoctorView
        ? appointment['patientName']
        : 'Dr. ${appointment['doctorName']}';

    if (videoCallId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Erreur: ID de visio manquant'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallPage(
          channelName: videoCallId,
          appointmentId: appointmentId,
          userName: otherUserName,
          isDoctor: isDoctorView,
        ),
      ),
    );
  }

  Future<void> _confirmAppointment(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le rendez-vous'),
        content: const Text(
          'Êtes-vous sûr de vouloir confirmer ce rendez-vous ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Trouver le document par ses champs
        final query = await FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: appointment['patientId'])
            .where('doctorId', isEqualTo: appointment['doctorId'])
            .where('date', isEqualTo: appointment['date'])
            .where('timeSlot', isEqualTo: appointment['timeSlot'])
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          await query.docs.first.reference.update({
            'status': 'scheduled',
            'confirmedAt': FieldValue.serverTimestamp(),
          });

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rendez-vous confirmé'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }

  Future<void> _cancelAppointment(BuildContext context) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le rendez-vous'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Êtes-vous sûr de vouloir annuler ce rendez-vous ?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motif d\'annulation (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Retour'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Annuler le RDV'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final query = await FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: appointment['patientId'])
            .where('doctorId', isEqualTo: appointment['doctorId'])
            .where('date', isEqualTo: appointment['date'])
            .where('timeSlot', isEqualTo: appointment['timeSlot'])
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          final cancelledBy = isDoctorView ? 'doctor' : 'patient';
          final recipientId = isDoctorView
              ? appointment['patientId']
              : appointment['doctorId'];
          final cancellerName = isDoctorView
              ? 'Dr. ${appointment['doctorName']}'
              : appointment['patientName'];

          await query.docs.first.reference.update({
            'status': 'cancelled',
            'cancellationReason': reasonController.text,
            'cancelledAt': FieldValue.serverTimestamp(),
            'cancelledBy': cancelledBy,
          });

          // Créer une notification pour l'autre partie
          await FirebaseFirestore.instance.collection('notifications').add({
            'userId': recipientId,
            'type': 'appointment_cancelled',
            'title': 'Rendez-vous annulé',
            'message':
                '$cancellerName a annulé le rendez-vous du ${DateFormat('dd/MM/yyyy', 'fr_FR').format((appointment['date'] as Timestamp).toDate())} à ${appointment['timeSlot']}',
            'reason': reasonController.text.isNotEmpty
                ? reasonController.text
                : null,
            'appointmentId': query.docs.first.id,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rendez-vous annulé'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: getProportionateScreenHeight(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(14),
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(16),
                    fontWeight: FontWeight.w600,
                    color: valueColor,
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
