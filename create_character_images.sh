#!/bin/bash
cd /workspace/naruto-ai-chat/app/src/main/res/drawable

# Créer des images vectorielles simples pour chaque personnage avec leurs emojis

# Naruto
cat > ic_naruto.xml << 'NARUTO'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="200dp" android:height="200dp"
    android:viewportWidth="200" android:viewportHeight="200">
    <path android:fillColor="#FFA500" 
        android:pathData="M100,100m-90,0a90,90 0,1 1,180 0a90,90 0,1 1,-180 0"/>
    <path android:fillColor="#FFD700" 
        android:pathData="M60,60 L100,40 L140,60 L100,80 Z"/>
</vector>
NARUTO

# Sasuke
cat > ic_sasuke.xml << 'SASUKE'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="200dp" android:height="200dp"
    android:viewportWidth="200" android:viewportHeight="200">
    <path android:fillColor="#1E3A8A"
        android:pathData="M100,100m-90,0a90,90 0,1 1,180 0a90,90 0,1 1,-180 0"/>
    <path android:fillColor="#FFFF00"
        android:pathData="M90,90 L110,70 L110,110 Z"/>
</vector>
SASUKE

# Sakura
cat > ic_sakura.xml << 'SAKURA'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="200dp" android:height="200dp"
    android:viewportWidth="200" android:viewportHeight="200">
    <path android:fillColor="#FFC0CB"
        android:pathData="M100,100m-90,0a90,90 0,1 1,180 0a90,90 0,1 1,-180 0"/>
    <path android:fillColor="#FF69B4"
        android:pathData="M80,80 L100,60 L120,80 L120,120 L80,120 Z"/>
</vector>
SAKURA

# Kakashi
cat > ic_kakashi.xml << 'KAKASHI'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="200dp" android:height="200dp"
    android:viewportWidth="200" android:viewportHeight="200">
    <path android:fillColor="#808080"
        android:pathData="M100,100m-90,0a90,90 0,1 1,180 0a90,90 0,1 1,-180 0"/>
    <path android:fillColor="#FFFFFF"
        android:pathData="M70,100 L130,100 L130,130 L70,130 Z"/>
</vector>
KAKASHI

# Hinata
cat > ic_hinata.xml << 'HINATA'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="200dp" android:height="200dp"
    android:viewportWidth="200" android:viewportHeight="200">
    <path android:fillColor="#9370DB"
        android:pathData="M100,100m-90,0a90,90 0,1 1,180 0a90,90 0,1 1,-180 0"/>
    <path android:fillColor="#DDA0DD"
        android:pathData="M80,70 L100,60 L120,70 L120,100 L80,100 Z"/>
</vector>
HINATA

# Itachi
cat > ic_itachi.xml << 'ITACHI'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="200dp" android:height="200dp"
    android:viewportWidth="200" android:viewportHeight="200">
    <path android:fillColor="#2C2C2C"
        android:pathData="M100,100m-90,0a90,90 0,1 1,180 0a90,90 0,1 1,-180 0"/>
    <path android:fillColor="#FF0000"
        android:pathData="M90,90 L110,90 L100,110 Z"/>
</vector>
ITACHI

# Brad Pitt
cat > ic_brad_pitt.xml << 'BRAD'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="200dp" android:height="200dp"
    android:viewportWidth="200" android:viewportHeight="200">
    <path android:fillColor="#D4A373"
        android:pathData="M100,100m-90,0a90,90 0,1 1,180 0a90,90 0,1 1,-180 0"/>
    <path android:fillColor="#FFD700"
        android:pathData="M70,60 L130,60 L130,80 L70,80 Z"/>
</vector>
BRAD

# Leonardo DiCaprio
cat > ic_leonardo.xml << 'LEO'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="200dp" android:height="200dp"
    android:viewportWidth="200" android:viewportHeight="200">
    <path android:fillColor="#87CEEB"
        android:pathData="M100,100m-90,0a90,90 0,1 1,180 0a90,90 0,1 1,-180 0"/>
    <path android:fillColor="#4682B4"
        android:pathData="M80,90 L120,90 L100,120 Z"/>
</vector>
LEO

# The Rock
cat > ic_the_rock.xml << 'ROCK'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="200dp" android:height="200dp"
    android:viewportWidth="200" android:viewportHeight="200">
    <path android:fillColor="#8B4513"
        android:pathData="M100,100m-90,0a90,90 0,1 1,180 0a90,90 0,1 1,-180 0"/>
    <path android:fillColor="#654321"
        android:pathData="M70,70 L130,70 L130,90 L70,90 Z"/>
</vector>
ROCK

# Scarlett Johansson
cat > ic_scarlett.xml << 'SCARLETT'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="200dp" android:height="200dp"
    android:viewportWidth="200" android:viewportHeight="200">
    <path android:fillColor="#FFE4E1"
        android:pathData="M100,100m-90,0a90,90 0,1 1,180 0a90,90 0,1 1,-180 0"/>
    <path android:fillColor="#FF6347"
        android:pathData="M80,60 L120,60 L120,100 L80,100 Z"/>
</vector>
SCARLETT

# Margot Robbie
cat > ic_margot.xml << 'MARGOT'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="200dp" android:height="200dp"
    android:viewportWidth="200" android:viewportHeight="200">
    <path android:fillColor="#FFD700"
        android:pathData="M100,100m-90,0a90,90 0,1 1,180 0a90,90 0,1 1,-180 0"/>
    <path android:fillColor="#FFA500"
        android:pathData="M80,70 L120,70 L120,110 L80,110 Z"/>
</vector>
MARGOT

# Emma Watson
cat > ic_emma.xml << 'EMMA'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="200dp" android:height="200dp"
    android:viewportWidth="200" android:viewportHeight="200">
    <path android:fillColor="#F5DEB3"
        android:pathData="M100,100m-90,0a90,90 0,1 1,180 0a90,90 0,1 1,-180 0"/>
    <path android:fillColor="#8B4513"
        android:pathData="M70,60 L130,60 L130,85 L70,85 Z"/>
</vector>
EMMA

# Zendaya
cat > ic_zendaya.xml << 'ZENDAYA'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="200dp" android:height="200dp"
    android:viewportWidth="200" android:viewportHeight="200">
    <path android:fillColor="#DEB887"
        android:pathData="M100,100m-90,0a90,90 0,1 1,180 0a90,90 0,1 1,-180 0"/>
    <path android:fillColor="#8B4513"
        android:pathData="M70,65 L130,65 L130,90 L70,90 Z"/>
</vector>
ZENDAYA

echo "✅ Images vectorielles créées!"
ls -la
