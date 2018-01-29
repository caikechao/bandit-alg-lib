function [P, K, L, h, T, S, arm_para] = readDataHeader(file_name)
% Read the data file header

file_id = fopen(file_name, 'r');

P = 0;
K = 0;
L = 0;
h = 0;
T = 0;
S = 0;

i_line = fgetl(file_id);

while ischar(i_line) && i_line(1) == '#'
    parts = strsplit(i_line, ':');
    var_name = i_line(2);
    switch var_name
        case 'K'
            K = str2num(parts{2});
        case 'L'
            L = str2num(parts{2});
        case 'h'
            h = str2num(parts{2});
        case 'T'
            T = str2num(parts{2}); %#ok<*ST2NM>
        case 'S'
            S = str2num(parts{2});
        case 'p'
            P = P + 1;
        case 'A'           
            arml1 = str2num(parts{2});
        case 'B'
            arml2 = str2num(parts{2});
    end
    i_line = fgetl(file_id);
end

arm_para = [arml1;arml2];
fclose(file_id);

end