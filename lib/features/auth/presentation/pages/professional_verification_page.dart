import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/constants/app_constants.dart';

class ProfessionalVerificationPage extends StatefulWidget {
  final String userId;

  const ProfessionalVerificationPage({super.key, required this.userId});

  @override
  State<ProfessionalVerificationPage> createState() =>
      _ProfessionalVerificationPageState();
}

class _ProfessionalVerificationPageState
    extends State<ProfessionalVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _medicalIdController = TextEditingController();
  final _specialtyController = TextEditingController();

  String? _selectedSpecialty;
  File? _cniRectoImage;
  File? _cniVersoImage;
  bool _isSubmitting = false;
  bool _emailVerified = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      setState(() {
        _emailVerified = user.emailVerified;
      });
    }
  }

  Future<void> _sendVerificationEmail() async {
    // DÉSACTIVÉ - Ne plus envoyer d'emails de vérification
    /*
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de vérification envoyé'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
      );
    }
    */
  }

  Future<void> _pickImage(bool isRecto) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isRecto) {
            _cniRectoImage = File(image.path);
          } else {
            _cniVersoImage = File(image.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la capture: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<String?> _saveImageLocally(File image, String fileName) async {
    try {
      // Obtenir le répertoire de stockage permanent de l'application
      final directory = await getApplicationDocumentsDirectory();
      final userDir = Directory(
        '${directory.path}/verification_documents/${widget.userId}',
      );

      // Créer le dossier s'il n'existe pas
      if (!await userDir.exists()) {
        await userDir.create(recursive: true);
      }

      // Copier le fichier dans le stockage local
      final localPath = '${userDir.path}/$fileName';
      await image.copy(localPath);

      print('✅ Image sauvegardée localement: $localPath');
      return localPath; // Retourner le chemin local au lieu d'une URL
    } catch (e) {
      print('❌ Erreur sauvegarde locale: $e');
      return null;
    }
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;

    if (_cniRectoImage == null || _cniVersoImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez fournir les deux faces de votre CNI'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Vérification d'email DÉSACTIVÉE
    // if (!_emailVerified) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Veuillez vérifier votre email avant de continuer'),
    //       backgroundColor: AppColors.error,
    //     ),
    //   );
    //   return;
    // }

    setState(() => _isSubmitting = true);

    try {
      // Sauvegarde locale des images CNI
      final rectoPath = await _saveImageLocally(
        _cniRectoImage!,
        'cni_recto.jpg',
      );
      final versoPath = await _saveImageLocally(
        _cniVersoImage!,
        'cni_verso.jpg',
      );

      if (rectoPath == null || versoPath == null) {
        throw Exception('Erreur lors de la sauvegarde locale des images');
      }

      // Créer le document doctor
      final doctorData = {
        'userId': widget.userId,
        'medicalId': _medicalIdController.text.trim(),
        'specialty': _selectedSpecialty,
        'cniRectoPath': rectoPath, // Chemin local au lieu d'URL
        'cniVersoPath': versoPath, // Chemin local au lieu d'URL
        'verificationStatus': 'pending', // pending, approved, rejected
        'submittedAt': FieldValue.serverTimestamp(),
        'isVerified': false,
        'rating': 0.0,
        'reviewCount': 0,
      };

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.userId)
          .set(doctorData);

      // Mettre à jour le champ isProfessional dans users
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'isProfessional': true, 'verificationStatus': 'pending'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Demande de vérification envoyée. Vous serez notifié une fois approuvé.',
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Retour à la page précédente
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('Erreur soumission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _medicalIdController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;
    final adaptive = AdaptiveValues(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification Professionnelle'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            adaptive.spacing(mobile: 16, tablet: 24, desktop: 32),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: deviceType == DeviceType.desktop
                    ? 600
                    : deviceType == DeviceType.tablet
                    ? 550
                    : double.infinity,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info card
                    Card(
                      color: AppColors.primary.withOpacity(0.05),
                      child: Padding(
                        padding: EdgeInsets.all(
                          adaptive.spacing(mobile: 16, desktop: 24),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              CupertinoIcons.info_circle,
                              color: AppColors.primary,
                              size: deviceType == DeviceType.desktop ? 56 : 48,
                            ),
                            SizedBox(
                              height: adaptive.spacing(mobile: 12, desktop: 16),
                            ),
                            Text(
                              'Vérification Obligatoire',
                              style: TextStyle(
                                fontSize: deviceType == DeviceType.desktop
                                    ? 22
                                    : 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(
                              height: adaptive.spacing(mobile: 8, desktop: 12),
                            ),
                            Text(
                              'Pour apparaître dans les résultats de recherche, vous devez fournir :',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: deviceType == DeviceType.desktop
                                    ? 16
                                    : 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: adaptive.spacing(mobile: 12, desktop: 16),
                            ),
                            _buildRequirement(
                              'Identifiant médecin valide',
                              deviceType,
                            ),
                            _buildRequirement(
                              'Photo recto de votre CNI',
                              deviceType,
                            ),
                            _buildRequirement(
                              'Photo verso de votre CNI',
                              deviceType,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: adaptive.spacing(mobile: 24, desktop: 32)),

                    // Identifiant médecin
                    TextFormField(
                      controller: _medicalIdController,
                      style: TextStyle(
                        fontSize: deviceType == DeviceType.desktop ? 16 : 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Identifiant Médecin',
                        hintText: 'Ex: ORD123456',
                        prefixIcon: const Icon(CupertinoIcons.doc_text),
                        border: const OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: deviceType == DeviceType.desktop ? 20 : 16,
                          horizontal: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Identifiant requis';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: adaptive.spacing(mobile: 16, desktop: 20)),

                    // Spécialité
                    DropdownButtonFormField<String>(
                      value: _selectedSpecialty,
                      style: TextStyle(
                        fontSize: deviceType == DeviceType.desktop ? 16 : 14,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Spécialité',
                        prefixIcon: const Icon(CupertinoIcons.heart),
                        border: const OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: deviceType == DeviceType.desktop ? 20 : 16,
                          horizontal: 16,
                        ),
                      ),
                      items: AppConstants.medicalSpecialties.map((specialty) {
                        return DropdownMenuItem(
                          value: specialty,
                          child: Text(specialty),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedSpecialty = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Spécialité requise';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: adaptive.spacing(mobile: 24, desktop: 32)),

                    // CNI Photos en Row sur desktop/tablet
                    if (deviceType != DeviceType.mobile) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Photo CNI Recto',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontSize:
                                            deviceType == DeviceType.desktop
                                            ? 18
                                            : 16,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                _buildImagePicker(
                                  true,
                                  _cniRectoImage,
                                  deviceType,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: adaptive.spacing(mobile: 16, desktop: 24),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Photo CNI Verso',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontSize:
                                            deviceType == DeviceType.desktop
                                            ? 18
                                            : 16,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                _buildImagePicker(
                                  false,
                                  _cniVersoImage,
                                  deviceType,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // CNI Recto
                      Text(
                        'Photo CNI Recto',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildImagePicker(true, _cniRectoImage, deviceType),
                      const SizedBox(height: 16),

                      // CNI Verso
                      Text(
                        'Photo CNI Verso',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildImagePicker(false, _cniVersoImage, deviceType),
                    ],
                    SizedBox(height: adaptive.spacing(mobile: 32, desktop: 40)),

                    // Submit button
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: deviceType == DeviceType.desktop ? 18 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              height: deviceType == DeviceType.desktop
                                  ? 22
                                  : 20,
                              width: deviceType == DeviceType.desktop ? 22 : 20,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Soumettre pour vérification',
                              style: TextStyle(
                                fontSize: deviceType == DeviceType.desktop
                                    ? 17
                                    : 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, DeviceType deviceType) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: deviceType == DeviceType.desktop ? 6 : 4,
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.checkmark_circle_fill,
            size: deviceType == DeviceType.desktop ? 20 : 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: deviceType == DeviceType.desktop ? 15 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(bool isRecto, File? image, DeviceType deviceType) {
    return GestureDetector(
      onTap: () => _pickImage(isRecto),
      child: Container(
        height: deviceType == DeviceType.desktop ? 220 : 180,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: image != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.xmark_circle_fill),
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          if (isRecto) {
                            _cniRectoImage = null;
                          } else {
                            _cniVersoImage = null;
                          }
                        });
                      },
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.camera,
                    size: deviceType == DeviceType.desktop ? 56 : 48,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: deviceType == DeviceType.desktop ? 12 : 8),
                  Text(
                    'Prendre une photo',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: deviceType == DeviceType.desktop ? 17 : 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
