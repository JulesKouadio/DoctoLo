import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification Professionnelle'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(getProportionateScreenWidth(16)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Card(
                color: AppColors.primary,
                child: Padding(
                  padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                  child: Column(
                    children: [
                      const Icon(
                        CupertinoIcons.info_circle,
                        color: AppColors.primary,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Vérification Obligatoire',
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(18),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pour apparaître dans les résultats de recherche, vous devez fournir :',
                        style: TextStyle(color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      _buildRequirement('Identifiant médecin valide'),
                      _buildRequirement('Photo recto de votre CNI'),
                      _buildRequirement('Photo verso de votre CNI'),
                      // _buildRequirement('Email vérifié'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Email verification
              // Card(
              //   child: ListTile(
              //     leading: Icon(
              //       _emailVerified
              //           ? CupertinoIcons.check_mark_circled_solid
              //           : CupertinoIcons.exclamationmark_circle,
              //       color: _emailVerified
              //           ? AppColors.success
              //           : AppColors.warning,
              //     ),
              //     title: Text(
              //       _emailVerified ? 'Email vérifié' : 'Email non vérifié',
              //     ),
              //     subtitle: _emailVerified
              //         ? null
              //         : const Text('Cliquez pour renvoyer l\'email'),
              //     trailing: _emailVerified
              //         ? null
              //         : TextButton(
              //             onPressed: _sendVerificationEmail,
              //             child: const Text('Renvoyer'),
              //           ),
              //     onTap: _emailVerified ? null : _checkEmailVerification,
              //   ),
              // ),
              // const SizedBox(height: 16),

              // Identifiant médecin
              TextFormField(
                controller: _medicalIdController,
                decoration: const InputDecoration(
                  labelText: 'Identifiant Médecin',
                  hintText: 'Ex: ORD123456',
                  prefixIcon: Icon(CupertinoIcons.doc_text),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Identifiant requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Spécialité
              DropdownButtonFormField<String>(
                initialValue: _selectedSpecialty,
                decoration: const InputDecoration(
                  labelText: 'Spécialité',
                  prefixIcon: Icon(CupertinoIcons.heart),
                  border: OutlineInputBorder(),
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
              const SizedBox(height: 24),

              // CNI Recto
              Text(
                'Photo CNI Recto',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildImagePicker(true, _cniRectoImage),
              const SizedBox(height: 16),

              // CNI Verso
              Text(
                'Photo CNI Verso',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildImagePicker(false, _cniVersoImage),
              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Soumettre pour vérification',
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(16),
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(4)),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.checkmark_circle_fill,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(bool isRecto, File? image) {
    return GestureDetector(
      onTap: () => _pickImage(isRecto),
      child: Container(
        height: 180,
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
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prendre une photo',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: getProportionateScreenHeight(16),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
