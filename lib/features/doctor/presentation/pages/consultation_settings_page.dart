import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../shared/widgets/currency_widgets.dart';

class ConsultationSettingsPage extends StatefulWidget {
  final String doctorId;
  final String userId;

  const ConsultationSettingsPage({
    super.key,
    required this.doctorId,
    required this.userId,
  });

  @override
  State<ConsultationSettingsPage> createState() =>
      _ConsultationSettingsPageState();
}

class _ConsultationSettingsPageState extends State<ConsultationSettingsPage> {
  bool _offersPhysicalConsultation = true;
  bool _offersTelemedicine = true;
  bool _acceptsNewPatients = true;

  final TextEditingController _physicalFeeController = TextEditingController();
  final TextEditingController _teleFeeController = TextEditingController();
  final TextEditingController _consultationDurationController =
      TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _physicalFeeController.dispose();
    _teleFeeController.dispose();
    _consultationDurationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _offersTelemedicine = data['offersTelemedicine'] ?? true;
          _offersPhysicalConsultation =
              data['offersPhysicalConsultation'] ?? true;
          _acceptsNewPatients = data['acceptsNewPatients'] ?? true;
          _physicalFeeController.text = (data['consultationFee'] ?? 50.0)
              .toString();
          _teleFeeController.text = (data['teleconsultationFee'] ?? 40.0)
              .toString();
          _consultationDurationController.text =
              (data['consultationDuration'] ?? 30).toString();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement paramètres: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_offersPhysicalConsultation && !_offersTelemedicine) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.youMustOfferAtLeastOne),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updates = <String, dynamic>{
        'offersTelemedicine': _offersTelemedicine,
        'offersPhysicalConsultation': _offersPhysicalConsultation,
        'acceptsNewPatients': _acceptsNewPatients,
        'consultationFee': double.tryParse(_physicalFeeController.text) ?? 50.0,
        'teleconsultationFee': double.tryParse(_teleFeeController.text) ?? 40.0,
        'consultationDuration':
            int.tryParse(_consultationDurationController.text) ?? 30,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .update(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.settingsSavedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur sauvegarde paramètres: $e');
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.consultationTypes),
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
              onPressed: _saveSettings,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(getProportionateScreenWidth(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Types de consultation
                  Text(
                    l10n.consultationTypes,
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(l10n.consultationAtOffice),
                          subtitle: Text(l10n.physicalConsultation),
                          value: _offersPhysicalConsultation,
                          onChanged: (value) {
                            setState(() {
                              _offersPhysicalConsultation = value;
                            });
                          },
                          secondary: Icon(
                            CupertinoIcons.plus_circle,
                            color: AppColors.primary,
                          ),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: Text(l10n.telemedicine),
                          subtitle: Text(l10n.consultationByVideo),
                          value: _offersTelemedicine,
                          onChanged: (value) {
                            setState(() {
                              _offersTelemedicine = value;
                            });
                          },
                          secondary: Icon(
                            CupertinoIcons.videocam_fill,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tarifs
                  Text(
                    'Tarifs',
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_offersPhysicalConsultation) ...[
                    TextField(
                      controller: _physicalFeeController,
                      decoration: InputDecoration(
                        labelText: 'Tarif consultation physique',
                        suffix: const CurrencyDisplay(),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_offersTelemedicine) ...[
                    TextField(
                      controller: _teleFeeController,
                      decoration: InputDecoration(
                        labelText: 'Tarif téléconsultation',
                        suffix: const CurrencyDisplay(),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Durée
                  TextField(
                    controller: _consultationDurationController,
                    decoration: InputDecoration(
                      labelText: 'Durée d\'une consultation',
                      suffixText: 'minutes',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(CupertinoIcons.clock),
                      helperText: 'Durée moyenne d\'une consultation',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 24),

                  // Nouveaux patients
                  Text(
                    'Disponibilité',
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    child: SwitchListTile(
                      title: const Text('Accepter de nouveaux patients'),
                      subtitle: const Text(
                        'Afficher mon profil dans les recherches',
                      ),
                      value: _acceptsNewPatients,
                      onChanged: (value) {
                        setState(() {
                          _acceptsNewPatients = value;
                        });
                      },
                      secondary: Icon(
                        CupertinoIcons.person_2_fill,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveSettings,
        backgroundColor: AppColors.primary,
        icon: const Icon(CupertinoIcons.floppy_disk, color: Colors.white),
        label: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
