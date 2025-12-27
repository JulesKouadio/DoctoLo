#!/bin/bash

echo "🔄 Conversion des fichiers restants..."

files=(
    "lib/features/pharmacy/presentation/pages/on_duty_pharmacies_page.dart"
    "lib/features/pharmacy/presentation/pages/pharmacy_details_page.dart"
    "lib/features/appointment/presentation/pages/video_call_page.dart"
    "lib/features/messages/presentation/pages/create_prescription_page.dart"
    "lib/features/doctor/presentation/pages/professional_experience_page.dart"
    "lib/features/doctor/presentation/pages/documents_management_page.dart"
    "lib/features/doctor/presentation/pages/patient_detail_page.dart"
    "lib/features/admin/presentation/pages/verification_requests_page.dart"
    "lib/shared/widgets/section_header.dart"
    "lib/shared/widgets/patient_list_card.dart"
    "lib/shared/widgets/agenda_slot_card.dart"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "📝 $file..."
        # EdgeInsets.all
        perl -i -pe 's/const EdgeInsets\.all\(([0-9.]+)\)/EdgeInsets.all(getProportionateScreenWidth($1))/g' "$file"
        # EdgeInsets.symmetric avec les deux
        perl -i -pe 's/const EdgeInsets\.symmetric\(\s*horizontal:\s*([0-9.]+)\s*,\s*vertical:\s*([0-9.]+)\s*\)/EdgeInsets.symmetric(horizontal: getProportionateScreenWidth($1), vertical: getProportionateScreenHeight($2))/g' "$file"
        perl -i -pe 's/const EdgeInsets\.symmetric\(\s*vertical:\s*([0-9.]+)\s*,\s*horizontal:\s*([0-9.]+)\s*\)/EdgeInsets.symmetric(vertical: getProportionateScreenHeight($1), horizontal: getProportionateScreenWidth($2))/g' "$file"
        # EdgeInsets.symmetric horizontal seul
        perl -i -pe 's/const EdgeInsets\.symmetric\(\s*horizontal:\s*([0-9.]+)\s*\)/EdgeInsets.symmetric(horizontal: getProportionateScreenWidth($1))/g' "$file"
        # EdgeInsets.symmetric vertical seul
        perl -i -pe 's/const EdgeInsets\.symmetric\(\s*vertical:\s*([0-9.]+)\s*\)/EdgeInsets.symmetric(vertical: getProportionateScreenHeight($1))/g' "$file"
        # EdgeInsets.only
        perl -i -pe 's/const EdgeInsets\.only\(\s*left:\s*([0-9.]+)\s*\)/EdgeInsets.only(left: getProportionateScreenWidth($1))/g' "$file"
        perl -i -pe 's/const EdgeInsets\.only\(\s*right:\s*([0-9.]+)\s*\)/EdgeInsets.only(right: getProportionateScreenWidth($1))/g' "$file"
        perl -i -pe 's/const EdgeInsets\.only\(\s*top:\s*([0-9.]+)\s*\)/EdgeInsets.only(top: getProportionateScreenHeight($1))/g' "$file"
        perl -i -pe 's/const EdgeInsets\.only\(\s*bottom:\s*([0-9.]+)\s*\)/EdgeInsets.only(bottom: getProportionateScreenHeight($1))/g' "$file"
        echo "✅ Converti"
    fi
done

echo "✨ Terminé!"
echo "Restant:" && grep -r "const EdgeInsets\." lib --include="*.dart" | wc -l
