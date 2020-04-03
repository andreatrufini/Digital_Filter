#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#define row_dim 8
#define col_dim 1024

void CA_2(int num, int *num_bin, int sign);

int main() {
    FILE *Mem_A_data;
    FILE *Mem_B_data;

    int Mem_A[col_dim], Mem_B[col_dim];
    int Mem_A_CA2[row_dim], Mem_B_CA2[row_dim];
    int i,j;
    int sign=1;

    Mem_A_data = fopen("Mem_A_data", "w");
    srand(time(NULL));
    if (!Mem_A_data) {
        printf("Impossibile aprire il file 'Mem_A_out'");
        return 1;
    }

    for (i = 0; i < col_dim; i++) {
        sign = rand() % 2;
        if (sign == 0)
            Mem_A[i] = (-1) * rand() % 129;
        else
            Mem_A[i] = rand() % 128;

       // printf("%d\n", Mem_A[i]);
        CA_2(Mem_A[i], Mem_A_CA2, sign);
        for(j=0; j<row_dim; j++)
            fprintf(Mem_A_data, "%d", Mem_A_CA2[j]);

        fprintf(Mem_A_data, "\n");
    }
    fclose(Mem_A_data);
    for(i=0; i<1024; i++){
        if(Mem_A[i] < 0 && Mem_A[i]%4 != 0) {
            Mem_B[i] = (Mem_A[i] / 4) - 1;
            printf("%d\n", Mem_B[i]);
        }
        else
            Mem_B[i] = (Mem_A[i]/4);

        if(i>0)
            Mem_B[i] += Mem_A[i-1];
        if(i>2)
            Mem_B[i] += (-2)*Mem_A[i-3];
        if(Mem_B[i] > 127)
            Mem_B[i] = 127;
        if(Mem_B[i] < -128)
            Mem_B[i] = -128;
    }

    Mem_B_data = fopen ("Mem_B_data", "w") ;
    if (Mem_B_data) {
        for (i = 0; i < col_dim; i++) {
            CA_2(Mem_B[i], Mem_B_CA2, sign);
            fprintf(Mem_B_data, "%d %d ",Mem_A[i], Mem_B[i]);
            for(j=0; j<row_dim; j++)
                fprintf(Mem_B_data, "%d", Mem_B_CA2[j]);

            fprintf(Mem_B_data, "\n");
        }

        //fprintf(Mem_A_data, "\n");
    }else
        printf("Impossibile aprire il file 'Mem_A_out'");

    return 0;
}

void CA_2(int num, int *num_bin, int sign){
    int i,j;
    int neg;

    num = abs(num);
    for(i=(row_dim - 1); i>=0; i--){
        if(num%2 ==0 || num ==0 )
            num_bin[i] = 0;
        else
            num_bin[i] = 1;
        num /= 2;
    }

    neg = 0;
    if(sign == 0)                                         // ---------- CA2
        for(i=(row_dim - 1); i>=0 && neg == 0; i--) {
            if (num_bin[i] == 1) {
                neg = 1;
                for (j = i - 1; j >= 0; j--)
                    num_bin[j] = 1 - num_bin[j];

            }
        }

    num_bin[0] = 1 - sign;
}