#ifndef CROSS_F2_H
#define CROSS_F2_H

#include <vector>
#include <math.h>
#include "cross.h"

using namespace std;

class F2 : public Cross
{
 public:
    F2(){
        type = "f2";
    };
    ~F2(){};

    bool check_geno(int gen, bool is_observed_value,
                bool is_X_chr, bool is_female, vector<int> cross_info);

    double init(int true_gen,
                bool is_X_chr, bool is_female, vector<int> cross_info);
    double emit(int obs_gen, int true_gen, double error_prob,
                bool is_X_chr, bool is_female, vector<int> cross_info);
    double step(int gen_left, int gen_right, double rec_frac,
                bool is_X_chr, bool is_female, vector<int> cross_info);

    vector<int> geno(bool is_X_chr, bool is_female, vector <int>cross_info);
    vector<int> allgeno(bool is_X_chr);

    double nrec(int gen_left, int gen_right,
                bool is_X_chr, bool is_female, vector<int> cross_info);

    bool check_genoPK(int gen, bool is_observed_value,
                      bool is_X_chr, bool is_female, vector<int> cross_info);

    double initPK(int true_gen,
                  bool is_X_chr, bool is_female, vector<int> cross_info);
    double emitPK(int obs_gen, int true_gen, double error_prob,
                  bool is_X_chr, bool is_female, vector<int> cross_info);
    double stepPK(int gen_left, int gen_right, double rec_frac,
                  bool is_X_chr, bool is_female, vector<int> cross_info);

    vector<int> genoPK(bool is_X_chr, bool is_female, vector <int>cross_info);
    vector<int> allgenoPK(bool is_X_chr);

};

#endif // CROSS_F2_H