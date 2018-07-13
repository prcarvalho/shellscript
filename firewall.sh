#!/bin/bash
### limpar todas as regras pré existentes
iptables -F
iptables -t nat -F
iptables -t mangle -F
### Protecao contra port scanners ocultos
iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RTS -m limit --limit 1/s -j ACCEPT
### Defesa: syncookies (evita ataque DoS "Negacao de servicos")
echo > 1 /proc/sys/net/ipv4/tcp_syncookies
#Defesa: rpfilter (evita ataque de spoofing "falsificação de ip")
echo > 1 /proc/sys/net/ipv4/conf/default/rp_filter
### Elimina pacotes inválidos (Evita diversos tipos de ataques)
iptables -A INPUT -m state --state INVALID -j DROP
### Liberando acesso a interface de loopback:
iptables -A INPUT -p tcp -i lo -j ACCEPT
### Carregando o módulo correspondente (Liberar internet)
modprobe iptable_nat
### Regra (liberar internet)
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
### Ativando o módulo ip_forward (Liberar internet)
echo 1 > /proc/sys/net/ipv4/ip_forward
#Liberando DNS:
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
### Liberando http e https:
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
#Libera envio e recebimento de Email. Obs Verificar portas junto ao Provedor
iptables -A INPUT -p tcp --dport 110 -j ACCEPT
iptables -A INPUT -p tcp --dport 25 -j ACCEPT
### Liberando o acesso remoto via SSH:
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
#liberando SAMBA
iptables -A INPUT -p tcp --dport 445 -j ACCEPT
iptables -A INPUT -p tcp --dport 139 -j ACCEPT
iptables -A INPUT -p udp --dport 137 -j ACCEPT
iptables -A INPUT -p udp --dport 138 -j ACCEPT
### Bloqueia as portas UDP de 0 a 1023 ( com excessão das abertas acima):
iptables -A INPUT -p udp --dport 0:1023 -j DROP
### Bloueia conexões nas demais portas:
iptables -A INPUT -p tcp --syn -j DROP
