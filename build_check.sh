#!/bin/bash

# Script para verificar el build local antes de hacer push
# Guarda este archivo como build_check.sh en la raíz de tu proyecto

echo "🔍 Verificando configuración de Flutter..."

# Verificar versión de Flutter
flutter --version

echo "📦 Instalando dependencias..."
flutter pub get

echo "🧹 Limpiando builds anteriores..."
flutter clean

echo "🏗️ Construyendo para web..."
flutter build web --release --base-href "/shiftSense/"

# Verificar que se generó correctamente
if [ -d "build/web" ]; then
    echo "✅ Build exitoso! Verificando contenido..."
    echo "📁 Archivos generados:"
    ls -la build/web/
    
    # Verificar archivos críticos
    if [ -f "build/web/index.html" ]; then
        echo "✅ index.html encontrado"
    else
        echo "❌ index.html NO encontrado"
        exit 1
    fi
    
    if [ -f "build/web/main.dart.js" ] || [ -f "build/web/main.dart.wasm" ]; then
        echo "✅ Archivos principales encontrados"
    else
        echo "❌ Archivos principales NO encontrados"
        exit 1
    fi
    
    echo "🎉 ¡Todo listo para el despliegue!"
    echo "💡 Ahora puedes hacer git add, commit y push"
    
else
    echo "❌ Error: No se generó la carpeta build/web"
    echo "🔧 Revisa los errores anteriores"
    exit 1
fi
