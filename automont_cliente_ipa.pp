
class cliente_nfs {

    exec { 'ipa_client_automount':
        command => 'ipa-client-automount --unattended',
        path    => ['/bin', '/usr/bin', '/usr/sbin'],
    }
}

class{'cliente_nfs':}
