import numpy as np
import os

indir = r"file"
lon_range = [25, 42]
lat_range = [-15, 6]
intv = 0.5
# per_list = [5]
per_list = [5, 7, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45]

def _mesh(lon_range, lat_range, intv, cushion = 1):
    '''
    This function create a mesh for study area
    Looping order: latitude and longitude, range[0] to range[1].
    '''
    lon_array = np.arange(lon_range[0] - intv*cushion, lon_range[1] + intv*cushion + intv, intv)
    lat_array = np.arange(lat_range[0] - intv*cushion, lat_range[1] +intv*cushion + intv, intv)
    lat_array = lat_array[::-1]
    grid_lon = [l for l in lon_array for i in range(len(lat_array))]
    grid_lat = list(lat_array) * len(lon_array)
    return lat_array, lon_array, grid_lat, grid_lon

def get_velocity(per):
    inlon, inlat, invel = np.loadtxt(f'{indir}/Africa_300_100_{per}.1', unpack = True)
    lat_array, lon_array, grid_lat, grid_lon = _mesh(lon_range, lat_range, intv)
    outvel = []
    grid_vel = []
    misfit = []
    for lon in lon_array:
        try:

            ver_lon = np.interp(lat_array, inlat[inlon == lon], invel[inlon == lon])
        except ValueError:
            ver_lon = np.array([np.average(invel)] * len(lat_array))
        misfit_lon = np.array([0.3] * len(ver_lon))
        grid_vel.extend(ver_lon)
        ver_lon = np.round(ver_lon, 8).astype(str)
        misfit_lon = misfit.extend(np.round(misfit_lon, 8).astype(str))
        misfit_lon = misfit.extend([''])
        outvel.extend(ver_lon)
        outvel.extend([''])
    return outvel,grid_vel, misfit, grid_lat, grid_lon
    

if __name__ == '__main__':
    for per in per_list:
        velocity, grid_vel, misfit, grid_lat, grid_lon = get_velocity(per)
        velocity = np.insert(velocity, 0, 
            [str(int((lat_range[1]-lat_range[0]) / intv + 1)), str(lat_range[1]), str(intv), ''])
        misfit = np.insert(misfit, 0, 
            [str(int((lon_range[1]-lon_range[0]) / intv + 1)), str(lon_range[0]), str(intv), ''])
        np.savetxt(f'gridi.{per}.vtx', np.column_stack((velocity, misfit)), fmt="%s")
        np.savetxt(f'vgridc.{per}.txt', np.column_stack((grid_lat, grid_lon, grid_vel)), fmt="%.6f")
