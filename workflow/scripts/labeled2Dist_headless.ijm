//***********************************************************************************************************************************
// labeled2dist - Performs "euclide" distance transformation over labeled segmentation "tif" file
//
// Citation: Fiji
// Schindelin, J.; Arganda-Carreras, I. & Frise, E. et al. (2012), "Fiji: an open-source platform for biological-image analysis", 
// Nature methods 9(7): 676-682, PMID 22743772, doi:10.1038/nmeth.2019 (on Google Scholar).
//
//  Date: 2022/11/19
//  Author: Raul Gomez
//  Contact information:
//  e-mail: raul.gomez@crg.eu
//***********************************************************************************************************************************

requires("1.50f");
arg = getArgument();
strArray = split(arg, ",");

input = strArray[0];

print(" \n");
print("Running batch analysis with arguments:");
mPath = File.directory();
parentPath =File.getParent(mPath);
Path = parentPath + File.separator + input;
print("input="+Path);

print("Installing Bio-Formats Macro Extensions ....");
run("Bio-Formats Macro Extensions");
wait(1000);
print("\\Update:Installing Bio-Formats Macro Extensions .... Done!");

open(Path + File.separator + "Results_in_um_Nuclei.csv");
IJ.renameResults("Results");

ImageNumberID = 0;
Nucleus_present=newArray();

for (i = 0; i <nResults; i++) {
	ImageNumber = getResult("ImageNumber", i);
	
	if (ImageNumberID < ImageNumber && nImages<1) {
		    FileName = Table.getString("FileName_DAPI", i);		    
    		FileName = FileName + "f";
    		NewfileName = loadImageFile(input, FileName, NewfileName); 		
    		ImageNumberID = ImageNumber;

    		
	} else if (ImageNumberID < ImageNumber ) {
			DistMapGenerator(input, NewfileName, FileName, Nucleus_present);
			run("Close All");
			FileName = Table.getString("FileName_DAPI", i);		    
    		FileName = FileName + "f";
    		NewfileName = loadImageFile(input, FileName, NewfileName);   		
    		ImageNumberID = ImageNumber;
    		Nucleus_counter = 0;
			Nucleus_present=newArray();
			
	}
	if (ImageNumberID == ImageNumber) {
		N_ID = Table.getString("Nucleus_ID", i);
		Nucleus_present = Array.concat(Nucleus_present, N_ID);
	}

}
DistMapGenerator(input, NewfileName, FileName, Nucleus_present);
selectWindow("Results");
close("Results");
run("Quit");


function loadImageFile(input, FileName, NewfileName) { 
// load Image file and create a mask image
	Ext.openImagePlus(input + File.separator + FileName);
    NewfileName = replace(FileName,".tiff","-dist");
	return NewfileName;
}

function DistMapGenerator(input, NewfileName, FileName, Nucleus_present) { 
// Recontruct cell images and generate its Distances Map
	selectWindow(FileName);
	ID = getImageID();
	DistMap(Nucleus_present[0]);
	rename("Image0");
	for (j = 1; j < lengthOf(Nucleus_present); j++){
		selectImage(ID);
		DistMap(Nucleus_present[j]);
		rename("Image"+j);
		imageCalculator("OR stack", "Image0","Image"+j);
		selectWindow("Image"+j);
		close();
	}
	run("16-bit");
	selectWindow("Image0");
	saveAs("TIFF", input + File.separator + NewfileName);
	run("Close All");
}

function DistMap(i){
// Create distances map
	run("Duplicate...", "duplicate");	
	run("Macro...", "code=v=(v=="+i+") stack");
	run("Multiply...", "value=65535 stack");
	run("Make Binary", "background=Dark calculate black");
	run("Distance Map", "stack");
}

