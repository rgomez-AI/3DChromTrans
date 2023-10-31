# -*- coding: utf-8 -*-
"""
The 3D_visualization.py script allow to plot the coordinates of selected markers coming
from Fluorescence in situ hybridization (FISH) assay in a multi-dimensional images using napari.

From one side the script receive as input the image datasets in ".tif" format located 
in the CP_DATASET folder with the following order:
CH02- Nuclear marker
CH00- RED marker
CH01- GREEN marker

From another side it also receive as an input  the excel file containing the coordinates 
of the markers together with the its corresponding distances map image all located at CP_OUT directory.

By default the voxel size is set to a constant value of [0.0731, 0.0731, 0.0731]

Created on Tue Nov  1 06:58:38 2022
@author: Raul Gomez-Riera
"""
__author__ = "Raul Gomez-Riera"
__copyright__ = "Copyright 2022, Center for Genomic Regulation"
__email__ = "raul.gomez@crg.es"
__license__ = "BSD 3-Clause License"
__version__ = "1.0"

import sys
import os
import napari
import numpy as np
import pandas as pd
import tkinter as tk
from tkinter.filedialog import askopenfilename, askdirectory

# SCALE constant is the voxel size after Z-reslicing to become the image in an isotropic space.
SCALE  = [0.0731, 0.0731, 0.0731]

class FileBrowser(tk.Tk):
    def __init__(self):
        super().__init__()

        self.title("3D Image visualization")
        self.resizable(False, False)
        self.geometry('660x300')
        
        self.FrameForImages = tk.LabelFrame(self, text="Choose Images Files")
        self.FrameForImages.grid(row=0, column=0, ipadx=10, ipady=4, padx=14, sticky='W')

        self.txtVarNucleus = tk.StringVar()
        self.btn_Nucleus = tk.Button(self.FrameForImages, text="CH02", command=self.browsefileNucleus)
        self.btn_Nucleus.grid(row=0, column=0, padx=14, pady=10, ipadx=7, sticky='W')

        self.txtNucleus = tk.Entry(self.FrameForImages, textvariable=self.txtVarNucleus)
        self.txtNucleus.grid(row=0, column=2, pady=10, ipadx=200, ipady=5)

        self.txtVarRED = tk.StringVar() 
        self.btn_RED = tk.Button(self.FrameForImages, text="CH00", command=self.browsefileRED)
        self.btn_RED.grid(row=2, column=0, padx=14, pady=0, ipadx=7 , sticky='W')

        self.txtRED= tk.Entry(self.FrameForImages, textvariable=self.txtVarRED)
        self.txtRED.grid(row=2, column=2, pady=3 ,ipadx=200, ipady=5)

        self.txtVarGREEN = tk.StringVar()
        self.btn_GREEN = tk.Button(self.FrameForImages, text="CH01", command=self.browsefileGREEN)
        self.btn_GREEN.grid(row=3, column=0, padx=14, pady=10, ipadx=7 , sticky='W')

        self.txtGREEN = tk.Entry(self.FrameForImages, textvariable=self.txtVarGREEN)
        self.txtGREEN.grid(row=3, column=2, pady=3 ,ipadx=200, ipady=5)

        self.FrameForAnalysis = tk.LabelFrame(self, text="Choose CellProfile Output Directory")
        self.FrameForAnalysis.grid(row=1, column=0, ipadx=10, ipady=5, padx=14, sticky='W')

        self.txtVar = tk.StringVar()
        self.btn_Open = tk.Button(self.FrameForAnalysis, text="Open", command=self.browsedirectory)
        self.btn_Open.grid(row=0, column=0, padx=14, pady=10, ipadx=7 , sticky='W')

        self.txtOpen = tk.Entry(self.FrameForAnalysis, textvariable=self.txtVar)
        self.txtOpen.grid(row=0, column=2, pady=3 ,ipadx=200, ipady=5)

        self.btn_clear = tk.Button(self, text="Clear", command=self.clear)
        self.btn_clear.grid(row=3, column=0, ipadx=30, ipady=10, padx=150, pady=10, sticky='W')

        self.btn_OK = tk.Button(self, text=" OK ", command=self.destroy)
        self.btn_OK.grid(row=3, column=0, ipadx=30, ipady=10, padx=400)
        
        
    def browsefileNucleus(self):
        filename = askopenfilename(title = "Select the Nuclei File",
                                   filetypes=(("tiff files",
                                               "*.tif"),
                                              ("All files","*.*")))
        self.txtNucleus.delete(0, tk.END)
        self.txtVarNucleus.set(filename)


    def browsefileRED(self):
        filename = askopenfilename(title = "Select the RED File",
                                   filetypes=(("tiff files",
                                               "*.tif"),
                                              ("All files","*.*")))
        self.txtRED.delete(0, tk.END)
        self.txtVarRED.set(filename)


    def browsefileGREEN(self):
        filename = askopenfilename(title = "Select the GREEN File",
                                   filetypes=(("tiff files",
                                               "*.tif"),
                                              ("All files","*.*")))
        self.txtGREEN.delete(0, tk.END)
        self.txtVarGREEN.set(filename)

    def browsedirectory(self):
        filename = askdirectory(title = "Select Directory")
        self.txtOpen.delete(0, tk.END)
        self.txtVar.set(filename)


    def clear(self):
        self.txtNucleus.delete(0, tk.END)
        self.txtRED.delete(0, tk.END)
        self.txtGREEN.delete(0, tk.END)
        self.txtOpen.delete(0, tk.END)
        
    
