// RI sib-mating HMM functions

#include <math.h>
#include <string>
#include <Rcpp.h>
#include "cross.h"

enum gen {NA=0, AA=1, BB=2};

bool RIsib::check_geno(int gen, bool is_observed_value,
                       bool is_X_chr, bool ignored, vector<int> cross_info)
{
    if(is_observed_value && gen==NA) return true;

    if(gen != AA && gen != BB)
        throw std::range_error("genotype not allowed.");

    return true;
}


double RIsib::init(int true_gen,
                   bool is_X_chr, bool ignored, vector<int> cross_info)
{
    check_geno(true_gen, false, is_X_chr, ignored, cross_info);

    const bool forward_direction = (cross_info[0] == 0); // AA female x BB male

    if(is_X_chr) {
        if(forward_direction) {
            if(true_gen == AA) return log(2.0)-log(3.0);
            if(true_gen == BB) return -log(3.0);
        }
        else {
            if(true_gen == BB) return log(2.0)-log(3.0);
            if(true_gen == AA) return -log(3.0);
        }
    }
    else { // autosome
        return -log(2.0);
    }

    return NA_REAL; // can't get here
}

double RIsib::emit(int obs_gen, int true_gen, double error_prob,
                   bool is_X_chr, bool ignored, vector<int> cross_info)
{
    check_geno(obs_gen, true, is_X_chr, ignored, cross_info);
    check_geno(true_gen, false, is_X_chr, ignored, cross_info);

    if(obs_gen==NA) return 0.0; // missing

    if(obs_gen == true_gen) return log(1.0 - error_prob);
    else return log(error_prob);
}

double RIsib::step(int gen_left, int gen_right, double rec_frac,
                   bool is_X_chr, bool ignored, vector<int> cross_info)
{
    check_geno(gen_left, false, is_X_chr, ignored, cross_info);
    check_geno(gen_right, false, is_X_chr, ignored, cross_info);

    if(is_X_chr)  {
        const bool forward_direction = (cross_info[0] == 0); // AA female x BB male

        if(forward_direction) {
            if(gen_left == AA) {
                if(gen_right == AA)
                    return log(1.0 + 2.0*rec_frac) - log(1.0 + 4.0*rec_frac);
                if(gen_right == BB)
                    return log(2.0*rec_frac) - log(1.0 + 4.0*rec_frac);
            }

            if(gen_left == BB) {
                if(gen_right == BB)
                    return -log(1.0 + 4.0*rec_frac);
                if(gen_right == AA)
                    return log(4.0*rec_frac) - log(1.0 + 4.0*rec_frac);
            }
        }
        else {
            if(gen_left == AA) {
                if(gen_right == AA)
                    return -log(1.0 + 4.0*rec_frac);
                if(gen_right == BB)
                    return log(4.0*rec_frac) - log(1.0 + 4.0*rec_frac);
            }

            if(gen_left == BB) {
                if(gen_right == BB)
                    return log(1.0 + 2.0*rec_frac) - log(1.0 + 4.0*rec_frac);
                if(gen_right == AA)
                    return log(2.0*rec_frac) - log(1.0 + 4.0*rec_frac);
            }
        }
    }
    else { // autosome
        const double R = 4.0*rec_frac/(1+6.0*rec_frac);

        if(gen_left == gen_right) return log(1.0-R);
        else return log(R);
    }

    return NA_REAL; // can't get here
}

vector<int> RIsib::allgeno(bool is_X_chr)
{
    int vals[] = {AA,BB};
    vector<int> result(vals, vals+2);
    return result;
}

double RIsib::nrec(int gen_left, int gen_right,
                   bool is_X_chr, bool ignored, vector<int> cross_info)
{
    check_geno(gen_left, false, is_X_chr, ignored, cross_info);
    check_geno(gen_right, false, is_X_chr, ignored, cross_info);

    if(gen_left == gen_right) return 0.0;
    else return 1.0;
}