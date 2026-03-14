#!/bin/bash

# ==============================================
# Script de configuration automatique Raspberry Pi - Projet IoT
# ==============================================

SEPARATOR="=============================================="

print_step() {
    echo ""
    echo "$SEPARATOR"
    echo "  $1"
    echo "$SEPARATOR"
}

# Vérification des droits sudo
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  Ce script doit être exécuté avec sudo"
    echo "    Utilisation : sudo bash setup_raspberry.sh"
    exit 1
fi

print_step "🚀 Lancement du programme de configuration IoT"
sleep 1

# ----------------------------
# 1. Mise à jour du système
# ----------------------------
print_step "📦 Mise à jour du système (apt update & upgrade)"
apt update && apt upgrade -y
if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la mise à jour du système"
    exit 1
fi
echo "✅ Système mis à jour"
sleep 1

# ----------------------------
# 2. Installation de Python
# ----------------------------
print_step "🐍 Vérification / Installation de Python3"
apt install python3 python3-pip python3-venv -y
if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de l'installation de Python3"
    exit 1
fi

PYTHON_VERSION=$(python3 --version 2>&1)
echo "✅ $PYTHON_VERSION installé"
sleep 1

# ----------------------------
# 3. Recherche des venvs existants
# ----------------------------
print_step "🔍 Recherche des environnements virtuels (venv) existants..."

# Recherche dans les répertoires courants (plus rapide que /)
SEARCH_DIRS=("/home" "/root" "/opt" "$(pwd)")
VENV_LIST=()

for dir in "${SEARCH_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        # Un venv valide contient bin/activate et bin/python
        while IFS= read -r -d '' activate_path; do
            venv_dir=$(dirname "$(dirname "$activate_path")")
            if [ -f "$venv_dir/bin/python" ]; then
                VENV_LIST+=("$venv_dir")
            fi
        done < <(find "$dir" -name "activate" -path "*/bin/activate" 2>/dev/null -print0)
    fi
done

echo ""
if [ ${#VENV_LIST[@]} -eq 0 ]; then
    echo "⚠️  Aucun environnement virtuel trouvé dans les répertoires suivants :"
    for d in "${SEARCH_DIRS[@]}"; do echo "    - $d"; done
else
    echo "✅ ${#VENV_LIST[@]} environnement(s) virtuel(s) trouvé(s) :"
    for i in "${!VENV_LIST[@]}"; do
        venv="${VENV_LIST[$i]}"
        python_path="$venv/bin/python"
        python_ver=$("$python_path" --version 2>&1)
        echo ""
        echo "  [$((i+1))] 📁 Chemin  : $venv"
        echo "       🐍 Python  : $python_ver"
        echo "       ▶️  Activer : source $venv/bin/activate"
    done
fi

# ----------------------------
# 4. Créer un nouveau venv ?
# ----------------------------
print_step "➕ Créer un nouvel environnement virtuel ?"
echo "Voulez-vous créer un nouveau venv ? (o/n)"
read -r CREATE_VENV

if [[ "$CREATE_VENV" =~ ^[oO]$ ]]; then
    echo ""
    echo "📂 Entrez le chemin complet où créer le venv"
    echo "   (ex: /home/pi/mon_projet/venv) :"
    read -r VENV_PATH

    if [ -z "$VENV_PATH" ]; then
        echo "❌ Chemin vide, création annulée"
    else
        # Créer le dossier parent si nécessaire
        mkdir -p "$(dirname "$VENV_PATH")"
        python3 -m venv "$VENV_PATH"

        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ Venv créé avec succès !"
            echo "   📁 Chemin  : $VENV_PATH"
            echo "   ▶️  Activer : source $VENV_PATH/bin/activate"
	    python -m pip install -r ./requirement.txt
	    
        else
            echo "❌ Erreur lors de la création du venv à : $VENV_PATH"
        fi
    fi
else
    echo "⏭️  Création ignorée"
fi

# ----------------------------
# Fin
# ----------------------------
print_step "🏁 Configuration terminée"
echo ""
