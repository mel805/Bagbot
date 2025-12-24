#!/bin/bash

# Créer des images PNG simples mais jolies pour chaque personnage
DEST="/workspace/naruto-ai-chat/app/src/main/res/drawable-nodpi"
mkdir -p "$DEST"

# Utiliser ImageMagick pour créer des images avec dégradés
# Naruto - Orange vif
convert -size 400x400 gradient:"#FF8C00"-"#FFA500" "$DEST/naruto_photo.png"

# Sasuke - Bleu nuit
convert -size 400x400 gradient:"#000080"-"#1E90FF" "$DEST/sasuke_photo.png"

# Sakura - Rose
convert -size 400x400 gradient:"#FF69B4"-"#FFC0CB" "$DEST/sakura_photo.png"

# Kakashi - Gris argenté
convert -size 400x400 gradient:"#778899"-"#C0C0C0" "$DEST/kakashi_photo.png"

# Hinata - Lavande
convert -size 400x400 gradient:"#9370DB"-"#E6E6FA" "$DEST/hinata_photo.png"

# Itachi - Rouge sombre
convert -size 400x400 gradient:"#8B0000"-"#DC143C" "$DEST/itachi_photo.png"

# Brad Pitt - Or
convert -size 400x400 gradient:"#DAA520"-"#FFD700" "$DEST/brad_photo.png"

# Leo DiCaprio - Bleu océan
convert -size 400x400 gradient:"#006994"-"#4682B4" "$DEST/leo_photo.png"

# The Rock - Marron musclé
convert -size 400x400 gradient:"#8B4513"-"#D2691E" "$DEST/rock_photo.png"

# Scarlett - Rouge glamour
convert -size 400x400 gradient:"#DC143C"-"#FF6347" "$DEST/scarlett_photo.png"

# Margot - Diamant brillant
convert -size 400x400 gradient:"#E0E0E0"-"#FFFFFF" "$DEST/margot_photo.png"

# Emma - Brun élégant
convert -size 400x400 gradient:"#8B4513"-"#D2B48C" "$DEST/emma_photo.png"

# Zendaya - Violet royal
convert -size 400x400 gradient:"#4B0082"-"#9370DB" "$DEST/zendaya_photo.png"

echo "Images PNG créées dans $DEST"
ls -lh "$DEST"/*.png
