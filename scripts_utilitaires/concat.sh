#!/bin/bash

rm IA
touch IA
echo "//GlobalVar file" >> IA
echo "" >> IA
echo "" >> IA
cat TUC-The-Code/GlobalVar >> IA
echo "" >> IA
echo "" >> IA
echo "//Utilitaires file" >> IA
echo "" >> IA
echo "" >> IA
cat TUC-The-Code/Utilitaires >> IA
echo "" >> IA
echo "" >> IA
echo "//FonctionEtat file" >> IA
echo "" >> IA
echo "" >> IA
cat TUC-The-Code/FonctionEtat >> IA
echo "" >> IA
echo "" >> IA
echo "//IA file" >> IA
echo "" >> IA
echo "" >> IA
cat TUC-The-Code/IA >> IA
echo "" >> IA
echo "" >> IA

# suppression des includes
sed -i "s@include(@//include(@" IA

