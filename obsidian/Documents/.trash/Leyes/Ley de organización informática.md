# Ley de organización informática
El objetivo de este documento es definir la organización de los dispositivos informáticos, esto es, las 2 torres y los 2 portátiles.
## TORRE 1
La torre 1 se usará como centro de juegos, con el sistema operativo Linux, distribución CachyOS. Se usará única y exclusivamente para juegos modernos y videoconsolas del 2002 en adelante, configurados en el frontend Pegasus.
Dicho portátil deberá tener única y exclusivamente:
- Kitty
- Pegasus
- Steam
- Dolphin
- etc...
## TORRE 2
La torre 2 se usará como centro de juegos antiguos y videoconsolas hasta el 2002. Tendrá el sistema operativo Windows XP.
## PORTÁTIL 1
El portátil 1 se usará diariamente. El sistema operativo actual es Debian, aunque en un futuro se cambiará a NixOS una vez se adquieran los conocimientos necesarios para ello.
Dicho portátil deberá tener única y exclusivamente:
- Librewolf (con el dotfile de GitHub)
- Obsidian (con el dotfile de GitHub)
- Kitty (con el dotfile de GitHub)
- Opcional: Virtualbox
- Vim (con el dotfile de GitHub)
- VSCode (Fallback de Vim, la versión sin telemetría de Microsoft)

Las razones del uso de NixOS son:
- Facilidad para transferir el sistema con un archivo de configuración
- Facilidad para decidir paquetes a incluir o excluir
- Facilidad para reducir al mínimo el bloatware, y tener trazabilidad de paquetes

El entorno de escritorio será en principio dwm. Se estudiará la viabilidad de usar KDE en vez de GNOME.
En cuanto a los atajos de teclado, en principio se dejarán como están, la única modificación siendo:
- Número fijo de escritorios virtuales (4)
- Alt+# para cambiar al correspondiente escritorio virtual
- Alt+Shift+# para mover la ventana al correspondiente escritorio virtual
- Sin reglas de ventana

El sistema se instalará primero en el portátil auxiliar, desde ahí se transferirán los archivos y cuentas necesarias y se hará un período de prueba de 2 semanas. Una vez transcurrido el tiempo, se borrará el sistema actual del portátil 1 y se instalará el contenido del portátil auxiliar en el.
## PORTÁTIL 2
El portátil 2 se usará como zona de pruebas, recomendado especialmente para aprender todo sobre Linux.