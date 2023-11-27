//***********************************************************************************************************************************
// LabelConversions.ijm 
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

requires("1.50f");
arg = getArgument();
strArray = split(arg, ",");

input = strArray[0];
output = strArray[1];

print(" \n");
print("Running batch analysis with arguments:");
print("input="+input);
print("output="+output);

print("Installing Bio-Formats Macro Extensions ....");
run("Bio-Formats Macro Extensions");
wait(1000);
print("\\Update:Installing Bio-Formats Macro Extensions .... Done!");

processFolder(input, output);
run("Conversions...", "scale");
run("Quit");

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input, output) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i], output);
		if(endsWith(list[i], "_cp_masks.tif"))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	Ext.openImagePlus(input + File.separator + file);
	run("Conversions...", " ");
	run("16-bit");
	NewfileName = replace(file,"_cp_masks.tif",".tif");
	saveAs("tiff",  output + File.separator + NewfileName);
	run("Close All");
}
