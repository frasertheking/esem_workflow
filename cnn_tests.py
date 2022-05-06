### Source: duncanwp's ESEM project (https://github.com/duncanwp/ESEm)
### Copyright 2019-2021 Duncan Watson-Parris

from esem import cnn_model
from esem.utils import get_random_params
import matplotlib.pyplot as plt
import numpy as np
import matplotlib 
import cartopy.crs as ccrs

def plot_map(x, figsize, save_path, cbar=True, error=False, set_bounds=True):
    assert len(x.shape) == 2, 'can only plot 2d map, len(x.shape) != 2'
    plt.figure(figsize=figsize)
    ax = plt.axes(projection=ccrs.Mollweide(central_longitude=180))
    if set_bounds:
        if error:
            vmin, vmax = -0.2, 0.2
        else:
            vmin, vmax = 0, 1
    else:
        vmin, vmax = None, None
    im = ax.imshow(x,
        transform=ccrs.PlateCarree(central_longitude=180),
        extent=[-180, 180, 90, -90],
        cmap='bwr')

    ax.coastlines(resolution='110m')
    if cbar:
        plt.colorbar(im)
    ax.set_aspect('auto', adjustable=None)
    plt.savefig(save_path)
    print('Saved', save_path)
    plt.close()

def run_cnn(X_train, X_test, Y_train, Y_test):
    print('\nSPONGE')
    print(X_train.shape, X_test.shape, Y_train.to_numpy().shape, Y_test.to_numpy().shape)
    
    print()
    print(X_train)
   
    arr = [[] for x in range(7)] 
    for i,y in enumerate(Y_train.to_numpy()):
        for j in range(7):
            arr[j].append(Y_train.to_numpy()[i][j].reshape(96, 144))
   
    reshaped = np.asarray(arr)
    Y_train = np.moveaxis(reshaped, 0, -1)


    arr = [[] for x in range(7)]
    for i,y in enumerate(Y_test.to_numpy()):
        for j in range(7):
            arr[j].append(Y_test.to_numpy()[i][j].reshape(96, 144))

    reshaped = np.asarray(arr)
    Y_test = np.moveaxis(reshaped, 0, -1)

    model = cnn_model(X_train, Y_train)
    model.train()
    m, v = model.predict(X_test)

    test = np.swapaxes(m[0],0,2)
    test = np.swapaxes(test,1,2)
    np.save('output/esem_results', test)

