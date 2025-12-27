import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/constants/app_settings_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final SettingsService _settingsService = SettingsService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  bool _isSaving = false;

  String _selectedLanguage = '';
  String _selectedCurrency = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    setState(() {
      _selectedLanguage = _settingsService.currentLanguage;
      _selectedCurrency = _settingsService.currentCurrency.code;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      await _settingsService.setLanguage(_selectedLanguage, userId: _userId);
      await _settingsService.setCurrency(_selectedCurrency, userId: _userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Paramètres enregistrés'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountSettings),
        backgroundColor: AppColors.primary,
        actions: [
          if (_isSaving)
            Center(
              child: Padding(
                padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(CupertinoIcons.floppy_disk),
              onPressed: _saveSettings,
              tooltip: l10n.save,
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(getProportionateScreenWidth(16)),
        children: [
          // Section Langue
          _buildSectionHeader(
            icon: CupertinoIcons.globe,
            title: l10n.language,
            subtitle: l10n.selectLanguage,
          ),
          const SizedBox(height: 12),
          _buildLanguageSelector(),
          const SizedBox(height: 32),

          // Section Devise
          _buildSectionHeader(
            icon: CupertinoIcons.money_dollar,
            title: l10n.currency,
            subtitle: l10n.selectCurrency,
          ),
          const SizedBox(height: 12),
          _buildCurrencySelector(),
          const SizedBox(height: 32),

          // Info
          Container(
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.info_circle, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.settingsAppliedEverywhere,
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: getProportionateScreenHeight(13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bouton Enregistrer
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveSettings,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(CupertinoIcons.checkmark),
            label: Text(_isSaving ? l10n.saving : l10n.save),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(getProportionateScreenWidth(8)),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: getProportionateScreenHeight(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: getProportionateScreenHeight(13),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: AppSettingsConstants.availableLanguages.entries.map((entry) {
          final isSelected = _selectedLanguage == entry.key;
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getLanguageFlag(entry.key),
                  style: TextStyle(fontSize: getProportionateScreenHeight(24)),
                ),
              ),
            ),
            title: Text(
              entry.value,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.black87,
              ),
            ),
            trailing: isSelected
                ? const Icon(
                    CupertinoIcons.checkmark_circle,
                    color: AppColors.primary,
                  )
                : null,
            onTap: () {
              setState(() {
                _selectedLanguage = entry.key;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: AppSettingsConstants.availableCurrencies.entries.map((entry) {
          final currency = entry.value;
          final isSelected = _selectedCurrency == entry.key;
          return ListTile(
            leading: Container(
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  currency.symbol,
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(20),
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : Colors.black87,
                  ),
                ),
              ),
            ),
            title: Text(
              '${currency.name} (${currency.code})',
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.black87,
              ),
            ),
            subtitle: Text(
              'Exemple: ${currency.format(100.0)}',
              style: TextStyle(
                fontSize: getProportionateScreenHeight(12),
                color: AppColors.textSecondary,
              ),
            ),
            trailing: isSelected
                ? const Icon(
                    CupertinoIcons.checkmark_circle,
                    color: AppColors.primary,
                  )
                : null,
            onTap: () {
              setState(() {
                _selectedCurrency = entry.key;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  String _getLanguageFlag(String languageCode) {
    const Map<String, String> flags = {
      'fr': '🇫🇷',
      'en': '🇬🇧',
      'es': '🇪🇸',
      'ar': '🇸🇦',
      'de': '🇩🇪',
    };
    return flags[languageCode] ?? '🌐';
  }
}
