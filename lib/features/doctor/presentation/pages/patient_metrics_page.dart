import 'package:DoctoLo/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PatientConsultationPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientConsultationPage({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  State<PatientConsultationPage> createState() =>
      _PatientConsultationPageState();
}

class _PatientConsultationPageState extends State<PatientConsultationPage> {
  final TextEditingController diagnosticController = TextEditingController();
  final TextEditingController prescriptionController = TextEditingController();

  bool _isLoading = false;
  DateTime? _consultationStartTime;
  List<Map<String, dynamic>> _weightHistory = [];
  List<Map<String, dynamic>> _heightHistory = [];

  @override
  void initState() {
    super.initState();
    _consultationStartTime = DateTime.now();
    _loadPatientHistory();
  }

  Future<void> _loadPatientHistory() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('medical_records')
          .doc(widget.patientId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final consultations = data['consultations'] as List<dynamic>? ?? [];

        setState(() {
          _weightHistory = consultations
              .where((c) => c['weight'] != null)
              .map(
                (c) => {
                  'date': (c['date'] as Timestamp).toDate(),
                  'value': (c['weight'] as num).toDouble(),
                },
              )
              .toList();

          _heightHistory = consultations
              .where((c) => c['height'] != null)
              .map(
                (c) => {
                  'date': (c['date'] as Timestamp).toDate(),
                  'value': (c['height'] as num).toDouble(),
                },
              )
              .toList();
        });
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'historique : $e');
    }
  }

  Future<void> _generatePrescriptionPdf() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'ORDONNANCE MÉDICALE',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 2, color: PdfColors.blue900),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Date : ${dateFormat.format(now)}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Patient : ${widget.patientName}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'DIAGNOSTIC',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Text(
                    diagnosticController.text,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'PRESCRIPTION',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.blue900, width: 1),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Text(
                    prescriptionController.text,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Signature du médecin'),
                      pw.SizedBox(height: 40),
                      pw.Container(
                        width: 200,
                        height: 1,
                        color: PdfColors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _completeConsultation() async {
    if (diagnosticController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un diagnostic'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final endTime = DateTime.now();
      final duration = endTime.difference(_consultationStartTime!);

      final consultationData = {
        'date': Timestamp.fromDate(endTime),
        'startTime': Timestamp.fromDate(_consultationStartTime!),
        'endTime': Timestamp.fromDate(endTime),
        'duration': duration.inMinutes,
        'diagnostic': diagnosticController.text.trim(),
        'prescription': prescriptionController.text.trim(),
      };

      // 1. Mettre à jour le dossier médical
      final docRef = FirebaseFirestore.instance
          .collection('medical_records')
          .doc(widget.patientId);

      await docRef.set({
        'patientId': widget.patientId,
        'patientName': widget.patientName,
        'lastUpdated': FieldValue.serverTimestamp(),
        'consultations': FieldValue.arrayUnion([consultationData]),
      }, SetOptions(merge: true));

      // 2. Mettre à jour le statut du rendez-vous (appointments)
      final appointmentQuery = await FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: widget.patientId)
          .where('status', isEqualTo: 'in_progress')
          .limit(1)
          .get();
      if (appointmentQuery.docs.isNotEmpty) {
        final appointmentId = appointmentQuery.docs.first.id;
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointmentId)
            .update({
              'status': 'completed',
              'diagnosis': diagnosticController.text.trim(),
              'prescription': prescriptionController.text.trim(),
            });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation enregistrée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;
    final isMobile = screenWidth <= 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.05),
              Colors.cyan.shade50,
              Colors.teal.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(isMobile),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(
                    isMobile
                        ? 16
                        : isTablet
                        ? 24
                        : 32,
                  ),
                  child: isDesktop
                      ? _buildDesktopLayout()
                      : _buildMobileTabletLayout(isMobile),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPatientHeader(false),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildDiagnosticSection(false),
                  const SizedBox(height: 24),
                  _buildPrescriptionSection(false),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildChart(
                    'Évolution du Poids',
                    _weightHistory,
                    Colors.orange,
                    'kg',
                    false,
                  ),
                  const SizedBox(height: 24),
                  _buildChart(
                    'Évolution de la Taille',
                    _heightHistory,
                    AppColors.primary,
                    'cm',
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildDesktopActionButtons(),
      ],
    );
  }

  Widget _buildMobileTabletLayout(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPatientHeader(isMobile),
        const SizedBox(height: 24),
        _buildDiagnosticSection(isMobile),
        const SizedBox(height: 24),
        _buildPrescriptionSection(isMobile),
        const SizedBox(height: 24),
        _buildChart(
          'Évolution du Poids',
          _weightHistory,
          Colors.orange,
          'kg',
          isMobile,
        ),
        const SizedBox(height: 24),
        _buildChart(
          'Évolution de la Taille',
          _heightHistory,
          AppColors.primary,
          'cm',
          isMobile,
        ),
        const SizedBox(height: 32),
        _buildMobileActionButtons(isMobile),
      ],
    );
  }

  Widget _buildAppBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back,
            color: AppColors.primary,
            onPressed: () => Navigator.pop(context),
            isMobile: isMobile,
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Container(
            width: isMobile ? 36 : 40,
            height: isMobile ? 36 : 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medical_services,
              color: AppColors.primary,
              size: isMobile ? 20 : 24,
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consultation Médicale',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isMobile) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.patientName,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (!isMobile) ...[const SizedBox(width: 16), _buildTimerBadge()],
        ],
      ),
    );
  }

  Widget _buildTimerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: AppColors.primary, size: 16),
          const SizedBox(width: 6),
          Text(
            'En cours',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool isMobile,
  }) {
    return Container(
      width: isMobile ? 36 : 40,
      height: isMobile ? 36 : 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: IconButton(
        icon: Icon(icon, size: isMobile ? 20 : 22),
        color: color,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildPatientHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 48 : 56,
            height: isMobile ? 48 : 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Colors.blueAccent.shade400],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: isMobile ? 24 : 28,
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.patientName,
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Consultation en cours',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (isMobile) _buildTimerBadge(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.green.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isMobile ? 32 : 36,
                height: isMobile ? 32 : 36,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.doc_text,
                  color: Colors.green,
                  size: isMobile ? 18 : 20,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnostic',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Analyse médicale',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: isMobile ? 12 : 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: diagnosticController,
              maxLines: isMobile ? 4 : 6,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: isMobile ? 14 : 15,
              ),
              decoration: InputDecoration(
                hintText: 'Saisissez le diagnostic du patient...',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: isMobile ? 14 : 15,
                  color: Colors.grey.shade500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.purple.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: isMobile ? 32 : 36,
                    height: isMobile ? 32 : 36,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      CupertinoIcons.capsule,
                      color: Colors.purple,
                      size: isMobile ? 18 : 20,
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ordonnance',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Prescription médicale',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: isMobile ? 12 : 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildIconButton(
                icon: CupertinoIcons.doc_on_clipboard,
                color: Colors.red,
                onPressed: () {
                  prescriptionController.text.isNotEmpty
                      ? _generatePrescriptionPdf()
                      : null;
                },
                isMobile: isMobile,
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.purple.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: prescriptionController,
              maxLines: isMobile ? 4 : 6,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: isMobile ? 14 : 15,
              ),
              decoration: InputDecoration(
                hintText: 'Saisissez l\'ordonnance médicale...',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: isMobile ? 14 : 15,
                  color: Colors.grey.shade500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(
    String title,
    List<Map<String, dynamic>> data,
    Color color,
    String unit,
    bool isMobile,
  ) {
    if (data.isEmpty) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100, width: 1),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 24 : 32),
            Column(
              children: [
                Icon(
                  Icons.show_chart,
                  color: Colors.grey.shade300,
                  size: isMobile ? 48 : 56,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune donnée disponible',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontFamily: 'Poppins',
                    fontSize: isMobile ? 14 : 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unit',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 20 : 24),
          SizedBox(
            height: isMobile ? 200 : 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade100,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          final date = data[value.toInt()]['date'] as DateTime;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('dd/MM').format(date),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: 'Poppins',
                                fontSize: isMobile ? 10 : 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      reservedSize: isMobile ? 40 : 45,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                            fontSize: isMobile ? 10 : 11,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: data.length - 1.0,
                minY:
                    data
                        .map((e) => e['value'] as double)
                        .reduce((a, b) => a < b ? a : b) -
                    10,
                maxY:
                    data
                        .map((e) => e['value'] as double)
                        .reduce((a, b) => a > b ? a : b) +
                    10,
                lineBarsData: [
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map(
                          (e) => FlSpot(
                            e.key.toDouble(),
                            e.value['value'] as double,
                          ),
                        )
                        .toList(),
                    isCurved: true,
                    color: color,
                    barWidth: isMobile ? 2.5 : 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: isMobile ? 3 : 3.5,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: color,
                        );
                      },
                    ),
                    shadow: Shadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.3),
                          color.withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTextButton(
            icon: Icons.cancel_outlined,
            label: 'Annuler',
            color: Colors.grey,
            onPressed: () => Navigator.pop(context),
            isDesktop: true,
          ),
          const SizedBox(width: 16),
          _buildElevatedButton(
            icon: _isLoading ? null : Icons.check_circle,
            label: _isLoading ? 'Enregistrement...' : 'Terminer',
            color: Colors.green,
            onPressed: _isLoading ? null : _completeConsultation,
            isLoading: _isLoading,
            isDesktop: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileActionButtons(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildElevatedButton(
            icon: _isLoading ? null : Icons.check_circle,
            label: _isLoading
                ? 'Enregistrement...'
                : 'Terminer la consultation',
            color: Colors.green,
            onPressed: _isLoading ? null : _completeConsultation,
            isLoading: _isLoading,
            isDesktop: false,
          ),
          const SizedBox(height: 12),
          _buildTextButton(
            icon: Icons.cancel_outlined,
            label: 'Annuler',
            color: Colors.grey,
            onPressed: () => Navigator.pop(context),
            isDesktop: false,
          ),
        ],
      ),
    );
  }

  Widget _buildElevatedButton({
    required IconData? icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    required bool isLoading,
    required bool isDesktop,
  }) {
    return SizedBox(
      width: isDesktop ? 180 : double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : 16,
            vertical: isDesktop ? 16 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          side: BorderSide.none,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else if (icon != null)
              Icon(icon, size: 20),
            if (icon != null || isLoading) SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isDesktop ? 15 : 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isDesktop,
  }) {
    return SizedBox(
      width: isDesktop ? 140 : double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 16,
            vertical: isDesktop ? 16 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isDesktop ? 15 : 16,
                  fontFamily: 'Poppins',
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    diagnosticController.dispose();
    prescriptionController.dispose();
    super.dispose();
  }
}
