# Snakemake workflow: `3DChromTrans`

[![Snakemake](https://img.shields.io/badge/snakemake-≥6.3.0-brightgreen.svg)](https://snakemake.github.io)
[![GitHub actions status](https://github.com/<owner>/<repo>/workflows/Tests/badge.svg?branch=main)](https://github.com/<owner>/<repo>/actions?query=branch%3Amain+workflow%3ATests)


### A Snakemake workflow for measuring distances between two types of markers in [Chromosomal Translocation](https://en.wikipedia.org/wiki/Chromosomal_translocation)

The usage of this workflow is described also in the [Snakemake Workflow Catalog](https://snakemake.github.io/snakemake-workflow-catalog/?usage=<owner>%2F<repo>).

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this (original) <repo>sitory and its DOI (see above).


## Image acquisition settings for data generation

The Fluorescence In Situ Hybridization (FISH) assay was carried out
with the following fluorophores:
* Texas Red, Emission Wavelength=614nm
* Alexa Fluor 488, Emission Wavelength=517nm

For nuclei detection, cells were stained with 
* DAPI, Emission Wavelength=465nm

3D multiplex images of whole cells were acquired with ZEISS LMS 980 microscope in airyscan mode.
* Objective Immersion="Oil" LensNA="1.4"
* Model="Plan-Apochromat 63x/1.4 Oil DIC (UV) VIS-IR M27"
* NominalMagnification="63"
* WorkingDistance="193.0" WorkingDistanceUnit="um"
* Zoom="3.6"
* Voxel Size: 0.073x0.073x0.130

## Installation

You will need a current version of `snakemake` to run this workflow. To get `snakemake` please follow the install [instructions](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) on their website, but in brief once `conda` and `mamba` are installed you can install `snakemake` with:

```
mamba create -n snakemake -c conda-forge -c bioconda snakemake
```

Afterwards you can activate the `conda` environment and download the repository. And all additional dependencies will be handled by `snakemake`.

```
conda activate snakemake
git clone https://gitlab.linux.crg.es/rgomez/3dchromtrans.git
```

## Running

All parameters are described in `config/README.md` and you can modify any of them
by modifying `config/config.yaml`. To execute change current directory to the directory `workflow` where `Snakefile` is located.

```
snakemake --cores all --use-conda Data_Analysis
```

## Output

The file `results/Results_in_um_Nuclei.xlsx` will contain all distances between the two markers per each nuclei and per image
the `results/Results_in_um_Markers.xlsx` detail information about each marker localization relative to the nucleus surface and its absolute coordinates as well.

## 3D Visualization

You will need a current version of `napari` as python package, please follow the install [instructions](https://napari.org/stable/tutorials/fundamentals/installation.html) on their website.

Afterwards you can activate the `napari` environment

```
conda activate napari-env
```

Then change current directory to the directory `workflow/scripts` where `3D_visualization.py` is located for script execution.

```
python 3D_visualization.py
```
<p align="center">
  <img width="496"  src="img/3Dvisualization.png" alt="3D visualization">
</p>


# TODO

* Replace `<owner>` and `<repo>` everywhere in the template (also under .github/workflows) with the correct `<repo>` name and owning user or organization.
* Replace `<name>` with the workflow name (can be the same as `<repo>`).
* Replace `<description>` with a description of what the workflow does.
* The workflow will occur in the snakemake-workflow-catalog once it has been made public. Then the link under "Usage" will point to the usage instructions if `<owner>` and `<repo>` were correctly set.