#!/bin/bash

# Dossier de destination
DEST="/workspace/naruto-ai-chat/app/src/main/res/drawable-nodpi"

# Placeholder image generator (couleur unie pour chaque personnage)
# On va créer des images PNG simples pour l'instant

# Naruto - Orange
convert -size 400x400 xc:"#FFA500" "$DEST/naruto_photo.jpg" 2>/dev/null || echo "ImageMagick not available, using curl"

# Sasuke - Dark blue
convert -size 400x400 xc:"#000080" "$DEST/sasuke_photo.jpg" 2>/dev/null

# Sakura - Pink
convert -size 400x400 xc:"#FFC0CB" "$DEST/sakura_photo.jpg" 2>/dev/null

# Kakashi - Silver
convert -size 400x400 xc:"#C0C0C0" "$DEST/kakashi_photo.jpg" 2>/dev/null

# Hinata - Lavender
convert -size 400x400 xc:"#E6E6FA" "$DEST/hinata_photo.jpg" 2>/dev/null

# Itachi - Red/Black
convert -size 400x400 xc:"#8B0000" "$DEST/itachi_photo.jpg" 2>/dev/null

echo "Images créées dans $DEST"
ls -lh "$DEST"
