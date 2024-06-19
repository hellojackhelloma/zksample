pragma circom 2.0.0;

include "node_modules/circomlib/circuits/eddsamimc.circom";
include "node_modules/circomlib/circuits/mimc.circom";

template VerifySignature(n) {
    signal input messages[n];
    signal input pubKeys[n][2];
    signal input signatures[n][2];
    signal output allValid;

    component verifiers[n];

    for (var i = 0; i < n; i++) {
        verifiers[i] = EdDSAMiMCVerifier();
        verifiers[i].message <== messages[i];
        verifiers[i].A <== pubKeys[i];
        verifiers[i].R8 <== signatures[i][0];
        verifiers[i].S <== signatures[i][1];
    }

    allValid <== 1;
    for (var i = 0; i < n; i++) {
        allValid <== allValid * verifiers[i].out;
    }
}

component main = VerifySignature(3);