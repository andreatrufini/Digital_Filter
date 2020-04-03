#!/bin/bash
# $file_bin_to_create è il file binario da creare
# $file_row è il numero di righe del file
# $n_bits è il numero di bit per riga
# $file_filtred è il file binario di uscita
file_bin_to_create=$1
file_row=$2
n_bits=$3
file_filtred=$4

# creo un file col prefisso uguale a quello passato solo con dec finale
file_bin_to_create_dec=$(echo "$file_bin_to_create" | cut -d '.' -f 1)"_dec."$(echo "$file_bin_to_create" | cut -d '.' -f 2)
# creo un file col prefisso uguale a quello passato solo con dec finale
file_filtred_dec=$(echo "$file_filtred" | cut -d '.' -f 1)"_dec."$(echo "$file_filtred" | cut -d '.' -f 2)

if [ -f $file_bin_to_create ]
then
	rm $file_bin_to_create
fi

if [ -f $file_bin_to_create_dec ]
then
	rm $file_bin_to_create_dec
fi

if [ -f $file_filtred ]
then
	rm $file_filtred
fi

if [ -f $file_filtred_dec ]
then
	rm $file_filtred_dec
fi

for ((i=1; i<=$file_row; i++))
do	
	num_bin=0
	for((j=1; j<=$n_bits; j++))
	do
		bit=$((RANDOM % 2))
		num_bin=$num_bin$bit
		echo -n "$bit" >> $file_bin_to_create
	done
	num_bin_dec=$((2#$num_bin))
	[ "$num_bin_dec" -gt 127 ] && ((num_bin_dec=$num_bin_dec-256))
	echo "$num_bin_dec" >> $file_bin_to_create_dec
	echo >> $file_bin_to_create
done

count=$(( 0 ))
uno=$(( 0 ))
due=$(( 0 ))
quattro=$(( 0 ))
tre=$(( 0 ))
media=$((0))

for binary in `cat $file_bin_to_create`
do 
	# trasformo in decimale
	number=$((2#$binary))
	[ "$number" -gt 127 ] && ((number=$number-256))
	#echo "$number"
	
	media=$(($media + $number))
	
	if [ $count -gt 3 ]
	then
		# shifto i valori
		uno=$(($due))
		due=$(($tre))
		tre=$(($quattro))
		quattro=$(($number))
		
		#eseguo sempre la stessa operazione a regime
		to_print=$(($quattro/4 + $tre - 2*$uno)) 

	else
		if [ $count -eq 0 ]
		then
			to_print=$(( $number/4))
			uno=$(($number))
		else
			if [ $count -eq 1 ]
			then
				to_print=$(( $number/4 + $uno))
				due=$(($number))
			else
				if [ $count -eq 2 ]
				then
					to_print=$(( $number/4 + $due))
					tre=$(($number))
				else
					if [ $count -eq 3 ]
					then	
						to_print=$(( $number/4 + $tre - 2*$uno))
						quattro=$(($number))
					fi
				fi
			fi
		fi
	fi

	echo "$to_print"
	# se il primo valore è negativo e minore di zero
	# se inoltre non è divisibile per 4 
	# allora devo sottrarci uno perchè la divisione per 4 in binario
	# approssima sempre per difetto 
	if [ $number -lt 0 ] ; then
		sup=$((-$number%4))
		echo $sup
		if [ $sup -ne 0 ] ; then
			to_print=$(($to_print-1))
		fi
	fi
	echo "$to_print"
	
	rest=$(( $count%2 ))
	if [ $rest -ne 0 ]; then
		to_print=$(( $to_print*(-1) ))
	fi
	
	if [ $to_print -lt -128 ]; then
		to_print=-128
	fi	
	if [ $to_print -gt 127 ]; then
		to_print=127
	fi
	
	echo "$to_print" >> $file_filtred_dec
	
	# riporto il numero al valore positivo precedente se l'aveva
	[ $to_print -lt 0 ] && to_print=$(( $to_print + 256 ))
	
	# ritrasformo in binario
	to_print_bin=$(echo "obase=2;$to_print" | bc)
	
	if [ $to_print -lt 0 ]
	then
		# devo mettere tutti gli 8 valori
		# i bit aggiunti devono essere tutti 1		
		while [ ${#to_print_bin} -lt 8 ]
		do
			to_print_bin="1"$to_print_bin
		done
	else		
		# devo mettere tutti gli 8 valori
		# i bit aggiunti devono essere tutti 0
		while [ ${#to_print_bin} -lt 8 ]; do
			to_print_bin="0"$to_print_bin
		done
	fi
	
	echo "$to_print_bin" >> $file_filtred
	
	#incremento il contatore
	count=$(($count+1))
done  
	
	
	echo "la la somma è: $media"
	media=$(($media/1024)
	echo "la media è: $media"
	# riporto il numero al valore positivo precedente se l'aveva
	[ $media -lt 0 ] && media=$(( $media + 256 ))

	# ritrasformo in binario
	media_bin=$(echo "obase=2;$media" | bc)
	echo "la media è: $media_bin"

