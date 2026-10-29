function [bin, decimal] = voltage2bin(v_in, min_voltage, max_voltage, bits)

del_v = (max_voltage - min_voltage) / (2^(bits));

bin = (v_in - min_voltage) / del_v;

decimal = ((v_in - min_voltage)/(max_voltage - min_voltage)) * (2^(bits) - 1);

end