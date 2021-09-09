set key above
set xdata time
set style data lines
set timefmt '%H:%M:%S'
set format x "%Hh\n%Mm\n%Ss"
set xlabel 'tempo'
set ylabel 'utilização (tamanho de cada pacote)'
set title 'Utilização HTTP/HTTPS/IMAP em relação ao tempo'
set terminal png
set output 'grafico.png'
plot "dados.txt" using 1:2 with line
