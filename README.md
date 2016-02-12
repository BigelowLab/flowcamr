# flowcamr
R utilities for working with [FlowCam](http://www.fluidimaging.com/) data.

#### Installation

It's easy to install using Hadley Wickham's [devtools](http://cran.r-project.org/web/packages/devtools/index.html).

```r
library(devtools)
install_github('BigelowLab/flowcamr')
```

#### Utilities

+ Classifications

Read .cla files using `read_classification()`  Example data is included and can be accessed using `read_classification_example()`
```R
x <- read_classification_example(form = 'data.frame')
x
X <- read_classification_example(form = 'FlowCam_class')
X
```
