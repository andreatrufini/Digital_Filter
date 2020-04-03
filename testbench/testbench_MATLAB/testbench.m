clc;
clear;
close all;

%Creazione matrice binaria casuale
 for CNT_1024 = 1:1024
    MEM_A_BIN(CNT_1024, 1:8) = randi([0 1], 1, 8);
 end

 int16 MEM_A
%Conversione matrice MEM_A_BIN in decimale (MEM_A_BIN => MEM_A)
for CNT_1024 = 1:1024
    MEM_A(CNT_1024) = typecast(uint8(bin2dec(num2str(MEM_A_BIN(CNT_1024, 1:8)))), 'int8');
end

REG_AVERAGE = int16(0);
%Scrittura dati in MEM_B
for CNT_1024 = 1:1024
    REG_FILTER = int16(0); %Reset somma
    REG_SAMPLES = int16(MEM_A(CNT_1024)) %Read primo dato
    
    REG_AVERAGE = REG_AVERAGE + REG_SAMPLES; %Accumulo per media
    REG_FILTER = idivide(REG_SAMPLES, 4, 'floor') %Prima operazione, divide troncando al num. più basso
    
    if(CNT_1024 - 1 >= 1)
        REG_SAMPLES = int16(MEM_A(CNT_1024 - 1)); %Read secondo dato
        REG_FILTER = REG_FILTER + REG_SAMPLES; %Seconda operazione
        if(CNT_1024 - 3 >= 1)
            REG_SAMPLES = int16(MEM_A(CNT_1024 - 3)); %Read terzo dato
            REG_FILTER = REG_FILTER - 2*REG_SAMPLES; %Terza operazione
        end
    end
    
    if((-1)^(CNT_1024-1) < 0)
        REG_FILTER = -REG_FILTER; %Inversione ogni 2 cicli
    end
    
    if(REG_FILTER >= -128 && REG_FILTER <= 127) %"Overflow" del dato
        MEM_B(CNT_1024) = REG_FILTER;
    else
        if(REG_FILTER < 0)
        MEM_B(CNT_1024) = -128;
        elseif(REG_FILTER >0)
        MEM_B(CNT_1024) = 127;
        end
    end
end

REG_AVERAGE = idivide(REG_AVERAGE, 1024, 'floor') %Divisione media

%Conversione matrice MEM_B in binario (MEM_B => MEM_B_BIN)
for CNT_1024 = 1:1024
    num = MEM_B(CNT_1024)
    if(num < 0)
        MEM_B_BIN(CNT_1024, 1:8) = ['1', dec2bin(2^7 + num, 7)];
    else
        MEM_B_BIN(CNT_1024, 1:8) = dec2bin(num, 8);
    end
end

%Creazione file binari matrice A e B
dlmwrite("MEM_A.txt", MEM_A, 'delimiter', '\n');
dlmwrite("MEM_B.txt", MEM_B, 'delimiter', '\n');
dlmwrite("MEM_A_BIN.txt", MEM_A_BIN, 'delimiter', '');
dlmwrite("MEM_B_BIN_MATLAB.txt", MEM_B_BIN, 'delimiter', '');