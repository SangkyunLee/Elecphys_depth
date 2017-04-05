%Banks to EIB-27 x 4 :  A:J2
N = 12; %columns
M = 8;  %rows
Banks = ['B','A','A','B','C','D','D','C'];
%reverse connction: DCBA:J2J1J3J4
%Banks = ['C','D','D','C','B','A','A','B'];

fp = fopen('Tetrode_96ch_Map_New.cmp','w');
fprintf(fp,'//Cerebus Map File for Andreas Tetrode 96ch\n');
fprintf(fp,'//Banks Connection : D,C,B,A==J2,J1,J3,J4\n');
fprintf(fp,'96Ch Tetrode Map with Electrode Number\n');

for k = 1 : length(Banks)
    Bank = Banks(k);
    for n = 1 : N
        Column = n - 1;
        Row = M - k;
        Pin = 2*n - mod(k,2);
        ElecNum = (Bank - 'A')*32 + Pin;
        %fprintf(fp,'%d\t%d\t%c\t%d\n',n-1,M-k,Bank,2*n - mod(k,2));
        fprintf(fp,'%d\t%d\t%c\t%d\tElec%d\n',Column,Row,Bank,Pin,ElecNum);
    end
end

fclose(fp);
