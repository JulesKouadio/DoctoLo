import 'dart:io';
import 'package:DoctoLo/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';

class DocumentsManagementPage extends StatefulWidget {
  final String doctorId;
  final String userId;

  const DocumentsManagementPage({
    super.key,
    required this.doctorId,
    required this.userId,
  });

  @override
  State<DocumentsManagementPage> createState() =>
      _DocumentsManagementPageState();
}

class _DocumentsManagementPageState extends State<DocumentsManagementPage> {
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .get();

      if (doc.exists && doc.data()?['documents'] != null) {
        setState(() {
          _documents = List<Map<String, dynamic>>.from(
            doc.data()!['documents'],
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement documents: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Demander le type de document
        final docType = await _showDocumentTypeDialog();
        if (docType == null) return;

        setState(() {
          _isUploading = true;
        });

        // Upload vers Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child(
          'doctors/${widget.userId}/documents/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
        );

        File fileToUpload;
        if (file.path != null) {
          fileToUpload = File(file.path!);
        } else {
          throw Exception('Impossible de lire le fichier');
        }

        final uploadTask = await storageRef.putFile(fileToUpload);
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        // Ajouter à Firestore
        final newDoc = {
          'name': file.name,
          'type': docType,
          'url': downloadUrl,
          'uploadedAt': Timestamp.now(),
          'size': file.size,
        };

        _documents.add(newDoc);

        await FirebaseFirestore.instance
            .collection('doctors')
            .doc(widget.doctorId)
            .update({
              'documents': _documents,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Document ajouté'),
              backgroundColor: Colors.green,
            ),
          );
        }

        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur upload document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<String?> _showDocumentTypeDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Type de document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('CV'),
              leading: const Icon(CupertinoIcons.doc_text),
              onTap: () => Navigator.pop(context, 'cv'),
            ),
            ListTile(
              title: const Text('Diplôme'),
              leading: const Icon(CupertinoIcons.book),
              onTap: () => Navigator.pop(context, 'diploma'),
            ),
            ListTile(
              title: const Text('Certification'),
              leading: const Icon(CupertinoIcons.checkmark_seal_fill),
              onTap: () => Navigator.pop(context, 'certification'),
            ),
            ListTile(
              title: const Text('Autre'),
              leading: const Icon(CupertinoIcons.folder_fill),
              onTap: () => Navigator.pop(context, 'other'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteDocument(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le document'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce document ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() {
        _isUploading = true;
      });

      // Supprimer de Storage
      final doc = _documents[index];
      if (doc['url'] != null) {
        try {
          await FirebaseStorage.instance.refFromURL(doc['url']).delete();
        } catch (e) {
          print('⚠️ Erreur suppression Storage: $e');
        }
      }

      // Supprimer de la liste
      _documents.removeAt(index);

      // Mettre à jour Firestore
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .update({
            'documents': _documents,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Document supprimé'),
            backgroundColor: Colors.green,
          ),
        );
      }

      setState(() {
        _isUploading = false;
      });
    } catch (e) {
      print('❌ Erreur suppression document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() {
        _isUploading = false;
      });
    }
  }

  IconData _getDocumentIcon(String type) {
    switch (type) {
      case 'cv':
        return CupertinoIcons.doc_text;
      case 'diploma':
        return CupertinoIcons.book;
      case 'certification':
        return CupertinoIcons.checkmark_seal_fill;
      default:
        return CupertinoIcons.folder_fill;
    }
  }

  String _getDocumentTypeLabel(String type) {
    switch (type) {
      case 'cv':
        return 'CV';
      case 'diploma':
        return 'Diplôme';
      case 'certification':
        return 'Certification';
      default:
        return 'Autre';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cvAndDiplomas),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.folder_open,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun document',
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(18),
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez votre CV et vos diplômes',
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(14),
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(getProportionateScreenWidth(16)),
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                final doc = _documents[index];
                final uploadedAt = (doc['uploadedAt'] as Timestamp).toDate();

                return Card(
                  margin: EdgeInsets.only(bottom: getProportionateScreenHeight(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        _getDocumentIcon(doc['type']),
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      doc['name'] ?? 'Document',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_getDocumentTypeLabel(doc['type'])),
                        Text(
                          '${_formatFileSize(doc['size'] ?? 0)} • ${uploadedAt.day}/${uploadedAt.month}/${uploadedAt.year}',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(12),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.arrow_up_right_square,
                          ),
                          color: AppColors.primary,
                          onPressed: () async {
                            final url = _documents[index]['url'];
                            if (url != null) {
                              final uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Impossible d\'ouvrir le document',
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.trash),
                          color: Colors.red,
                          onPressed: () => _deleteDocument(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _pickAndUploadDocument,
        backgroundColor: AppColors.primary,
        icon: _isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(CupertinoIcons.add, color: Colors.white),
        label: Text(
          _isUploading ? 'Upload...' : 'Ajouter',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
