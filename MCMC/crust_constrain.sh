path=/mnt/ufs18/nodr/home/jieyaqi/east_africa/inversion6015
for sta in `ls $path/station` 
    do python3 crust_constrain.py $path/station/$sta/run_info
    mv crust_para.dat $path/station/$sta
done

for grid in `ls $path/grid`  
    do python3 crust_constrain.py $path/grid/$grid/run_info
    mv crust_para.dat $path/grid/$grid
done

