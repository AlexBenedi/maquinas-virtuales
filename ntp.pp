class chrony {

  package { 'chrony':
    ensure 	=> installed,
    require => Exec['descargar'],
  }

  file { 'chrony.conf':
    ensure  => file,
    content => "server 2001:470:736b:1ff::1 iburst\nserver 2001:470:736b:1ff::2 iburst\nlogdir /var/log/chrony\n",
    path => '/etc/chrony.conf',
    notify => Exec['restart'],
  }
  
  service { 'chronyd':
    ensure => running,
    enable => true,
  }
  
  exec {'restart':
		command    => 'systemctl restart chronyd',
    path	=> ['/usr/bin', '/usr/sbin'],
	}
	
	exec {'descargar':
		command    => 'nmcli connection modify vlan112 ipv6.dns \'2001:470:736b:1ff::2\'',
    path			 => ['/usr/bin', '/usr/sbin'],
	}
}

class {'chrony':}
