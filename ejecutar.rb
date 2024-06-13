#!/usr/bin//ruby -w
require 'net/ping'
#require 'net/ssh'
#require 'net/scp'

PATH = File.expand_path('~/.u/hosts')

# Lee el fichero host y guarda las direcciones en un vector
def leer_hosts grupo_ip
  hosts = {}
  grupo_actual = nil
  es_grupo = true
  File.open(PATH, 'r').each_line do |linea|
  	linea = linea.strip
  	case linea[0]
  	when '-'
  		grupo_actual = linea[1..-1]
  		hosts[grupo_actual] = []
  	when '+'
  		grupo_existente = linea[1..-1]
  		if hosts.key?(grupo_existente)
  			hosts[grupo_actual].concat(hosts[grupo_existente])
  		end
  	else
  		if grupo_actual and !linea.empty?
  			hosts[grupo_actual] << linea
  			if linea == grupo_ip
  				es_grupo = false
  			end
  		end
  	end
  end
  return hosts, es_grupo
end

def parametros(argv)
  parametro = nil
  grupo_ip = nil
  comando = nil
  archivos = []

  if argv.length == 1
    case argv[0]
    when "p"
      parametro = argv[0]
      grupo_ip = nil
    when "s"
      exit
    end
  elsif argv.length == 2
    case argv[0]
    when "p"
      parametro = argv[1]
      grupo_ip = argv[0]
    when "s"
      parametro = argv[0]
      comando = argv[1]
    when "c"
      parametro = argv[0]
      archivos << argv[1]
    end
  elsif argv.length >= 3
    if argv[1] == "s"
    	subcomando = argv[1]
      grupo_ip = argv[0]
      subcomando_ssh = argv[2]
    elsif argv[1] == "c"
      subcomando = argv[1]
      grupo_ip = argv[0]
      archivos = argv[2..-1]
    elsif argv[0] == "c"
       subcomando = argv[0]
       archivos = argv[1..-1]
    end
  else
    exit
  end

  return parametro, grupo_ip, comando, archivos
end


# FUNCIONES EJECUTAR
#Ejecuta el comando en una maquina
def comando host, com
	return "ssh a843826@#{host} #{com}"
end

# Ejecuta el comando en un grupo de maquinas.
# ESte grupo puede ser uno en especifico o a todas las maquinas
def comando_grupo hosts, com
	realizadas = []
	hosts.each do |host|
		if realizadas.include?(host)
			next
		end
 		ping = ping host
  	puts "#{host}: #{ping}"
		com = comando host, com
		output = `#{com}`
		puts output
		puts "\n"
		realizadas << host
	end
end

# Ejecuta el comando en todas las maquinas
def comando_hosts hosts, com, grupo_ip, es_grupo
	if grupo_ip == 'nil'	# todas las maquians
		comando_grupo hosts.values.flatten, com
	elsif es_grupo				# un grupo de maquinas
		comando_grupo hosts[grupo_ip], com
	else									# solo una maquina
		puts "#{grupo_ip}: #{ping grupo_ip}"
		com = comando grupo_ip, com
		output = `#{com}`
		puts output
	end
end



# FUNCIONES PING

# Hace ping a una maquina
def ping host
	ping = Net::Ping::TCP.new(host, 22)
	if ping.ping?
	  	"FUNCIONA"
	else
  		"fallo"
  	end
end

# Hace ping a un grupo de maquinas.
# ESte grupo puede ser uno en especifico o a todas las maquinas
def ping_grupo hosts
	realizadas = []
	hosts.each do |ip|
		if realizadas.include?(ip)
			next
		end
		puts "#{ip}: #{ping ip}"
		realizadas << ip
	end
end

# Distingue hacia que maquinas o maquin lanzar el ping
def ping_hosts hosts, grupo_ip, es_grupo
	#puts hosts
	if grupo_ip == 'nil'	# todas las maquians
		ping_grupo hosts.values.flatten
	elsif es_grupo				# un grupo de maquinas
		ping_grupo hosts[grupo_ip]
	else									# solo una maquina
		puts "#{grupo_ip}: #{ping grupo_ip}"
	end
end

def manifiesto ip, archivos
	archivos.each do |archivo|
		com = "scp /home/a843826/.u/manifiestos/#{archivo} a843826@[#{ip}]:/tmp/#{archivo}"
		output = `#{com}`
		com = "sudo puppet apply /tmp/#{archivo}"
		com = "ssh a843826@#{ip} #{com}"
		output = `#{com}`
		puts "#{ip}: #{output}"
		com = "rm /tmp/#{archivo}"
		com = "ssh a843826@#{ip} #{com}"
		output = `#{com}`
	end
end

def manifiesto_grupo hosts, archivos
	realizadas = []
	hosts.each do |ip|
		if realizadas.include?(ip)
			next
		end
		manifiesto ip, archivos
		realizadas << ip
	end
end

def manifiesto_hosts hosts, comando, grupo_ip, es_grupo, archivos
	if grupo_ip == 'nil'	# todas las maquians
		manifiesto_grupo hosts.values.flatten, archivos
	elsif es_grupo				# un grupo de maquinas
		manifiesto_grupo hosts[grupo_ip], archivos
	else									# solo una maquina
		manifiesto grupo_ip, archivos
	end
end
# FUNCION EJECUTAR
# Distingue el comando a ejecutar
def ejecutar hosts, parametro, comando, grupo_ip, es_grupo, archivos
  case parametro
  when 'p'	# ping
    ping_hosts hosts, grupo_ip, es_grupo
  when 's'	# comando
		comando_hosts hosts, comando, grupo_ip, es_grupo
	when 'c'	#manifiesto
		manifiesto_hosts hosts, comando, grupo_ip, es_grupo, archivos
  else
    puts "parametro no válido."
  end
end


# MAIN
parametro, grupo_ip, comando, archivos = parametros(ARGV)
hosts, es_grupo = leer_hosts grupo_ip
ejecutar hosts, parametro, comando, grupo_ip, es_grupo, archivos
