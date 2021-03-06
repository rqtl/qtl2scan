context("effect scan by scan1coef with polygenic effect")

# calc estimates via lm(), just one chromosome
eff_via_lm <-
    function(probs, pheno, kinship, addcovar=NULL, intcovar=NULL,
             se=TRUE)
{
    kinship <- double_kinship(kinship) # need 2*kinship for LMM
    kinship <- decomp_kinship(kinship)
    eigenvec <- kinship$vectors
    hsq <- calc_hsq_clean(kinship, as.matrix(pheno), addcovar, NULL, FALSE,
                          reml=TRUE, cores=1, check_boundary=TRUE, tol=1e-12)$hsq[1,1]

    wts <- 1/(hsq*kinship$values + (1-hsq))

    npos <- dim(probs)[3]
    nind <- length(pheno)
    ngen <- dim(probs)[2]

    nadd <- ifelse(is.null(addcovar), 0, ncol(addcovar))
    nint <- ifelse(is.null(intcovar), 0, ncol(intcovar))
    ncoef <- ngen + nadd + (ngen-1)*nint

    result <- matrix(nrow=npos, ncol=ncoef)
    SEs <- matrix(nrow=npos, ncol=ncoef)

    if(!is.null(intcovar)) intcovar <- as.matrix(intcovar)

    pheno <- eigenvec %*% pheno

    for(i in 1:npos) {
        X <- probs[,,i]
        if(!is.null(addcovar)) X <- cbind(X, addcovar)
        if(!is.null(intcovar)) {
            for(j in 1:ncol(intcovar))
                X <- cbind(X, probs[,-1,i]*intcovar[,j])
        }
        X <- eigenvec %*% X

        lm.out <- lm(pheno ~ -1 + X, weights=wts)
        result[i,] <- lm.out$coef
        if(se) # need to deal with NAs
            SEs[i,!is.na(lm.out$coef)] <- summary(lm.out)$coef[,2]
        else SEs <- NULL
    }

    attr(result, "SE") <- SEs

    class(result) <- c("scan1coef", "scan1", "matrix")
    result
}

