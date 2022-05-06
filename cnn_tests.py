#import iris
#from utils import get_bc_ppe_data
from esem import cnn_model
from esem.utils import get_random_params
#import iris.quickplot as qplt
import matplotlib.pyplot as plt
import numpy as np
import matplotlib 
import cartopy.crs as ccrs
#import iris.plot as iplt
#import iris.analysis.maths as imath


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

#ppe_params, ppe_aaod = get_bc_ppe_data()
#ppe_aaod.transpose((0,2,3,1))
#n_test = 5

#X_test, X_train = ppe_params[:n_test], ppe_params[n_test:]
#Y_test, Y_train = ppe_aaod[:n_test], ppe_aaod[n_test:]

#print(type(X_test))
#print(type(X_train))
#print(type(Y_test))
#print(type(Y_train))

#X_train = np.load('train_x.csv.npy')
#X_test = np.load('test_x.csv.npy')
#Y_train = np.load('train_y.csv.npy')
#Y_test = np.load('test_y.csv.npy')

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

    # print(m[0])
    print(m[0].shape)
    test = np.swapaxes(m[0],0,2)
    test = np.swapaxes(test,1,2)
    print(test.shape)
    print(test[0].shape)
    # print(type(m))
    # print(m[0].collapsed('time', iris.analysis.MEAN).shape)
    # print(m[0].collapsed('time', iris.analysis.MEAN))
    
    # plot_map(m[0].collapsed('time', iris.analysis.MEAN).data, (12, 8), 'testing.png', set_bounds=False)

    np.save('esem_results', test)
    plot_map(test[0], (12, 8), 'images/out_1.png', set_bounds=True)
    plot_map(test[1], (12, 8), 'images/out_2.png', set_bounds=True)
    plot_map(test[2], (12, 8), 'images/out_3.png', set_bounds=True)
    plot_map(test[3], (12, 8), 'images/out_4.png', set_bounds=True)
    plot_map(test[4], (12, 8), 'images/out_5.png', set_bounds=True)
    plot_map(test[5], (12, 8), 'images/out_6.png', set_bounds=True)
    plot_map(test[6], (12, 8), 'images/out_7.png', set_bounds=True)

# # Plotting 
# plt.figure(figsize=(12, 8))
# plt.subplot(2,2,1)
# qplt.pcolormesh(m[0].collapsed('time', iris.analysis.MEAN))
# plt.gca().set_title('Predicted')
# plt.gca().coastlines()

# plt.subplot(2,2,2)
# qplt.pcolormesh(Y_test[0].collapsed('time', iris.analysis.MEAN))
# plt.gca().set_title('Test')
# plt.gca().coastlines()

# plt.subplot(2,2,3)
# qplt.pcolormesh((m.collapsed(['sample', 'time'], iris.analysis.MEAN)-Y_test.collapsed(['job', 'time'], iris.analysis.MEAN)), cmap='RdBu_r', vmin=-0.01, vmax=0.01)
# plt.gca().coastlines()
# plt.gca().set_title('Difference')
# plt.savefig('cnn.png')
