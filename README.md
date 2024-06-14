# maquinas-virtuales

La red consta 11 maquinas virtuales virtualizadas mediante libvirt (qcow2). Algunas de estas maquinas son utilizas unicamente como routers mientras que otras proporcionan servicios distribuidos.
A continuacion se detalla los servicios distribuidos proporcionados:

* DNS
    - Para proporcionar este servicio se hace uso de 3 maquinas virtuales.
    - Un nodo maestro contendra toda la informacion de los nodos de autoridad y replicara la informacion a un nodo esclavo. Esto se ha implementado haciendo uso de NSD
    - Se ha añadadido un tercer nodo que actua como servidor DNS recursivo y ademas se encuentra cacheada para mejorar el rendimiento. Este servidor recursivo de implementado haciendo uso de unbound.
 
* NTP
    - Se ha implementado en la red un servidor de sincornizacion de tiempos. Este se encuentra en uno de los routers.
    - Se ha implementado haciendo uso de NTPd y de chrony

* FreeIpa con NFS "Kerberizado"
    - Para proporcionar este servicio se hace uso de 3 maquinas diferentes.
    - Se configura un nodo maestro y un nodo esclavo dentro del dominion Ipa.
    - En el tercer nodo se configura un servicio NFS Kerberizado el cual exportara los directorios home correspondiente a cada uno de los usuarios.
  


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
