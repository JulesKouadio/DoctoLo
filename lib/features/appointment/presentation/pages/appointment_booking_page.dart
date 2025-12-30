import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/utils/responsive.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class AppointmentBookingPage extends StatefulWidget {
  final String userId;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String? photoUrl;
  final double consultationFee;
  final double teleconsultationFee;
  final bool offersPhysicalConsultation;
  final bool offersTelemedicine;

  const AppointmentBookingPage({
    super.key,
    required this.userId,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    this.photoUrl,
    required this.consultationFee,
    required this.teleconsultationFee,
    required this.offersPhysicalConsultation,
    required this.offersTelemedicine,
  });

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  int _currentStep = 0;
  String? _selectedConsultationType;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  String _reason = '';
  bool _isLoading = false;

  final TextEditingController _reasonController = TextEditingController();
  Map<String, List<String>> _availableSlots = {};

  @override
  void initState() {
    super.initState();
    if (widget.offersPhysicalConsultation && !widget.offersTelemedicine) {
      _selectedConsultationType = 'physical';
    } else if (widget.offersTelemedicine &&
        !widget.offersPhysicalConsultation) {
      _selectedConsultationType = 'telemedicine';
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableSlots(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Charger les disponibilités du médecin
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .get();

      if (doc.exists && doc.data()?['availability'] != null) {
        final availability =
            doc.data()!['availability'] as Map<String, dynamic>;
        final dayName = _getDayName(date.weekday);

        if (availability[dayName] != null) {
          final slots = List<Map<String, dynamic>>.from(availability[dayName]);
          List<String> timeSlots = [];

          for (var slot in slots) {
            final start = slot['start'] as String;
            final end = slot['end'] as String;
            timeSlots.addAll(_generateTimeSlots(start, end));
          }

          // Récupérer les rendez-vous déjà réservés pour ce jour
          final startOfDay = DateTime(date.year, date.month, date.day);
          final endOfDay = DateTime(
            date.year,
            date.month,
            date.day,
            23,
            59,
            59,
          );

          final bookedAppointments = await FirebaseFirestore.instance
              .collection('appointments')
              .where('doctorId', isEqualTo: widget.userId)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
              )
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
              .where('status', whereIn: ['pending', 'confirmed'])
              .get();

          // Extraire les créneaux déjà réservés
          final bookedSlots = bookedAppointments.docs
              .map((doc) => doc.data()['timeSlot'] as String?)
              .where((slot) => slot != null)
              .toSet();

          // Filtrer les créneaux disponibles
          var availableTimeSlots = timeSlots
              .where((slot) => !bookedSlots.contains(slot))
              .toList();

          // Si c'est aujourd'hui, filtrer les créneaux passés
          final now = DateTime.now();
          final isToday =
              date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;

          if (isToday) {
            availableTimeSlots = availableTimeSlots.where((slot) {
              final parts = slot.split(':');
              final slotHour = int.parse(parts[0]);
              final slotMinute = int.parse(parts[1]);
              // Garder seulement les créneaux futurs (au moins 30 min après maintenant)
              final slotTime = DateTime(
                now.year,
                now.month,
                now.day,
                slotHour,
                slotMinute,
              );
              return slotTime.isAfter(now.add(const Duration(minutes: 30)));
            }).toList();
          }

          setState(() {
            _availableSlots = {dayName: availableTimeSlots};
            _isLoading = false;
          });
        } else {
          setState(() {
            _availableSlots = {};
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Erreur chargement créneaux: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> _generateTimeSlots(String start, String end) {
    final startParts = start.split(':');
    final endParts = end.split(':');
    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);
    final endHour = int.parse(endParts[0]);
    final endMinute = int.parse(endParts[1]);

    List<String> slots = [];
    int currentHour = startHour;
    int currentMinute = startMinute;

    while (currentHour < endHour ||
        (currentHour == endHour && currentMinute < endMinute)) {
      slots.add(
        '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}',
      );
      currentMinute += 30;
      if (currentMinute >= 60) {
        currentMinute = 0;
        currentHour++;
      }
    }

    return slots;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return '';
    }
  }

  Future<void> _confirmAppointment() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Générer un ID unique pour la téléconsultation
      final videoCallId = _selectedConsultationType == 'telemedicine'
          ? 'call_${DateTime.now().millisecondsSinceEpoch}_${authState.user.id.substring(0, 8)}'
          : null;

      final appointment = {
        'patientId': authState.user.id,
        'patientName': authState.user.fullName,
        'doctorId': widget.userId,
        'doctorName': widget.doctorName,
        'specialty': widget.specialty,
        'type': _selectedConsultationType == 'physical'
            ? 'Consultation physique'
            : 'Téléconsultation',
        'date': Timestamp.fromDate(_selectedDate!),
        'timeSlot': _selectedTimeSlot,
        'reason': _reason,
        'status': 'pending', // En attente de confirmation du professionnel
        'fee': _selectedConsultationType == 'physical'
            ? widget.consultationFee
            : widget.teleconsultationFee,
        'createdAt': FieldValue.serverTimestamp(),
        if (videoCallId != null) 'videoCallId': videoCallId,
      };

      await FirebaseFirestore.instance
          .collection('appointments')
          .add(appointment);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.checkmark_circle,
                    color: AppColors.success,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Rendez-vous confirmé !',
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(24),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Votre rendez-vous avec ${widget.doctorName} est confirmé.',
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(16),
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Heure: $_selectedTimeSlot',
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Retour à l\'accueil',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur confirmation rendez-vous: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final maxWidth = isDesktop ? 700.0 : (isTablet ? 600.0 : double.infinity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver un rendez-vous'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            children: [
              // Doctor Info Header
              Container(
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: isDesktop ? 35 : 30,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: widget.photoUrl != null
                          ? NetworkImage(widget.photoUrl!)
                          : null,
                      child: widget.photoUrl == null
                          ? Icon(
                              CupertinoIcons.person,
                              size: isDesktop ? 35 : 30,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.doctorName,
                            style: TextStyle(
                              fontSize: isDesktop ? 20 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.specialty,
                            style: TextStyle(
                              fontSize: isDesktop ? 16 : 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Stepper
              Expanded(
                child: Stepper(
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep == 0) {
                      if (_selectedConsultationType != null) {
                        setState(() {
                          _currentStep = 1;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Veuillez sélectionner un type de consultation',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    } else if (_currentStep == 1) {
                      if (_selectedDate != null && _selectedTimeSlot != null) {
                        setState(() {
                          _currentStep = 2;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _selectedDate == null
                                  ? 'Veuillez sélectionner une date'
                                  : 'Veuillez sélectionner un créneau horaire',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    } else if (_currentStep == 2) {
                      _confirmAppointment();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep--;
                      });
                    }
                  },
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: EdgeInsets.only(
                        top: getProportionateScreenHeight(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: EdgeInsets.symmetric(
                                  vertical: getProportionateScreenHeight(12),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _currentStep == 2 ? 'Confirmer' : 'Continuer',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          if (_currentStep > 0) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: details.onStepCancel,
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: getProportionateScreenHeight(12),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Retour'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  steps: [
                    // Step 1: Type de consultation
                    Step(
                      title: const Text('Type de consultation'),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0
                          ? StepState.complete
                          : StepState.indexed,
                      content: Column(
                        children: [
                          if (widget.offersPhysicalConsultation)
                            _ConsultationTypeOption(
                              title: 'Consultation au cabinet',
                              subtitle:
                                  '${widget.consultationFee.toStringAsFixed(0)} XOF',
                              icon: CupertinoIcons.plus_circle,
                              selected: _selectedConsultationType == 'physical',
                              onTap: () {
                                setState(() {
                                  _selectedConsultationType = 'physical';
                                });
                              },
                            ),
                          if (widget.offersPhysicalConsultation &&
                              widget.offersTelemedicine)
                            const SizedBox(height: 12),
                          if (widget.offersTelemedicine)
                            _ConsultationTypeOption(
                              title: 'Téléconsultation',
                              subtitle:
                                  '${widget.teleconsultationFee.toStringAsFixed(0)} XOF',
                              icon: CupertinoIcons.videocam_fill,
                              selected:
                                  _selectedConsultationType == 'telemedicine',
                              onTap: () {
                                setState(() {
                                  _selectedConsultationType = 'telemedicine';
                                });
                              },
                            ),
                        ],
                      ),
                    ),

                    // Step 2: Date et heure
                    Step(
                      title: const Text('Date et heure'),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1
                          ? StepState.complete
                          : StepState.indexed,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sélectionnez une date',
                            style: TextStyle(
                              fontSize: getProportionateScreenHeight(16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 14,
                              itemBuilder: (context, index) {
                                final date = DateTime.now().add(
                                  Duration(days: index),
                                );
                                final isSelected =
                                    _selectedDate?.day == date.day &&
                                    _selectedDate?.month == date.month;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDate = date;
                                      _selectedTimeSlot = null;
                                    });
                                    _loadAvailableSlots(date);
                                  },
                                  child: Container(
                                    width: 80,
                                    margin: EdgeInsets.only(
                                      right: getProportionateScreenWidth(8),
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _getDayName(
                                            date.weekday,
                                          ).substring(0, 3),
                                          style: TextStyle(
                                            fontSize:
                                                getProportionateScreenHeight(
                                                  12,
                                                ),
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          date.day.toString(),
                                          style: TextStyle(
                                            fontSize:
                                                getProportionateScreenHeight(
                                                  24,
                                                ),
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        Text(
                                          _getMonthName(date.month),
                                          style: TextStyle(
                                            fontSize:
                                                getProportionateScreenHeight(
                                                  12,
                                                ),
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (_selectedDate != null) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Créneaux disponibles',
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(16),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_isLoading)
                              const Center(child: CircularProgressIndicator())
                            else if (_availableSlots.isEmpty)
                              Container(
                                padding: EdgeInsets.all(
                                  getProportionateScreenWidth(16),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.info_circle,
                                      color: Colors.orange[700],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Aucun créneau disponible pour cette date',
                                        style: TextStyle(
                                          fontSize:
                                              getProportionateScreenHeight(14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _availableSlots.values.first
                                    .map(
                                      (slot) => ChoiceChip(
                                        label: Text(slot),
                                        selected: _selectedTimeSlot == slot,
                                        onSelected: (selected) {
                                          setState(() {
                                            _selectedTimeSlot = selected
                                                ? slot
                                                : null;
                                          });
                                        },
                                        selectedColor: AppColors.primary,
                                        labelStyle: TextStyle(
                                          color: _selectedTimeSlot == slot
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                          ],
                        ],
                      ),
                    ),

                    // Step 3: Confirmation
                    Step(
                      title: const Text('Confirmation'),
                      isActive: _currentStep >= 2,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SummaryItem(
                            icon: CupertinoIcons.bag_badge_plus,
                            label: 'Type',
                            value: _selectedConsultationType == 'physical'
                                ? 'Consultation au cabinet'
                                : 'Téléconsultation',
                          ),
                          _SummaryItem(
                            icon: CupertinoIcons.calendar,
                            label: 'Date',
                            value: _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : '',
                          ),
                          _SummaryItem(
                            icon: CupertinoIcons.clock,
                            label: 'Heure',
                            value: _selectedTimeSlot ?? '',
                          ),
                          _SummaryItem(
                            icon: CupertinoIcons.money_euro,
                            label: 'Tarif',
                            value:
                                '${(_selectedConsultationType == 'physical' ? widget.consultationFee : widget.teleconsultationFee).toStringAsFixed(0)} XOF',
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _reasonController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Motif de consultation (optionnel)',
                              hintText: 'Décrivez brièvement votre motif...',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) {
                              _reason = value;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return months[month - 1];
  }
}

class _ConsultationTypeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ConsultationTypeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(getProportionateScreenWidth(16)),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: selected ? AppColors.primary : Colors.grey[300],
              child: Icon(
                icon,
                color: selected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(16),
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.primary : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(18),
                      fontWeight: FontWeight.bold,
                      color: selected ? AppColors.primary : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                CupertinoIcons.checkmark_circle,
                color: AppColors.primary,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: getProportionateScreenHeight(12)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: getProportionateScreenHeight(14),
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: getProportionateScreenHeight(16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
