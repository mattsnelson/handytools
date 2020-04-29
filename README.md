# handytools

<!-- badges: start -->
<!-- badges: end -->

# work in progress

![construction](https://rsl.ethz.ch/research/researchtopics/dfab/_jcr_content/par/fullwidthimage/image.imageformat.fullwidth.299214605.jpg)



Oh hai there! Are you a biologist who spends *way* too much time copying and pasting data in Microsoft Excel? I was like you too once, before I found the light and started practising awesome reproducible research with R.

![Awesome - Bojack](https://media.giphy.com/media/xT0GqH01ZyKwd3aT3G/giphy.gif)

Over the course of my PhD I made many a handy little script for data wrangling the outputs of various experiments, icluding qPCR and ELISA plates, CLAMS data (and a link) and more. Ater many years living in various folders and subfolders, being copied and *slightly* modified (and then trying to find which modified copy I wanted), they finally have a home on the internet!

## Installation

You can install the released version of handytools using devtools:

``` r
library(devtools)
install_github("mattsnelson/handytools")
```

## Example

This is a basic example which shows you how to solve a common problem: (to fill in later -? one for each script)

``` r
library(handytools)
## basic example code
```

## ELISA analysis

### elisr
See templates/ELISR templates.Rmd for template workflows (#TODO)

Takes a template and results (in 96 well format) and 
 - melts together based on sampleID in template (agnostic to well position)
 - averages ODs
 - calcuates SD and CD%
 - calculates (mean OD - blank)

Example workflow:
```  
plate1_output <- handytools::elisr(my_template, raw_results, "BLK"")

colnames(plate1_output)[1] <- "ID"

plate1_stds <- merge(stds, plate1_output, by= "ID", all.x=T, all.y=F) 

# Interpolation with drc package
plate1_model<-drm(mean_OD_minus_blank~conc,
            fct=LL.4(names=c("Slope", "Lower", "Upper", "ED50")),
            data=plate1_stds)
```

## RNA extraction and cDNA synthesis

### Qiaxpert data wrangle
TODO -  

Script to easily data-wrangle output from qiaxpert plates (measuring concentration of RNA in extraxcted sample) into format that can be passed onto next step in workflow: `rna2cdna`  

### rna2cdna

takes qiaxpert input and checks for quality and batch effects.

calculates water and RNA to add into cDNA synthesis reaction

TODO: update this with an example/figure

Once run this, you'll want to go to the lab to start synthesising cDNA! Hold up, let's make an easy to print version of this using `cdna_plane_printable`  

### cdna_plan_printable

takes the output of the above cDNA synthesis paln and just makes it more readable (and printable so can have a hardcopy for going into the lab)

Yay, now you've synthesised some cDNA! But you can't wait to start doing some RT-PCR! See on below for the next steps on the journey

## RT-PCR

Using Quantstudio (3 or 5) with either Taqman probes (allowing to multiplex with reference gene) or Sybr reagents (where will need seperate well for 18S)

### melt384

Super simple handy script that takes a data frame in 384 well plate layout (e.g. the plate template you drew up in excel to show which samples go where) and converts it to a long list with the well position.

So you're 24 x 16 plate becomes this:

|  well_position | sample_id |
|----|---|
| A1  | 220 | 
| A2  | 247 |
| A3  | 248 |
| A4  | 251 |
etc

Doesn't seem like much, but it's super handy to have the plate template in this format for merging etc downstream with the Quantstudio output.

### ddct-taq

TODO

This uses Taqman chemistry, where each well has both a gene of interest (using a FAM probe) and a reference gene (with a VIC probe)

This is setup to work nicely if you have multiple of the same sample IDs. (e.g. if you have 96 samples so run 4 genes, and therefore in the plate template the same sample ID will be used 4 times). Note the sample ID has to be exactly the same acrtoss the plate template for this to work nicely, mmmkay.

