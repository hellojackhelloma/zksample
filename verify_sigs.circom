pragma circom 2.0.0;

include "node_modules/circomlib/circuits/eddsamimc.circom";
include "node_modules/circomlib/circuits/mimc.circom";

template VerifySignature(n) {
    signal input messages[n];
    signal input pubKeys[n][2];
    signal input signatures[n][2];
     signal input sender_sig_s[n];
    signal output allValid;

    component verifiers[n];

    for (var i = 0; i < n; i++) {
        verifiers[i] = EdDSAMiMCVerifier();
        verifiers[i].enabled <== 1;
        verifiers[i].M <== messages[i];
        verifiers[i].Ax <== pubKeys[i][0];
         verifiers[i].Ay <== pubKeys[i][1];
        verifiers[i].R8x <== signatures[i][0];
          verifiers[i].R8y <== signatures[i][1];
        verifiers[i].S <== sender_sig_s[i];

    }

    allValid <== 1;
    for (var i = 0; i < n; i++) {
        allValid <== allValid * verifiers[i].out;
    }
}

component main = VerifySignature(3);