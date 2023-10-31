//**********************************************************************************************************************************
// ResliceZandScale.ijm 
//
// Citation: Fiji
// Schindelin, J.; Arganda-Carreras, I. & Frise, E. et al. (2012), "Fiji: an open-source platform for biological-image analysis", 
// Nature methods 9(7): 676-682, PMID 22743772, doi:10.1038/nmeth.2019 (on Google Scholar).
//
//  Date: 2022/11/04
//  Author: Raul Gomez
//  Contact information:
//  e-mail: raul.gomez@crg.eu
//***********************************************************************************************************************************

requires("1.54f");
arg = getArgument();
strArray = split(arg, ",");

input = strArray[0];
output = strArray[1];
scale = strArray[2];

print(" \n");
print("Running batch analysis with arguments:");
print("input="+input);
print("output="+output);
print("scale="+scale);

print("Installing Bio-Formats Macro Extensions ....");
run("Bio-Formats Macro Extensions");
wait(1000);
print("\\Update:Installing Bio-Formats Macro Extensions .... Done!");

processFolder(input, output);
run("Quit");

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input, output) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i], output);
		if(endsWith(list[i], ".tif"))
			processFile(input, output, list[i], scale);
	}
}

function processFile(input, output, file, scale) {
	Ext.openImagePlus(input + File.separator + file);
	// Makes field of view squared and even number
	getDimensions(width, height, channels, slices, frames);
	if(width != height){
		if(width>height){
			if ((height/2) - floor(height/2) > 0) {
				makeRectangle(0, 0, height-1, height-1);
				run("Crop");
			} else {
				makeRectangle(0, 0, height, height);
				run("Crop");
			}

		} else {
			if ((width/2) - floor(width/2) > 0) {
				makeRectangle(0, 0, width-1, width-1);
				run("Crop");
			} else {
				makeRectangle(0, 0, width, width);
				run("Crop");
			}
		}
	}
	
	// Makes voxels perfect cubes with even number of Slices 
	getVoxelSize(width, height, depth, unit);
	run("Reslice Z", "new="+width);
	z = nSlices;
	if ((z/2) - floor(z/2) > 0) {
		setSlice(z);
		run("Delete Slice");
	} 
	
	// Scale down the image
	getDimensions(width, height, channels, slices, frames);
	run("Scale...", "x="+1/scale+" y="+1/scale+" z="+1/scale+" width="+width/scale+" height="+height/scale+" depth="+slices/scale +"interpolation=Bilinear average process");
	saveAs("tiff",  output + File.separator + file);
	run("Close All");
}