class Visualization3D():
    def __init__(self, 
                 pathN, 
                 pathRED, 
                 pathGREEN,
                 pathData):
        
        self.pathN = pathN
        self.pathRED = pathRED
        self.pathGREEN = pathGREEN
        self.pathData = pathData
        
        
        self.viewer = napari.Viewer(ndisplay=3)
        self.viewer.open(self.pathRED, name = 'RED')
        self.viewer.layers['RED'].opacity = 0.67
        self.viewer.layers['RED'].scale = SCALE
        self.viewer.layers['RED'].colormap = 'red'
        self.viewer.layers['RED'].contrast_limits=(635, 1303)

        self.viewer.open(self.pathGREEN, name = 'GREEN')
        self.viewer.layers['GREEN'].opacity = 0.84
        self.viewer.layers['GREEN'].scale = SCALE
        self.viewer.layers['GREEN'].colormap = 'green'
        self.viewer.layers['GREEN'].contrast_limits=(1486, 4229) 
       
        self.viewer.open(self.pathN, name = 'Nucleus')
        self.viewer.layers['Nucleus'].opacity = 0.45
        self.viewer.layers['Nucleus'].scale = SCALE
        self.viewer.layers['Nucleus'].colormap = 'gray'
        self.viewer.layers['Nucleus'].rendering = 'attenuated_mip'
        self.viewer.layers['Nucleus'].contrast_limits=(0, 20609)  
        
        FileName = os.path.basename(self.pathN)
        FileName_dist = FileName.split('.')[0] + "-dist.tif"
        DatapathImage = os.path.join(self.pathData, FileName_dist)
        
        self.viewer.open(DatapathImage, name = 'Dist-Map')
        self.viewer.layers['Dist-Map'].opacity = 0.36
        self.viewer.layers['Dist-Map'].scale = SCALE
        self.viewer.layers['Dist-Map'].colormap = 'turbo'
        self.viewer.layers['Dist-Map'].rendering = 'mip'
        self.viewer.layers['Dist-Map'].contrast_limits=(3,80)
        self.viewer.layers['Dist-Map'].visible = False
        
        
        

        Datapath = os.path.join(self.pathData, "Results_in_um_Nuclei.xlsx")
        data = pd.read_excel(Datapath, usecols= ['ImageNumber',         
                                                'Nucleus_ID', 
                                                'FileName_DAPI',
                                                'Location_Center_X',  
                                                'Location_Center_Y',  
                                                'Location_Center_Z'
                                                ])

        DatapathM = os.path.join(pathData, "Results_in_um_Markers.xlsx")
        dataM = pd.read_excel(DatapathM, usecols= ['ImageNumber',         
                                                   'Norm_Dist', 
                                                   'Location_Center_X',  
                                                   'Location_Center_Y',  
                                                   'Location_Center_Z',
                                                   'Marker'
                                                  ])

        
        idx = data['FileName_DAPI'] == FileName
        selectedImages = data.loc[idx,['ImageNumber']]
        selectedImages = selectedImages.ImageNumber.unique()
        
        Nucleus_ID = data.Nucleus_ID[idx]
        nucleus = Nucleus_ID.to_numpy()
        
        Location = data.loc[idx,['Location_Center_Z',
                                 'Location_Center_Y',
                                 'Location_Center_X'
                                 ]]
        
        points = Location.to_numpy()

        features = { 
                    'nucleus': nucleus       
                    }

        text = {
                'string': 'N {nucleus:.0f}',
                'size': 8,
                'color': 'yellow',
                'translation': np.array([3,-5, 0])
                }



        points = self.viewer.add_points(
                                data=points,
                                name='Nucleus centroid',
                                features=features,
                                text=text,
                                scale = SCALE,
                                size=3,
                                shading='spherical',
                                edge_width=0,
                                edge_width_is_relative=False,
                                visible=False
                                )


        #idxM = dataM['ImageNumber'] == int(selectedImages)
        idxM = dataM['ImageNumber'] == selectedImages[0]
        newDataM = dataM[idxM].reset_index(drop=True)
        idxRED = newDataM.Marker.str.startswith('RED')
        idxGREEN = newDataM.Marker.str.startswith('GREEN')
        
        Norm_DistRED =  newDataM.Norm_Dist[idxRED]
        Norm_DistValuesRED = Norm_DistRED.to_numpy()  
        MarkerRED = newDataM.Marker[idxRED].reset_index(drop=True)

        LocationRED = newDataM.loc[idxRED,['Location_Center_Z',
                                    'Location_Center_Y',
                                    'Location_Center_X'
                                    ]]

        pointsRED = LocationRED.to_numpy()
        featuresRED = { 
                     'Marker': MarkerRED, 
                     'Norm_Dist': Norm_DistValuesRED
                    }

        textRED = {
                'string': '{Marker} ({Norm_Dist:.2f})',
                'size': 8,
                'color': 'yellow',
                'translation': np.array([10,-5, 0])
                }
        
        points = self.viewer.add_points(
                                data=pointsRED,
                                name='RED Markers',
                                features=featuresRED,
                                text=textRED,
                                scale = SCALE,
                                size=3,
                                shading='spherical',
                                edge_width=0,
                                edge_width_is_relative=False,
                                visible=False
                                )


        Norm_DistGREEN =  newDataM.Norm_Dist[idxGREEN]
        Norm_DistValuesGREEN = Norm_DistGREEN.to_numpy()  
        MarkerGREEN = newDataM.Marker[idxGREEN].reset_index(drop=True)
        

        LocationGREEN = newDataM.loc[idxGREEN,['Location_Center_Z',
                                    'Location_Center_Y',
                                    'Location_Center_X'
                                    ]]

        pointsGREEN = LocationGREEN.to_numpy()
        featuresGREEN = { 
                     'Marker': MarkerGREEN, 
                     'Norm_Dist': Norm_DistValuesGREEN
                    }

        textGREEN = {
                'string': '{Marker} ({Norm_Dist:.2f})',
                'size': 8,
                'color': 'yellow',
                'translation': np.array([10,-5, 0])
                }
        
        points = self.viewer.add_points(
                                data=pointsGREEN,
                                name='GREEN Markers',
                                features=featuresGREEN,
                                text=textGREEN,
                                scale = SCALE,
                                size=3,
                                shading='spherical',
                                edge_width=0,
                                edge_width_is_relative=False,
                                visible=False
                                )
        
        self.viewer.scale_bar.visible = True
        self.viewer.scale_bar.unit = "um"
        self.viewer.reset_view()





def main () :
    """
    """
    ini_Browser = FileBrowser()
    ini_Browser.mainloop()
    pathN = ini_Browser.txtVarNucleus.get()
    pathRED = ini_Browser.txtVarRED.get()
    pathGREEN = ini_Browser.txtVarGREEN.get()
    pathData = ini_Browser.txtVar.get()  
    Visualization3D(pathN, pathRED, pathGREEN, pathData)
    napari.run()
    return 0



if __name__ == "__main__":
    sys.exit(main())
   