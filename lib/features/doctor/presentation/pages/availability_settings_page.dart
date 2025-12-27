import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/size_config.dart';

class AvailabilitySettingsPage extends StatefulWidget {
  final String doctorId;
  final String userId;

  const AvailabilitySettingsPage({
    super.key,
    required this.doctorId,
    required this.userId,
  });

  @override
  State<AvailabilitySettingsPage> createState() =>
      _AvailabilitySettingsPageState();
}

class _AvailabilitySettingsPageState extends State<AvailabilitySettingsPage> {
  final Map<String, List<TimeSlot>> _availability = {
    'Lundi': [],
    'Mardi': [],
    'Mercredi': [],
    'Jeudi': [],
    'Vendredi': [],
    'Samedi': [],
    'Dimanche': [],
  };

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .get();

      if (doc.exists && doc.data()?['availability'] != null) {
        final availabilityData =
            doc.data()!['availability'] as Map<String, dynamic>;

        setState(() {
          availabilityData.forEach((day, slots) {
            if (slots is List) {
              _availability[day] = (slots)
                  .map(
                    (slot) => TimeSlot(
                      start: TimeOfDay(
                        hour: int.parse(slot['start'].split(':')[0]),
                        minute: int.parse(slot['start'].split(':')[1]),
                      ),
                      end: TimeOfDay(
                        hour: int.parse(slot['end'].split(':')[0]),
                        minute: int.parse(slot['end'].split(':')[1]),
                      ),
                    ),
                  )
                  .toList();
            }
          });
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement disponibilités: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAvailability() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final Map<String, List<Map<String, String>>> availabilityData = {};

      _availability.forEach((day, slots) {
        if (slots.isNotEmpty) {
          availabilityData[day] = slots
              .map(
                (slot) => {
                  'start':
                      '${slot.start.hour.toString().padLeft(2, '0')}:${slot.start.minute.toString().padLeft(2, '0')}',
                  'end':
                      '${slot.end.hour.toString().padLeft(2, '0')}:${slot.end.minute.toString().padLeft(2, '0')}',
                },
              )
              .toList();
        }
      });

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .set({
            'availability': availabilityData,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.availabilitySaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur sauvegarde disponibilités: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorOccurred),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _addTimeSlot(String day) {
    setState(() {
      _availability[day]!.add(
        TimeSlot(
          start: const TimeOfDay(hour: 9, minute: 0),
          end: const TimeOfDay(hour: 17, minute: 0),
        ),
      );
    });
  }

  void _removeTimeSlot(String day, int index) {
    setState(() {
      _availability[day]!.removeAt(index);
    });
  }

  Future<void> _selectTime(String day, int index, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? _availability[day]![index].start
          : _availability[day]![index].end,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _availability[day]![index].start = picked;
        } else {
          _availability[day]![index].end = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myAvailability),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_isSaving)
            Center(
              child: Padding(
                padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(CupertinoIcons.floppy_disk),
              onPressed: _saveAvailability,
              tooltip: l10n.save,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(getProportionateScreenWidth(16)),
              itemCount: _availability.length,
              itemBuilder: (context, index) {
                final day = _availability.keys.elementAt(index);
                final slots = _availability[day]!;

                return Card(
                  margin: EdgeInsets.only(
                    bottom: getProportionateScreenHeight(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              day,
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(18),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.add_circled,
                                color: AppColors.primary,
                              ),
                              onPressed: () => _addTimeSlot(day),
                              tooltip: 'Ajouter un créneau',
                            ),
                          ],
                        ),
                        if (slots.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: getProportionateScreenHeight(8),
                            ),
                            child: Text(
                              'Pas de disponibilités',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        else
                          ...slots.asMap().entries.map((entry) {
                            final slotIndex = entry.key;
                            final slot = entry.value;

                            return Padding(
                              padding: EdgeInsets.only(
                                top: getProportionateScreenHeight(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _selectTime(day, slotIndex, true),
                                      child: Text(
                                        slot.start.format(context),
                                        style: TextStyle(
                                          fontSize:
                                              getProportionateScreenHeight(16),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      '→',
                                      style: TextStyle(
                                        fontSize: getProportionateScreenHeight(
                                          20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _selectTime(day, slotIndex, false),
                                      child: Text(
                                        slot.end.format(context),
                                        style: TextStyle(
                                          fontSize:
                                              getProportionateScreenHeight(16),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      CupertinoIcons.trash,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _removeTimeSlot(day, slotIndex),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveAvailability,
        backgroundColor: AppColors.primary,
        icon: const Icon(CupertinoIcons.floppy_disk, color: Colors.white),
        label: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class TimeSlot {
  TimeOfDay start;
  TimeOfDay end;

  TimeSlot({required this.start, required this.end});
}
