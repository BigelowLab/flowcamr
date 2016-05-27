# flowcamr
R utilities for working with [FlowCam](http://www.fluidimaging.com/) data.

#### Requirements

 + [R](https://www.r-project.org/) v 3+ 
 + R package [configurator](https://github.com/BigelowLab/configurator)
 + [FlowCam](http://www.fluidimaging.com/) dataset version 2+
 
#### Installation

It's easy to install using Hadley Wickham's [devtools](http://cran.r-project.org/web/packages/devtools/index.html).

```r
# if you don't have devtools already then do this first
# install.packages("devtools")

library(devtools)
install_github('BigelowLab/configurator')
install_github('BigelowLab/flowcamr')
```

#### MS Windows users note

Please note that [path separators](https://cran.r-project.org/bin/windows/base/old/2.1.0/rw-FAQ.html#R-can_0027t-find-my-file) in Windows require some attention.  

These work as `\\` and `/` are equivalent ...

```
"D:\\SABOR FCAM Classified\\LCL CLASSIFIED_2016-01-20.SABOR.txt"
"D:/SABOR FCAM Classified/LCL CLASSIFIED_2016-01-20.SABOR.txt"
```

This doesn't work ...

```
"D:\SABOR FCAM Classified\LCL CLASSIFIED_2016-01-20.SABOR.txt"
```


#### Utilities - to make the user's life easier

###### FlowCam

The FlowCamRefClass is a simple container for data, post-processed data, context and classification data.  It has the following fields...

    path - the fully qualified path description
    name - the basename of path
    filelist - a complete listing of relative paths within path
    ctx - context information in a ConfiguratorRefClass object
    cla - classification data stored in FlowCam_class S3 object
    data - a data.frame with the original data (from path/name.csv) and possibly post-processed data prefixed with 'PP_'


Here is an example to create and print a FlowCamRefClass instance.

```R
library(flowcamr)
X <- FlowCam("~/Dropbox/OSM 2016 Biovolume/LS2_1M/203-210524")
X
# Path: ~/Dropbox/OSM 2016 Biovolume/LS2_1M/203-210524 
# Version:  3.4.5 
# Trigger Mode:  Fluorescent 
# Cal Const:  1.0000 
# ESD range: 4.0000 - 10000.0000 
# n_particles: 354 
#      UserLabel Count       Volume
# 1A01      1A01     4    34059.576
# 1A02      1A02     2    99288.748
# 1A04      1A04    14  1110339.376
# 1A05      1A05    12   187656.743
# 1A06      1A06     4     4993.561
# 1B05      1B05     9   164795.228
# 2A          2A    33   406815.043
# 2C01      2C01     7   780305.413
# 2C02      2C02    18  1423174.460
# 2C03      2C03     3   326789.254
# 2D          2D     2    36118.105
# 3A          3A     1    25146.093
# 3B          3B    19   401392.654
# 3C          3C    21   392861.659
# 6A          6A    15 10089538.792
# 8A          8A    37   445256.185
# 8B          8B   126   114050.018
# 9A          9A    17   205528.506
# 9B          9B     2 19893320.236
# 9D          9D     8   292443.006
```

Users can get help on FlowCam using ```?FlowCam```

###### FlowCamGroup

Read one or more FlowCamRefClass objects into one list-like object.

```R

# if you have a character vector of directories
XX <- FlowCamGroup(some_list_of_paths)

# or if you have prepped a file, say 'SABOR.txt',  that list these directories...
# 
# D:\SABOR FCAM Classified\LCL CLASSIFIED_2016-01-20\1634FTconc\216-002758
# D:\SABOR FCAM Classified\LCL CLASSIFIED_2016-01-20\1716FTconc\210-175915

XX <- FlowCamGroup(filename = "D:/SABOR FCAM Classified/LCL CLASSIFIED_2016-01-20.SABOR.txt")
XX
```

Your can requested the particle IDs for all particles of a certain class.

```
# get tally of items labeled '1A'
ix <- which_labeled(XX, label = '1A')
ix
```

And you can request a aggregate volume by class summary.  By default the summary is saved as a CSV file as 'volume_summary.csv'.  Just where this is saved depends... (a) if you provide a list it will be saved in the parent directory of the first flowcam directory in the list, or (b) if you provide a file that lists the flowcam directories then it is saved in it's parent directory (beside the input file), or, finally, (c) you can explicitly provide the path and filename to save.

```
# get a volume-by-class summary table, save by default
vs <- volume_summary(XX)

# get a volume-by-class summary table, save to specified file
vs <- volume_summary(XX, filename = 'C:/my/path/volume_summary.csv')

```

Users can get help on FlowCamGroup using ```?FlowCamGroup```

#### Developer Tools - to make the developer's life easier

###### Context

Read the context configuration file into a ConfigurationRefClass object using `read_context()`. An example is included.

```R
filename <- system.file("extdata", "201-045311.ctx", package = "flowcamr")
Cfg <- read_context(filename)

# print it
Cfg
# [Software]
# SoftwareName=VisualSpreadsheet
# SoftwareVersion=3.4.5
# SoftwareBetaFlag=0
# ...

# get the FringeSize
fringe_size <- as.numeric(Cfg$get("Fluid", "FringeSize", default = "3.14"))
```

###### Classifications

Read .cla files using `read_classifications()` Example data is included.  Try reading into a data.frame as well as FlowCam_class S3 object.
```R
filename <- system.file("extdata", "201-045311.cla", package = "flowcamr")
x <- read_classifications(filename, form = 'data.frame')
head(x)
> head(x)
#   class_name particle_id classification
# 1          1           1           test
# 2          1          12           test
# 3          1          14           test
# 4          1          16           test
# 5          1          22           test
# 6          1          44           test

X <- read_classifications(filename, form = 'FlowCam_class')
str(X)
```
