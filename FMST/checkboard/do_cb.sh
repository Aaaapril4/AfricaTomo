if [ ! -e ../output_cb ]
then
    mkdir ../output_cb
fi

avelfile=../velocity.dat
parafile=../para.dat
sizefile=../checksize.dat
# get the average velocity to generate grid2dss.in which can be used to generate checkboard velocity
for per in 5 7 9 13 17 21 25 29 33 37 41 45
#for per in 7 21 41
do

    echo $per
    avel=`cat $avelfile | awk '$1==per {print $2}' per="$per"`
    damping=`cat $parafile | awk '$1==per {print $2}' per="$per"`
    smoothing=`cat $parafile | awk '$1==per {print $3}' per="$per"`
    size=`cat $sizefile | awk '$1==per {print $2}' per="$per"`
cat > grid2dss.in << EOF
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Set output file name
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
gridi_cb.$per.vtx
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Set grid size and location
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
43                    c: Number of grid points in theta (N-S)
35                    c: Number of grid points in phi (E-W)
6      -15.0          c: N-S range of grid (degrees)
25.0    42.0          c: W-E range of grid (degrees)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Set grid velocity values
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
$avel                 c: Background velocity
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Optionally apply random structure
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0                     c: Add random structure (0=no,1=yes)
0.80                  c: Standard deviation of random noise
12324                 c: Random seed for noise generation
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Uncertainty of model
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
1                     c: Add a priori model covariance (0=no,1=yes)?
0.3                   c: Diagonal elements of covariance matrix
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Optionally apply checkerboard
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
1                     c: Add checkerboard (0=no,1=yes)
0.10                  c: Maximum perturbation of vertices
$size                     c: Checkerboard size (NxN)
0                     c: Use spacing (0=no,1=yes)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Optionally, apply spikes
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0                     c: Apply spikes (0=no,1=yes)
2                     c: Number of spikes
-2.40                 c: Amplitude of spike 1
-12.1  135.0          c: Coordinates of spike 1
7.40                  c: Amplitude of spike 2
-31.4  135.0          c: Coordinates of spike 2
EOF

    grid2dss
    rm grid2dss.in

    cp ../FMM_input$per otimes.dat
    cp ../sources."$per".dat sources.dat
    cp ../receivers."$per".dat receivers.dat
    cp gridi_cb."$per".vtx gridi.vtx
    cp gridi.vtx gridc.vtx

    fm2dss
    rm otimes.dat
    synthtss
    rm *.out
    rm gridi.vtx
    rm gridc.vtx
    cp ../gridi."$per".vtx gridi.vtx
    
    sed -i '12c '$damping'' subinvss.in
    sed -i '15c '$smoothing'' subinvss.in
    
    zsh ttomoss
    
    tslicess
    mv gridi_cb."$per".vtx ../output_cb
    mv gridc.vtx ../output_cb/gridc."$per".vtx
    mv grid2dv.z ../output_cb/grid2dv."$per".z
    mv raypath.out ../output_cb/raypath."$per".out
    mv residuals.dat ../output_cb/residuals."$per".dat
    cp ../sources."$per".dat ../output_tomo
    cp ../receivers."$per".dat ../output_tomo
    rm *.dat
    rm *.out
    rm *.vtx
done

python3 gen_mask.py
sh PLOT_cbr_int.sh
