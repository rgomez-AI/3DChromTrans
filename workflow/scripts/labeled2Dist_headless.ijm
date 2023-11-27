//***********************************************************************************************************************************
// labeled2dist - Performs "euclide" distance transformation over labeled segmentation "tif" file
//
// Note: requiere MorphoLibJ Plus	
// In Fiji, you just need to add the IJPB-plugins update site:				
// 1- Select Help > Update... from the Fiji menu to start the updater.
// 2- Click on Manage update sites. This brings up a dialog where you can activate additional update sites.
// 3- Activate the IJPB-plugins update site and close the dialog. Now you should see an additional jar file for download.
// 4- Click Apply changes and restart Fiji.		
//
// Plugin MorphoLibJ Citation:
// David Legland, Ignacio Arganda-Carreras, Philippe Andrey; 
// MorphoLibJ: integrated library and plugins for mathematical morphology with ImageJ. 
// Bioinformatics 2016; 32 (22): 3532-3534. doi: 10.1093/bioinformatics/btw413
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
//mPath = getDir("file");
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
Nucleus_present="0";

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
			Nucleus_present="0";
			
	}
	if (ImageNumberID == ImageNumber) {
		N_ID = Table.getString("Nucleus_ID", i);
		Nucleus_present = Nucleus_present + "," + d2s(N_ID,0);
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

function DistMapGenerator(input, NewfileName, FileName, Nucleus_removed) { 
// Recontruct cell images and generate its Distances Map
	selectWindow(FileName);
	Title = getTitle();
	run("Duplicate...", "title=duplicate duplicate");
	run("Replace/Remove Label(s)", "label(s)="+ Nucleus_present +" final=0");
	imageCalculator("Difference stack",  Title  ,"duplicate");
	run("Chamfer Distance Map 3D", "distances=[Quasi-Euclidean (1,1.41,1.73)] output=[16 bits] normalize");
	saveAs("TIFF", input + File.separator + NewfileName);
	run("Close All");
}


