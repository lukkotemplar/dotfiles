# MÉTODOS AUXILIARES
Para leer datos de teclado, operaciones matemáticas adicionales o imprimir en pantalla, necesitamos métodos de clases internas de Java.
Necesitamos primero incluir la clase que queremos usar. Para ello:
```java
import java.util.Scanner //Clase scanner, para poder leer datos de entrada
import java.lang.Math.* //Otra forma de obtener los métodos es importar la clase Math y con el * importamos todas sus funciones
```
## ENTRADA
Primero tenemos que iniciar un objeto de la clase Scanner.
```java
import java.util.Scanner
...
Scanner teclado = new Scanner(System.in)
```
Los métodos son:
```java
import java.util.Scanner
...
Scanner teclado = new Scanner(System.in)
...
teclado.next() // Lee la siguiente cadena
teclado.nextLine() // Lee hasta el siguiente salto de línea
teclado.nextInt() // Lee hasta el siguiente número entero
```
## SALIDA
No necesitamos importar nada. Los métodos son:
```java
System.out.println("Hola") //Imprime Hola y mete un salto de línea
System.out.print("Hola") //Imprime Hola, sin meter un salto de línea
System.out.printf("Hola, %s", "Adios") //Imprime Hola, Adios. Sirve para formatear el texto, similar al printf de C
// %d para enteros, %f para decimales, %c para caracteres y %s para Strings
// CARACTERES ESPECIALES: /t (Tabulador), /n (Salto de línea)...
```
