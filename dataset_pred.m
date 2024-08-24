load('dlav.mat');
load('input_dataset.mat');
indp_data=dataset(:,:);
depd_data=dlav21(:,4:);
if size(input_data,1)
    ~=length(depd_data,1)
    error('row dimensions of depd data and inpd data do not match');
end
final_dataset=[indp_data,depd_data];
save('final_dataset.mat',"final_dataset")
