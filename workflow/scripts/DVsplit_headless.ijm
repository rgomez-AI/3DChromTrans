//***********************************************************************************************************************************
// tifsplit - tif images Split channels.
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

print(" \n");
print("Running batch analysis with arguments:");
print("input="+input);
print("output="+output);

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
		if(endsWith(list[i], ".dv"))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	Ext.openImagePlus(input + File.separator + file);
	Ext.setId(input + File.separator + file);
	Ext.getSizeC(numC);
	WavesN=newArray(numC);
	for (i=1;i<=numC;i++)
  	{
    	metafield="Wavelength "+i+" (in nm)";
    	wtmp="";
    	Ext.getMetadataValue(metafield,wtmp);
    	WavesN[i-1]=wtmp;
  	}
	 
	k = "";
	for (i = 0; i <lengthOf(WavesN); i++) {
	
		if (WavesN[i] == "614") 
			j = 1;
		else if (WavesN[i] == "517")
	   		j = 2;
    	else if (WavesN[i] == "465")
        	j = 3;
    	else
       		exit("ERROR: Channels wavelength mismatch");
    	k = k + j;
	}

	if (k != "123") {
		run("Arrange Channels...", "new="+k);
	}
	Ext.close();
	
	id = getImageID();
	getDimensions(width, height, channels, slices, frames);
	
	// Split channels and save in ".tif" file
	ImageTitle = getTitle();	
	filename = replace(ImageTitle,".dv","");
	filename = replace(filename, ".", "_");
	filename = replace(filename, "-", "_");
	filename = replace(filename, "\\", "_");
	filename = replace(filename, "/", "_");
	filename = replace(filename, " ", "_");
	rename(filename);
	if (channels > 1) {
		run("Split Channels");
		for (j = 1; j <= channels; j++) {
			selectWindow("C" + j + "-" + filename);
			// Save Results 
			saveAs("TIFF", output + File.separator + filename + "_ch" + IJ.pad(j-1, 2));
		}
	}
	run("Close All");
}
