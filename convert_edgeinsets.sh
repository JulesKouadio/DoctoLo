#!/bin/bash

# Script pour convertir automatiquement les EdgeInsets fixes en valeurs proportionnelles
# Usage: ./convert_edgeinsets.sh

echo "🔄 Conversion des EdgeInsets en cours..."

# Fonction pour ajouter l'import si nécessaire
add_import() {
    local file=$1
    if ! grep -q "import.*size_config.dart" "$file"; then
        # Trouver la dernière ligne d'import et ajouter après
        sed -i '' "/^import/a\\
import '../../../../core/utils/size_config.dart';
" "$file" 2>/dev/null || sed -i '' "/^import/a\\
import '../../core/utils/size_config.dart';
" "$file" 2>/dev/null
    fi
}

# Conversion des EdgeInsets.all()
convert_all() {
    local file=$1
    # Remplacer const EdgeInsets.all(X) par EdgeInsets.all(getProportionateScreenWidth(X))
    sed -i '' 's/const EdgeInsets\.all(\([0-9.]*\))/EdgeInsets.all(getProportionateScreenWidth(\1))/g' "$file"
    sed -i '' 's/EdgeInsets\.all(\([0-9.]*\))/EdgeInsets.all(getProportionateScreenWidth(\1))/g' "$file"
}

# Conversion des EdgeInsets.symmetric(horizontal: X, vertical: Y)
convert_symmetric() {
    local file=$1
    # Plus complexe, on va utiliser perl pour les remplacements avancés
    perl -i -pe 's/const EdgeInsets\.symmetric\(\s*horizontal:\s*([0-9.]+)\s*,\s*vertical:\s*([0-9.]+)\s*\)/EdgeInsets.symmetric(horizontal: getProportionateScreenWidth($1), vertical: getProportionateScreenHeight($2))/g' "$file"
    perl -i -pe 's/const EdgeInsets\.symmetric\(\s*vertical:\s*([0-9.]+)\s*,\s*horizontal:\s*([0-9.]+)\s*\)/EdgeInsets.symmetric(vertical: getProportionateScreenHeight($1), horizontal: getProportionateScreenWidth($2))/g' "$file"
    
    # Cas où il n'y a que horizontal
    perl -i -pe 's/const EdgeInsets\.symmetric\(\s*horizontal:\s*([0-9.]+)\s*\)/EdgeInsets.symmetric(horizontal: getProportionateScreenWidth($1))/g' "$file"
    
    # Cas où il n'y a que vertical
    perl -i -pe 's/const EdgeInsets\.symmetric\(\s*vertical:\s*([0-9.]+)\s*\)/EdgeInsets.symmetric(vertical: getProportionateScreenHeight($1))/g' "$file"
}

# Conversion des EdgeInsets.only()
convert_only() {
    local file=$1
    # Remplacer left
    perl -i -pe 's/const EdgeInsets\.only\(\s*left:\s*([0-9.]+)\s*\)/EdgeInsets.only(left: getProportionateScreenWidth($1))/g' "$file"
    # Remplacer right
    perl -i -pe 's/const EdgeInsets\.only\(\s*right:\s*([0-9.]+)\s*\)/EdgeInsets.only(right: getProportionateScreenWidth($1))/g' "$file"
    # Remplacer top
    perl -i -pe 's/const EdgeInsets\.only\(\s*top:\s*([0-9.]+)\s*\)/EdgeInsets.only(top: getProportionateScreenHeight($1))/g' "$file"
    # Remplacer bottom
    perl -i -pe 's/const EdgeInsets\.only\(\s*bottom:\s*([0-9.]+)\s*\)/EdgeInsets.only(bottom: getProportionateScreenHeight($1))/g' "$file"
}

# Liste des fichiers à traiter (pages principales)
files=(
    "lib/features/auth/presentation/pages/register_page.dart"
    "lib/features/auth/presentation/pages/forgot_password_page.dart"
    "lib/features/auth/presentation/pages/professional_verification_page.dart"
    "lib/features/messages/presentation/pages/doctor_messages_page.dart"
    "lib/features/messages/presentation/pages/search_doctors_page.dart"
    "lib/features/messages/presentation/pages/search_patients_page.dart"
    "lib/features/messages/presentation/pages/conversations_list_page.dart"
    "lib/features/search/presentation/pages/search_professional_page.dart"
    "lib/features/doctor/presentation/pages/doctor_home_page.dart"
    "lib/features/doctor/presentation/pages/patients_list_page.dart"
    "lib/features/doctor/presentation/pages/availability_settings_page.dart"
    "lib/features/doctor/presentation/pages/consultation_settings_page.dart"
    "lib/features/doctor/presentation/pages/doctor_profile_page.dart"
    "lib/features/appointment/presentation/pages/appointments_list_page.dart"
    "lib/features/appointment/presentation/pages/appointment_booking_page.dart"
    "lib/features/settings/presentation/pages/account_settings_page.dart"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "📝 Traitement de $file..."
        # add_import "$file"
        convert_all "$file"
        convert_symmetric "$file"
        convert_only "$file"
        echo "✅ $file converti"
    else
        echo "⚠️  $file non trouvé"
    fi
done

echo ""
echo "✨ Conversion terminée!"
echo ""
echo "📊 Statistique finale:"
grep -r "const EdgeInsets\." lib --include="*.dart" | wc -l | xargs echo "Lignes avec 'const EdgeInsets' restantes:"
