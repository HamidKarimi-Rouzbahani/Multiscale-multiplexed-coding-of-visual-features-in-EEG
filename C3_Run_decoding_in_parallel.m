

function C3_Run_decoding_in_parallel(poolSize,subjs)
parpool(poolSize); % Warning: you must call matlabpool with brackets
SOA=1;
parfor subj=1:subjs
    [Subject] = C4_different_window_length_decoding_parallel(subj,SOA);
%     [Subject] = C4_different_wind_length_non_avg_dec_para(subj,SOA);
    display(['Subj #',num2str(Subject),' Done!'])
end
delete(gcp('nocreate'))
end


