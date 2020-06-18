#!/bin/bash

# Directorio destino
DIR=/var/www/html

# Nombre de archivo HTML a generar
ARCHIVO=monitor.html

# Fecha actual
FECHA=$(date +'%d/%m/%Y %H:%M:%S')

# Declaración de la función
EstadoServicio() {

    systemctl --quiet is-active $1
    if [ $? -eq 0 ]; then
        echo "<p>Estado del servicio $1 está || <span class='encendido'> ACTIVO</span>.</p>" >> $DIR/$ARCHIVO
    else
        echo "<p>Estado del servicio $1 está || <span class='detenido'> DESACTIVADO | REINICIANDO</span>.</p>" >> $DIR/$ARCHIVO
		service $1 restart 
    fi
}

# Comienzo de la generación del archivo HTML
# Esta primera parte constitute el esqueleto básico del mismo.
echo "
<!DOCTYPE html>
<html lang='en'>
<head>
  <meta charset='UTF-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
  <meta http-equiv='X-UA-Compatible' content='ie=edge'>
  <title>Monitor de Servicios By @Kalix1</title>
  <link rel='stylesheet' href='estilos.css'>
</head>
<body>
<h1>Monitor de Servicios By @Kalix1</h1>
<p id='ultact'>Última actualización: $FECHA</p>
<hr>
" > $DIR/$ARCHIVO

# Servicios a chequear (podemos agregar todos los que deseemos
# Servidor SSH
EstadoServicio sshd
# Servidor DROPBEAR
EstadoServicio dropbear
# El servidor SSL
EstadoServicio stunnel4 
# Servidor SQUID
[[ $(EstadoServicio squid) ]] && EstadoServicio squid3
# Servidor APACHE
EstadoServicio apache2
on="<span class='encendido'> ACTIVO " && off="<span class='detenido'> DESACTIVADO | REINICIANDO "
[[ $(ps x | grep badvpn | grep -v grep | awk '{print $1}') ]] && badvpn=$on || badvpn=$off
echo "<p>Estado del servicio badvpn está ||  $badvpn </span>.</p> " >> $DIR/$ARCHIVO
#SERVICE BADVPN
PIDVRF3="$(ps aux|grep badvpn |grep -v grep|awk '{print $2}')"
if [[ -z $PIDVRF3 ]]; then
screen -dmS badvpn2 /bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10
else
for pid in $(echo $PIDVRF3); do
echo""
done
fi
#SERVICE PYTHON DIREC

ureset_python () {
for port in $(cat /etc/newadm/PortPD.log)
do
PIDVRF3="$(ps aux|grep pydic-"$port" |grep -v grep|awk '{print $2}')"
if [[ -z $PIDVRF3 ]]; then
screen -dmS pydic-"$port" python /etc/ger-inst/PDirect.py "$port"
else
for pid in $(echo $PIDVRF3); do
echo""
done
fi
done
}
ureset_python


pidproxy3=$(ps x | grep -w  "PDirect.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy3 ]] && P3="<span class='encendido'> ACTIVO " || P3="<span class='detenido'> DESACTIVADO | REINICIANDO "
echo "<p>Estado del servicio PythonDirec está ||  $P3 </span>.</p> " >> $DIR/$ARCHIVO
#LIBERAR RAM,CACHE
#sync ; echo 3 > /proc/sys/vm/drop_caches ; echo "RAM Liberada"
# Finalmente, terminamos de escribir el archivo
echo "
</body>
</html>" >> $DIR/$ARCHIVO
