#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <math.h>

#define row_dim 8
#define col_dim 1024
#define file_name_dim 100

void CA_2(int num, int *num_bin, int sign);

int main(int argc, char ** argv) {
    FILE *Mem_A_data;
    FILE *Mem_B_data;
    FILE *Mem_A_data_dec;
    FILE *Mem_B_data_dec;


    FILE *File_1;
    FILE *File_2;

    int Mem_A[col_dim], Mem_B[col_dim];
    int Mem_A_CA2[row_dim], Mem_B_CA2[row_dim];
    int i,j;
    int average, average_CA2[row_dim];
    int sign=1;
    int equal;
    int data_1, data_2;
    char file_1[file_name_dim];
    char file_2[file_name_dim];

    /*si utilizza un argomento da riga di comando per selezionare la modalità di utilizzo del programma, ovvero:
     * - se arg = "0" : il programma funziona come generatore dei due file contenente i dati da introdurre in MEM_A
     *   e quelli teoricamente ottenuti per MEM_B;
     * - si arg = "1" : il programma funziona come comparatore di due file, ovvero compara i dati che teoricamente
     *   essere presenti nella MEM_B e quelli che effettivamente sono stati ottenuti dalla simulazione circuitale
     *   */
    if(argc != 2) {
        printf("Errore nella riga di comando!");
        return EXIT_FAILURE;
    }

    if(argv[1][0] == '0') {

        printf("\nMODALITA' 0: GENERAZIONE DATI\n");

        Mem_A_data = fopen("Mem_A_data", "w");
            if (!Mem_A_data) {
                printf("Impossibile aprire il file 'Mem_A_data'");
                return EXIT_FAILURE;
            }
        Mem_A_data_dec = fopen("Mem_A_data_dec", "w");
            if (!Mem_A_data_dec) {
                printf("Impossibile aprire il file 'Mem_A_data_dec'");
                return EXIT_FAILURE;
            }

        srand(time(NULL));          //generazione di valori casuali per la generazione dei dati da inserire in MEM_A
        for (i = 0; i < col_dim; i++) {
            sign = rand() % 2;          //vengono in questo modo generati 0 od 1 casualmente per il bit di segno
            if (sign == 0)          //se il numero è negativo
                Mem_A[i] = (-1) * rand() % 129;   //saturo a -128
            else                    //se il numero è positivo
                Mem_A[i] = rand() % 128;   //saturo a 127


            CA_2(Mem_A[i], Mem_A_CA2, sign);   //funzione che esegue il complemento a 2 se il numero è negativo
            for (j = 0; j < row_dim; j++)
                fprintf(Mem_A_data, "%d", Mem_A_CA2[j]);

            fprintf(Mem_A_data, "\n");

            fprintf(Mem_A_data_dec, "%d\n", Mem_A[i]);
        }
        fclose(Mem_A_data);
        fclose(Mem_A_data_dec);

        for (i = 0; i < 1024; i++) {
            /* se il numero è negativo e non è divisibile per 4 nel sommatore viene approssimato per difetto
             * quindi è necessario sottrarre uno al numero trovato usando gli interi, perchè con essi il numero è
             * sempre approssimato per difetto ma in modulo. */
            if (Mem_A[i] < 0 && Mem_A[i] % 4 != 0) {
                Mem_B[i] = (Mem_A[i] / 4) - 1;
                // printf("%d\n", Mem_B[i]);
            } else
                Mem_B[i] = (Mem_A[i] / 4);

            if (i > 0)
                Mem_B[i] += Mem_A[i - 1];
            if (i > 2)
                Mem_B[i] += (-2) * Mem_A[i - 3];
            if (Mem_B[i] > 127)
                Mem_B[i] = 127;
            if (Mem_B[i] < -128)
                Mem_B[i] = -128;
        }

        /* scrittura dei dati teoricamente calcolati e che dovrebbero essere presenti in MEM_B */
        Mem_B_data = fopen("Mem_B_data", "w");
            if (!Mem_B_data) {
                printf("Impossibile aprire il file 'Mem_B_data'");
                return EXIT_FAILURE;
            }
        Mem_B_data_dec = fopen("Mem_B_data_dec", "w");
            if (!Mem_B_data_dec) {
                printf("Impossibile aprire il file 'Mem_B_data_dec'");
                return EXIT_FAILURE;
            }

        if (Mem_B_data) {
                for (i = 0; i < col_dim; i++) {
                    if (Mem_B[i] > 0)
                        sign = 1;
                    else
                        sign = 0;

                CA_2(Mem_B[i], Mem_B_CA2, sign);
                for (j = 0; j < row_dim; j++)
                    fprintf(Mem_B_data, "%d", Mem_B_CA2[j]);

                fprintf(Mem_B_data, "\n");

                fprintf(Mem_B_data_dec, "%d\n", Mem_B[i]);
                }
            fclose(Mem_B_data);
            fclose(Mem_B_data_dec);
        }else
            printf("Impossibile aprire il file 'Mem_A_out'");

        average = 0;            //calcolo della media
        for(i=0; i<row_dim; i++)
            average += Mem_A[i];

        average /= row_dim;
        if(average > 0)
            sign = 1;
        else
            sign = 0;
        CA_2(average, average_CA2, sign);

        printf("\nI file 'MEM_A_data' e 'MEM_B_data' sono stati generati!\n");
        printf("\nLa media e': \n");
        printf("\t- Decimale: %d", average);

        printf("\n\t- CA2: ");
        for (j = 0; j < row_dim; j++)
            printf("%d", average_CA2[j]);
        printf("\n");

    }else{

        /* SECONDA MODALITA' SCELTA DA RIGA DI COMANDO*/
        printf("MODALITA' 1: CONFRONTO RISULTATI\n\n");
        printf("Inserire il nome del file 1: ");
            scanf("%s", file_1);
        printf("\nInserisci il nome del file 2: ");
            scanf("%s", file_2);

        File_1 = fopen(file_1, "r");
        if (!File_1) {
            printf("Impossibile aprire il file %s!\n", file_1);
            return EXIT_FAILURE;
        }

        File_2 = fopen(file_2, "r");
        if (!File_2) {
            printf("Impossibile aprire il file %s!\n", file_2);
            return EXIT_FAILURE;
        }

        equal = 1;
        for(i=0; i<col_dim && equal == 1; i++) {
                fscanf(File_1, "%x", &data_1);
                fscanf(File_2, "%x", &data_2);

            if (data_1 != data_2)
                equal = 0; //   trovati dati diversi

        }

        if(equal == 0)
            printf("\nI due file non coincidono!\n");
        else
            printf("\nCircuito funzionante, i due file coincidono!\n");
    }

    return 0;
}

void CA_2(int num, int *num_bin, int sign){
    int i,j;
    int neg;

    num = abs(num);
    for(i=(row_dim - 1); i>=0; i--){            // conversione dei numeri i binario
        if(num%2 == 0 || num == 0 )
            num_bin[i] = 0;
        else
            num_bin[i] = 1;
        num /= 2;
    }

    neg = 0;
    if(sign == 0)                                         // ---------- CA2, se il numero è negativo
        for(i=(row_dim - 1); i>=0 && neg == 0; i--) {
            if (num_bin[i] == 1) {
                neg = 1;
                for (j = i - 1; j >= 0; j--)
                    num_bin[j] = 1 - num_bin[j];

            }
        }

    num_bin[0] = 1 - sign;  //si complementa il bit di segno
}