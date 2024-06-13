class clienteIPA {
    package { 'ipa-client':
        ensure => installed,
        notify => File['hosts'],
    }

    file { 'hosts':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        content => '2001:470:736b:112:db34:ee37:2830:a188 cl2.1.1.ff.es.eu.org cl2',
        path    => '/etc/hosts',
        notify    => Exec['configurar_dns'],
    }

    service { 'sssd':
        ensure    => running,
        enable    => true,
        #subscribe => Exec['configurar_ipa'],
    }
    
	exec {'configurar_dns':
		command    => 'nmcli connection modify vlan112 ipv6.dns \'2001:470:736b:111::2\'',
        path	=> ['/usr/bin', '/usr/sbin'],
        notify 	=> Exec['reiniciar_red'],
	}
	
	exec {'reiniciar_red':
		command    => 'systemctl restart NetworkManager',
        path	=> ['/usr/bin', '/usr/sbin'],
        notify 	=> Exec['configurar_ipa'],
	}
	
    exec { 'configurar_ipa':
         command    => 'ipa-client-install --unattended --server=ipa1.1.1.ff.es.eu.org --domain=1.1.ff.es.eu.org --principal=admin --password=Multip16 --hostname=cl2.1.1.ff.es.eu.org --realm=1.1.FF.ES.EU.ORG --force-join',
         path	=> ['/usr/bin', '/usr/sbin'],
         #subscribe  => File['hosts'],
    }
}

class { 'clienteIPA': }                  
