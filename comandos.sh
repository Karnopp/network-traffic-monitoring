#!/bin/bash
#para este codigo é necessario passar como parametro:
#op -> 1 para gerar grafico a partir de .pcap existe. 2 para gravar .pcap
#caso op=2 não é necessario passar outros parametros
#nome ou diretorio onde encontra o .pcap e
#ip da rede analisada juntamente com sua mascara, ex: 192.168.0.0/24
op=$1
pcapfile=$2
rede=$3

case $op in
    1)
    sudo timeout $3 tcpdump -n -i any -w $pcapfile
    ;;
    

    2)
    #sudo tcpdump -n -r $pcapfile src net $rede and port 80 or 443 or 143 or 993 > saida2.txt
    sudo tcpdump -n -r $pcapfile src net $rede and not arp > dados.txt
    sed -i 's/**.*IP//' dados.txt && sed -i 's/>.*//' dados.txt
    #sed -i 's/**.*tell//' dados.txt && sed -i 's/,*.*//' dados.txt
    #sed -i 's/**.*Repply//' dados.txt && sed -i 's/is-at*.*//' dados.txt
    sed -i 's/^ \+//' dados.txt #remove espaço em branco no inicio da linha
    sed -i 's/ *$//g' dados.txt #remove espaço em branco no final da linha
    cat dados.txt | awk -F "." '{print $1"."$2"."$3"."$4;}' | sort | uniq > saida1.txt
    #esta ultima linha remove a porta dos ips, ordena os ips e remove duplicatas

    quantidadeIP=$(grep -c "" saida1.txt)
    sudo tcpdump -n -r "$pcapfile" port 80 or 443 or 143 or 993 or 1900 > "dados.txt"
    for (( i=1; i<=$quantidadeIP; ++i ))
    do
        IP_atual=$(sed -n "$i"p saida1.txt)
        
        cat dados.txt | grep "$IP_atual" > saida2.txt
        sed -i 's/IP.*length//' saida2.txt && sed -i 's/".".*[[:space:]]//' saida2.txt && sed -i 's/: HTTP.*//' saida2.txt
        tam=$(du -hsb saida2.txt |awk '{print $1}')
        if [ $tam -gt 0 ]
        then
            echo "set key above" >> temp
            echo "set xdata time" >> temp
            echo "set style data lines" >> temp
            echo "set timefmt '%H:%M:%S' " >> temp
            echo "set format x \"%Hh\n%Mm\n%Ss\" " >> temp
            echo "set xlabel 'tempo' " >> temp
            echo "set ylabel 'utilização (tamanho de cada pacote)' " >> temp
            echo "set title 'Utilização HTTP/HTTPS/IMAP em relação ao tempo para host: "$IP_atual"' " >> temp
            echo "set terminal png " >> temp
            echo "set output '"$IP_atual".png' " >> temp
            echo "plot 'saida2.txt' using 1:2 with line " >> temp

            gnuplot 'temp'
            sudo shotwell "$IP_atual".png #comentar essa linha para fazer teste tempo de exxecução
            rm 'temp'
        fi
    done
    ;;

    *) echo "Parâmetro invalido ou não definido" ;;
esac
