# flowcamr
R utilities for working with [FlowCam](http://www.fluidimaging.com/) data.

#### Installation

It's easy to install using Hadley Wickham's [devtools](http://cran.r-project.org/web/packages/devtools/index.html).

```r
library(devtools)
install_github('BigelowLab/flowcamr')
```

#### Utilities

+ Context

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

+ Classifications


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
