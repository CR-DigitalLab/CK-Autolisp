RESUMEN DE LA RUTINA LISP: TXTACENTRO
=======================================

¿QUÉ HACE ESTA RUTINA?
Esta rutina te permite centrar automáticamente cualquier texto que esté contenido dentro de polígonos cerrados (polilíneas).
El programa calcula el centroide real y matemático de cada polilínea (incluso si tienen formas irregulares), localiza los textos próximos a esa área y los mueve exactamente a su centro, cambiando su justificación a Medio Centro (Middle Center).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSTRUCCIONES DE USO
=======================================

Paso 1: Cargar la rutina
-----------------------------------
1. Escribe el comando APPLOAD en AutoCAD y presiona Enter.
2. Selecciona el archivo TXTACENTRO.lsp (o su versión .fas / .vlx) y haz clic en "Cargar".

Paso 2: Ejecutar el comando
-----------------------------------
Comando a utilizar: TXTACENTRO

Paso 3: Procedimiento
-----------------------------------
1. Al escribir el comando, se te pedirá: "Seleccione las polilíneas cerradas:".
2. Selecciona en pantalla todos los polígonos (polilíneas cerradas) que contengan un texto adentro y presiona Enter.
3. El programa procesará los objetos en un instante. Los textos saltarán al centro geométrico exacto de cada parcela o polígono y se te mostrará el mensaje indicando cuántos polígonos fueron procesados.
