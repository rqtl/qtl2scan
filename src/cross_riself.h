#ifndef CROSS_RISELF_H
#define CROSS_RISELF_H

#include <vector>
#include <math.h>
#include "cross.h"

class RIself : public Cross
{
 public:
    RIself(){
        type = "riself";
    };
    ~RIself(){};

    bool check_geno(int gen, bool is_observed_value,
                    bool ignored1, bool ignored2, vector<int> ignored3);

    double init(int true_gen, bool is_X_chr, bool is_female,
                vector<int> cross_info);
    double emit(int obs_gen, int true_gen, double error_prob,
                bool is_X_chr, bool is_female, vector<int> cross_info);
    double step(int gen_left, int gen_right, double rec_frac,
                bool is_X_chr, bool is_female, vector<int> cross_info);

    vector<int> allgeno(bool ignored1);

    double nrec(int gen_left, int gen_right,
                bool ignored1, bool ignored2, vector<int> ignored3);
};

#endif // CROSS_RISELF_H