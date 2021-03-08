function [] = mat2mif(filename,memory_width,memory_depth,data)
%mat2mif Convert Matlab matrix to Altera/Intel Memory Initialisation Format 
%   Input arguments:
%
%   filename     : File name of output file e.g. 'data.mif'.
%   memory_width : Width of target memory in bits.
%   memory_depth : Depth of target memory in words.
%   data         : Data for encoding into mif file.

% Check data can fit within target memory size
data = round(data(:));
data_depth = numel(data);
if data_depth > memory_depth
    error('Length of input data depth greater than target memory depth.')
end

% Check data can fit within target memory width
max_unsigned_value = (2^memory_width)-1;
data_range_errors = find( data > max_unsigned_value );
if any(data_range_errors)
    error('Input data value at index %d exceeds target data width.',...
        data_range_errors(1));
end

% Check data values are all positive
data_sign_errors = find( data < 0 );
if any(data_sign_errors)
    error('Input data value at index %d is negative. Values must be unsigned.',...
        data_sign_errors(1));
end

% % Calculate number of hex digits required for memory_width
if ~endsWith(filename,'.mif')
    filename = [filename '.mif'];
end
fileID = fopen(filename,'w');

if fileID == -1
    error('Failed to open file.')
end

fprintf(fileID,'DEPTH = %u;\n',memory_depth);
fprintf(fileID,'WIDTH = %u;\n',memory_width);
fprintf(fileID,'ADDRESS_RADIX = UNS;\n');
fprintf(fileID,'DATA_RADIX = HEX;\n');

fprintf(fileID,'CONTENT BEGIN\n');

% Initialise all memory values as 0
fprintf(fileID,'[0..%u] : 0;\n',memory_depth-1);

% Output non zero data values
non_zero_data = find( data > 0 );

for idx = non_zero_data(:)'
    fprintf(fileID,'%u : %x;\n', idx-1, data(idx) );  
end

fprintf(fileID,'END;\n');

fclose(fileID);

end



