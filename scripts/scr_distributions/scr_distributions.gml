// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function gauss(base, sd){
    var x1, x2, w;
    do {
        x1 = random(-1, 1);
        x2 = random(-1, 1);
        w = sqr(x1)+sqr(x2);
    } until (0 < w and w < 1);

    w = sqrt(-2 * ln(w) / w);
    return base + sd * x1 * w;
}

function gauss_positive(base, sd){
    var x1, x2, w;
    do {
        x1 = random_range(0, 1);
        x2 = random_range(0, 1);
        w = sqr(x1)+sqr(x2);
    } until (0 < w and w < 1);

    w = sqrt(-2 * ln(w) / w);
    return base + (sd * x1 * w);
}

function pareto(base, exponent=1){
    return base * (1 - power(random(1), 1 / (1 + exponent)));
}

function lanczos_gamma(x1) {
    var g = 7;
    var p = [
        0.99999999999980993, 676.5203681218851, -1259.1392167224028,
        771.32342877765313, -176.61502916214059, 12.507343278686905,
        -0.13857109526572012, 9.9843695780195716e-6, 1.5056327351493116e-7
    ];
    
    if (x1 < 0.5) {
        return pi / (sin(pi * x1) * lanczos_gamma(1 - x1));
    } else {
        x1 -= 1;
        var a = p[0];
        var t = x1 + g + 0.5;
        for (var i = 1; i < array_length(p); i++) {
            a += p[i] / (x1 + i);
        }
        return sqrt(2 * pi) * pow(t, x1 + 0.5) * exp(-t) * a;
    }
}

function beta_function(alpha, beta) {
    return lanczos_gamma(alpha) * lanczos_gamma(beta) / lanczos_gamma(alpha + beta);
}

function beta_distribution(alpha, beta) {
    x1 = random_range(0, 1);
    return pow(x1, alpha - 1) * pow(1 - x1, beta - 1) / beta_function(alpha, beta);
}

// function exponent(lambda, base) {
//     var u = random(1);  // Generate a uniform random number between 0 and 1
//     var raw = -log(1 - u) / lambda;  // Generate an exponentially distributed number
//     return base * raw;  // Scale the number by the base value
// }