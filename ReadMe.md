This package is now **deprecated**. qtl2geno, qtl2scan, qtl2plot, and
qtl2db have been merged into a single package, [qtl2](https://github.com/rqtl/qtl2).

Install the new package and remove the old ones:

```
install.packages("qtl2", repos="https://rqtl.org/qtl2cran")
remove.packages(paste0("qtl2", c("geno", "scan", "plot", "db")))
```
