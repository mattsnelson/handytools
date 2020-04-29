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

So your 24 x 16 plate becomes this:

|  well_position | sample_id |
|----|---|
| A1  | 220 | 
| A2  | 247 |
| A3  | 248 |
| A4  | 251 |
etc

Doesn't seem like much, but it's super handy to have the plate template in this format for merging etc downstream with the Quantstudio output.

### ddct

This calculates ddct for you.

Minimum input required: 
 - A table that has "group" (it must be called exactly group or else will fail...I haven't figured a way around this yet)
 - ct values for your gene of interest (can name anything)
- ct values for refernce gene  (can name anything)  

|  group | gene_ct | ref_gene_ct
|----|---|---|
| Control  | 22.3 | 7.8 |
| Control  | 23.5 | 8.2 |
| Treatment  | 18.7 | 7.6 |
| Treatment  | 21.7 | 6.5 |
etc...

Need to specify the names of your reference group, the target gene and reference gene (as they are named in the table). Also specify a cutoff for the refgene, values above this will be excluded (good sanity control in case low volume pipetted in).  

`foldchange <- handytools::ddct(ct_data_table = pcr_results.mcp1, 
                     refgroup = "Control",
                     targetgene = "MCP-1",
                     refgene = "18S",
                     refgene.cutoff = 10)`


### ddct_taq_multi

maybe one day...or maybe not??

### ddct_sybr

TODO
maybe one day...or maybe not??
