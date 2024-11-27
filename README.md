# dirfns
A collection of functions to more cleanly organize output files by specifying directories separately and automatically organizing output by date.

## Installation

```bash
git clone https://github.com/kewiechecki/dirfns
cd dirfns
make
```

## Usage

```R
library(dirfns)

dir.csv(iris, "example", path = "path/to")

# Open a device
dir.pdf("example", path = "path/to")
plot(iris$Sepal.Length,iris$Petal.Length)
dev.off()

# Write a list of files with filenames taken from names(x).
x <- split(iris,iris$Species)
dir.apply(x, dir.csv, path="path/to")

# Selectively read files matching a given pattern.
dir.csv(iris, "example", path="path/to", append.date = F)
dir.tab(iris, "example", path="path/to", append.date = F)
lrtab("path/to", read.csv, "\\.csv")
```