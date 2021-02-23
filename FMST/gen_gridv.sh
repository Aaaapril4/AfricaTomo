avelfile=./velocity.dat

for per in 5 7 9 13 17 21 25 29 33 37 41 45 49 53 57 61 65
do

avel=`cat $avelfile | awk '$1==per {print $2}' per="$per"`

cat > grid2dss.in << EOF
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Set output file name
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
gridi.$per.vtx
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
0                     c: Add checkerboard (0=no,1=yes)
0.80                  c: Maximum perturbation of vertices
20                    c: Checkerboard size (NxN)
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
done
