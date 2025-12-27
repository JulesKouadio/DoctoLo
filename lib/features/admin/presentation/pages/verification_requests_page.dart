import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';

class VerificationRequestsPage extends StatefulWidget {
  const VerificationRequestsPage({super.key});

  @override
  State<VerificationRequestsPage> createState() =>
      _VerificationRequestsPageState();
}

class _VerificationRequestsPageState extends State<VerificationRequestsPage> {
  String _selectedFilter = 'pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes de vérification'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            color: Colors.white,
            child: Row(
              children: [
                _buildFilterChip('En attente', 'pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Approuvées', 'approved'),
                const SizedBox(width: 8),
                _buildFilterChip('Rejetées', 'rejected'),
              ],
            ),
          ),

          // Liste des demandes
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .where('verificationStatus', isEqualTo: _selectedFilter)
                  .orderBy('submittedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.doc_text_search,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune demande',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(18),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildRequestCard(context, docs[index].id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16), vertical: getProportionateScreenHeight(8)),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    String doctorId,
    Map<String, dynamic> data,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: getProportionateScreenHeight(16)),
      child: Padding(
        padding: EdgeInsets.all(getProportionateScreenWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec statut
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(
                    CupertinoIcons.person,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(data['userId'])
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text('Chargement...');
                      }
                      final userData =
                          snapshot.data?.data() as Map<String, dynamic>?;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: getProportionateScreenHeight(16),
                            ),
                          ),
                          Text(
                            userData?['email'] ?? '',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: getProportionateScreenHeight(14),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                _buildStatusBadge(data['verificationStatus']),
              ],
            ),
            const Divider(height: 24),

            // Informations
            _buildInfoRow(
              CupertinoIcons.doc_text,
              'ID Médecin',
              data['medicalId'] ?? 'N/A',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              CupertinoIcons.heart,
              'Spécialité',
              data['specialty'] ?? 'N/A',
            ),
            const SizedBox(height: 16),

            // Photos CNI
            Row(
              children: [
                Expanded(child: _buildCNIImage('Recto', data['cniRectoUrl'])),
                const SizedBox(width: 8),
                Expanded(child: _buildCNIImage('Verso', data['cniVersoUrl'])),
              ],
            ),

            // Actions (seulement pour les demandes en attente)
            if (data['verificationStatus'] == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveRequest(doctorId, data),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(CupertinoIcons.check_mark),
                      label: const Text('Approuver'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectRequest(doctorId, data),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(CupertinoIcons.xmark),
                      label: const Text('Rejeter'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'approved':
        color = AppColors.success;
        label = 'Approuvé';
        icon = CupertinoIcons.check_mark_circled_solid;
        break;
      case 'rejected':
        color = AppColors.error;
        label = 'Rejeté';
        icon = CupertinoIcons.xmark_circle_fill;
        break;
      default:
        color = AppColors.warning;
        label = 'En attente';
        icon = CupertinoIcons.clock_fill;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(12), vertical: getProportionateScreenHeight(6)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: getProportionateScreenHeight(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: getProportionateScreenHeight(14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: getProportionateScreenHeight(14),
          ),
        ),
      ],
    );
  }

  Widget _buildCNIImage(String label, String? url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: getProportionateScreenHeight(12),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: url != null ? () => _showFullImage(url) : null,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: url != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(CupertinoIcons.exclamationmark_triangle),
                        );
                      },
                    ),
                  )
                : const Center(child: Icon(CupertinoIcons.photo)),
          ),
        ),
      ],
    );
  }

  void _showFullImage(String url) {
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(child: InteractiveViewer(child: Image.network(url))),
    );
  }

  Future<void> _approveRequest(
    String doctorId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Mettre à jour le statut du doctor
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .update({
            'verificationStatus': 'approved',
            'approvedAt': FieldValue.serverTimestamp(),
            'isVerified': true,
          });

      // Mettre à jour le user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(data['userId'])
          .update({'verificationStatus': 'approved', 'isVerified': true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Professionnel approuvé avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _rejectRequest(
    String doctorId,
    Map<String, dynamic> data,
  ) async {
    // Demander une raison
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Raison du rejet'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Expliquez pourquoi la demande est rejetée',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );

    if (reason == null || reason.isEmpty) return;

    try {
      // Mettre à jour le statut du doctor
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .update({
            'verificationStatus': 'rejected',
            'rejectedAt': FieldValue.serverTimestamp(),
            'rejectionReason': reason,
            'isVerified': false,
          });

      // Mettre à jour le user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(data['userId'])
          .update({'verificationStatus': 'rejected'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande rejetée'),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
      );
    }
  }
}
