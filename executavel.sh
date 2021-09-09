#!/bin/sh
#load 'plotarGrafico.gnu'
#sudo chmod 777 executavel.sh
#local=$(pwd)
#sudo chmod -R 777 $local

echo "Digite 1 para começar a gravar um .pcap"
echo "Digite 2 para gerar um grafico de utilização a partir de um .pcap existente"
read op
case $op in
    1) echo "Digite um nome para o arquivo .pcap: "
    read pcapfile
    echo "Digite quantos segundos queira gravar: "
    read tempo
    sudo timeout $tempo tcpdump -n -i any port 80 or 443 or 143 or 993 -w "$pcapfile"
    echo "Deseja criar o gráfico? (s/n)"
    read opgrafico
    case $opgrafico in
        s) sudo tcpdump -r -n "$pcapfile" port 80 or 443 or 143 or 993 > "dados.txt"
        sed -i 's/IP.*length//' dados.txt && sed -i 's/".".*[[:space:]]//' dados.txt && sed -i 's/: HTTP.*//' dados.txt
        gnuplot 'criarGrafico.gnu'
        sudo shotwell grafico.png
        ;;
        *) echo "Arquivo gravado"
        ;;
    esac
    ;;
    2) echo "Digite o nome/diretorio do arquivo .pcap: "
    read pcapfile
    sudo tcpdump -r "$pcapfile" port 80 or 443 or 993 > "dados.txt"
    sed -i 's/IP.*length//' dados.txt && sed -i 's/".".*[[:space:]]//' dados.txt && sed -i 's/: HTTP.*//' dados.txt
    gnuplot 'criarGrafico.gnu'
    sudo shotwell grafico.png
    ;;
    *) echo "Opção Invalida!" ;;
esac
