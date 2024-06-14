# maquinas-virtuales


A continuacion se explica la finalidad de cada manifiesto de puppet:

+ automont_cliente_ipa.pp
    - Este manifiesto establece el automontaje del directorio home para el cliente del dominio ipa que se haya configurado previamente.

* cliente_ipa.pp
    - Esta manifiesto instala un cliente ipa y lo configura dentro del dominio especificado en el manifiesto.
  
* ntp.pp
    - Instala chrony y sincroniza automaticamente el tiempo de la maquina.

A continuacion se explica la finalidad de los scrips de ruby y shell:
  
* mv.sh
    - Permite definir, encecnder, apagar, destruir y realizar copias de seguridad de una o varias maquinas virtuales. Si se quiere realizar para varias maquinas virtuales es necesario crear un fichero con el nombre de las maquinas.
  
* ejecutar.rb
    - Permite ejecutar comandos o aplicar manifiestos puppets en una o varias maquinas virtuales.
