# handytools

<!-- badges: start -->
<!-- badges: end -->

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

## RT-PCR Workflow

#

### rna2cdna

takes qiaxpert input and checks for quality and batch effects.

calculates water and RNA to add into cDNA synthesis reaction

TODO: update this with an example/figure

### cdna_plan_printable

takes the output of the above cDNA synthesis paln and just makes it more readable (and printable so can have a hardcopy for going into the lab)

### melt384



### ddct-taq

This uses Taqman chemistry, where each well has 

> block quote tet
> what dis look like eh
