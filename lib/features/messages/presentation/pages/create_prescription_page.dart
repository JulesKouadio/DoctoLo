import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';

class CreatePrescriptionPage extends StatefulWidget {
  final String doctorName;
  final String patientName;

  const CreatePrescriptionPage({
    super.key,
    required this.doctorName,
    required this.patientName,
  });

  @override
  State<CreatePrescriptionPage> createState() => _CreatePrescriptionPageState();
}

class _CreatePrescriptionPageState extends State<CreatePrescriptionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clinicController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, String>> _medications = [
    {'name': '', 'dosage': '', 'duration': ''},
  ];

  bool _isGenerating = false;

  @override
  void dispose() {
    _clinicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addMedication() {
    setState(() {
      _medications.add({'name': '', 'dosage': '', 'duration': ''});
    });
  }

  void _removeMedication(int index) {
    if (_medications.length > 1) {
      setState(() {
        _medications.removeAt(index);
      });
    }
  }

  Future<File> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      _clinicController.text.isEmpty
                          ? 'Cabinet Médical'
                          : _clinicController.text,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Dr. ${widget.doctorName}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.blue700,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Informations patient
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PATIENT',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      widget.patientName,
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Titre Ordonnance
              pw.Center(
                child: pw.Text(
                  'ORDONNANCE MÉDICALE',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Liste des médicaments
              ...(_medications.asMap().entries.map((entry) {
                final index = entry.key;
                final med = entry.value;
                if (med['name']?.isEmpty ?? true) return pw.SizedBox();

                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 15),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 25,
                            height: 25,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.blue,
                              shape: pw.BoxShape.circle,
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                '${index + 1}',
                                style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 10),
                          pw.Expanded(
                            child: pw.Text(
                              med['name'] ?? '',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (med['dosage']?.isNotEmpty ?? false) ...[
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Posologie: ${med['dosage']}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                      if (med['duration']?.isNotEmpty ?? false) ...[
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'Durée: ${med['duration']}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList()),

              // Notes
              if (_notesController.text.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.yellow50,
                    border: pw.Border.all(color: PdfColors.yellow700),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Notes:',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        _notesController.text,
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],

              pw.Spacer(),

              // Signature
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Signature et cachet',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 30),
                      pw.Container(
                        width: 150,
                        height: 1,
                        color: PdfColors.grey400,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Dr. ${widget.doctorName}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final fileName = 'ordonnance_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  Future<void> _createPrescription() async {
    if (!_formKey.currentState!.validate()) return;

    // Vérifier qu'il y a au moins un médicament
    final hasValidMedication = _medications.any(
      (med) => med['name']?.isNotEmpty ?? false,
    );

    if (!hasValidMedication) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins un médicament'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final pdfFile = await _generatePDF();

      if (!mounted) return;

      Navigator.pop(context, pdfFile);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Créer une ordonnance',
          style: TextStyle(
            color: Colors.white,
            fontSize: getProportionateScreenHeight(18),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isGenerating)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _createPrescription,
              child: Text(
                'Créer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: getProportionateScreenHeight(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(getProportionateScreenWidth(16)),
          children: [
            // Informations générales
            Card(
              child: Padding(
                padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations générales',
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _clinicController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de la clinique',
                        hintText: 'Cabinet Médical',
                        prefixIcon: Icon(CupertinoIcons.building_2_fill),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(getProportionateScreenWidth(12)),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.person_badge_plus,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Docteur: ${widget.doctorName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.person,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Patient: ${widget.patientName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Médicaments
            Card(
              child: Padding(
                padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Médicaments',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: _addMedication,
                          icon: const Icon(CupertinoIcons.add_circled_solid),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._medications.asMap().entries.map((entry) {
                      final index = entry.key;
                      return _MedicationField(
                        index: index,
                        medication: entry.value,
                        onRemove: () => _removeMedication(index),
                        canRemove: _medications.length > 1,
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            Card(
              child: Padding(
                padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes (optionnel)',
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText:
                            'Ajoutez des recommandations ou instructions supplémentaires...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationField extends StatefulWidget {
  final int index;
  final Map<String, String> medication;
  final VoidCallback onRemove;
  final bool canRemove;

  const _MedicationField({
    required this.index,
    required this.medication,
    required this.onRemove,
    required this.canRemove,
  });

  @override
  State<_MedicationField> createState() => _MedicationFieldState();
}

class _MedicationFieldState extends State<_MedicationField> {
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication['name']);
    _dosageController = TextEditingController(
      text: widget.medication['dosage'],
    );
    _durationController = TextEditingController(
      text: widget.medication['duration'],
    );

    _nameController.addListener(() {
      widget.medication['name'] = _nameController.text;
    });
    _dosageController.addListener(() {
      widget.medication['dosage'] = _dosageController.text;
    });
    _durationController.addListener(() {
      widget.medication['duration'] = _durationController.text;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: getProportionateScreenHeight(16)),
      padding: EdgeInsets.all(getProportionateScreenWidth(12)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${widget.index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Médicament',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: getProportionateScreenHeight(16),
                  ),
                ),
              ),
              if (widget.canRemove)
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(CupertinoIcons.trash, size: 20),
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nom du médicament *',
              hintText: 'Ex: Paracétamol 500mg',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nom requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dosageController,
            decoration: const InputDecoration(
              labelText: 'Posologie',
              hintText: 'Ex: 1 comprimé 3 fois par jour',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _durationController,
            decoration: const InputDecoration(
              labelText: 'Durée',
              hintText: 'Ex: 7 jours',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