test_that("scan1coef_pg for grav", {

    set.seed(9308594)

    library(qtl2geno)
    grav <- read_cross2(system.file("extdata", "grav2.zip", package="qtl2geno"))
    map <- insert_pseudomarkers(grav$gmap, step=1)
    pr <- calc_genoprob(grav, map)
    K <- calc_kinship(pr)
    phe <- grav$pheno[,"T330",drop=FALSE]

    est <- scan1coef(pr[,1], phe, K, se=FALSE)
    est_lm <- eff_via_lm(pr[[1]], phe, K)
    expect_equivalent(est, est_lm)

    est <- scan1coef(pr[,1], phe, K, se=TRUE)
    expect_equivalent(est, est_lm)
    expect_equivalent(attr(est, "SE"), attr(est_lm, "SE"))

    # pre-decomp kinship
    Ke <- decomp_kinship(K)
    est <- scan1coef(pr[,1], phe, Ke)
    expect_equivalent(est, est_lm)

    est <- scan1coef(pr[,1], phe, Ke, se=TRUE)
    expect_equivalent(est, est_lm)
    expect_equivalent(attr(est, "SE"), attr(est_lm, "SE"))

    # kinship is a list of length 1
    Klist <- list("1"=K)
    est <- scan1coef(pr[,1], phe, Klist)
    expect_equivalent(est, est_lm)

    est <- scan1coef(pr[,1], phe, Klist, se=TRUE)
    expect_equivalent(est, est_lm)
    expect_equivalent(attr(est, "SE"), attr(est_lm, "SE"))

    # include covariate
    covar <- cbind(chr3=pr[[3]][,2,"CC.266L"])
    est <- scan1coef(pr[,1], phe, K, covar, se=FALSE)
    est_lm <- eff_via_lm(pr[[1]], phe, K, covar)
    expect_equivalent(est, est_lm)

    est <- scan1coef(pr[,1], phe, K, covar, se=TRUE)
    expect_equivalent(est, est_lm)
    expect_equivalent(attr(est, "SE"), attr(est_lm, "SE"))

    # pre-computed eigen decomp
    est <- scan1coef(pr[,1], phe, Ke, covar)
    expect_equivalent(est, est_lm)
    est <- scan1coef(pr[,1], phe, Ke, covar, se=TRUE)
    expect_equivalent(est, est_lm)
    expect_equivalent(attr(est, "SE"), attr(est_lm, "SE"))

    # interactive covariate
    est <- scan1coef(pr[,1], phe, K, covar, intcovar=covar, se=FALSE)
    est_lm <- eff_via_lm(pr[[1]], phe, K, covar, covar)
    expect_equivalent(est, est_lm)

    est <- scan1coef(pr[,1], phe, K, covar, intcovar=covar, se=TRUE)
    expect_equivalent(est, est_lm)
    expect_equivalent(attr(est, "SE"), attr(est_lm, "SE"))

    # pre-computed eigen decomp
    est <- scan1coef(pr[,1], phe, Ke, covar, intcovar=covar)
    expect_equivalent(est, est_lm)
    est <- scan1coef(pr[,1], phe, Ke, covar, intcovar=covar, se=TRUE)
    expect_equivalent(est, est_lm)
    expect_equivalent(attr(est, "SE"), attr(est_lm, "SE"))

    # two covariates
    covar <- cbind(covar, chr4=pr[[4]][,2,"CD.329C-Col"])
    est <- scan1coef(pr[,1], phe, K, covar, se=FALSE)
    est_lm <- eff_via_lm(pr[[1]], phe, K, covar)
    expect_equivalent(est, est_lm)

    est <- scan1coef(pr[,1], phe, K, covar, se=TRUE)
    expect_equivalent(est, est_lm)
    expect_equivalent(attr(est, "SE"), attr(est_lm, "SE"))

    # pre-computed eigen decomp
    est <- scan1coef(pr[,1], phe, Ke, covar)
    expect_equivalent(est, est_lm)
    est <- scan1coef(pr[,1], phe, Ke, covar, se=TRUE)
    expect_equivalent(est, est_lm)
    expect_equivalent(attr(est, "SE"), attr(est_lm, "SE"))

    # two interactive covariates
    est <- scan1coef(pr[,1], phe, K, covar, intcovar=covar, se=FALSE)
    est_lm <- eff_via_lm(pr[[1]], phe, K, covar, covar)
    expect_equivalent(est, est_lm)

    est <- scan1coef(pr[,1], phe, K, covar, intcovar=covar, se=TRUE)
    expect_equivalent(est, est_lm)
    expect_equivalent(attr(est, "SE"), attr(est_lm, "SE"))

    # pre-computed eigen decomp
    est <- scan1coef(pr[,1], phe, Ke, covar, intcovar=covar)
    expect_equivalent(est, est_lm)
    est <- scan1coef(pr[,1], phe, Ke, covar, intcovar=covar, se=TRUE)
    expect_equivalent(est, est_lm)
    expect_equivalent(attr(est, "SE"), attr(est_lm, "SE"))

})


test_that("scan1coef deals with mismatching individuals", {
    library(qtl2geno)
    iron <- read_cross2(system.file("extdata", "iron.zip", package="qtl2geno"))
    map <- insert_pseudomarkers(iron$gmap, step=2.5)
    probs <- calc_genoprob(iron, map, error_prob=0.002)
    kinship <- calc_kinship(probs, "loco")[["3"]]
    probs <- probs[,"3"]
    Xc <- get_x_covar(iron)
    X <- match(iron$covar$sex, c("f", "m"))-1
    names(X) <- rownames(iron$covar)

    phe <- iron$pheno[,2,drop=FALSE]

    ind <- c(1:50, 101:150)
    expected <- scan1coef(probs[ind,], phe[ind,,drop=FALSE], kinship[ind,ind], addcovar=X[ind])
    expect_equal(scan1coef(probs[ind,], phe, kinship, addcovar=X), expected)
    expect_equal(scan1coef(probs, phe[ind,,drop=FALSE], kinship, addcovar=X), expected)
    expect_equal(scan1coef(probs, phe, kinship[ind,ind], addcovar=X), expected)
    expect_equal(scan1coef(probs, phe, kinship, addcovar=X[ind]), expected)

})
