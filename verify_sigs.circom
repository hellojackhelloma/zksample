pragma circom 2.0.0;

include "node_modules/circomlib/circuits/eddsamimc.circom";
include "node_modules/circomlib/circuits/mimc.circom";

template SingleRelayVerifier() {
  signal input sender_pubkey[2];
  signal input receiver_pubkey[2];
  signal input relay_pubkey[2];
  signal input msg_size;
  signal input sender_sig_r[2];
  signal input sender_sig_s;

  component msgHasher = MultiMiMC7(7, 91);
  msgHasher.k <== 1;
  msgHasher.in[0] <== relay_pubkey[0];
  msgHasher.in[1] <== relay_pubkey[1];
  msgHasher.in[2] <== sender_pubkey[0];
  msgHasher.in[3] <== sender_pubkey[1];
  msgHasher.in[4] <== receiver_pubkey[0];
  msgHasher.in[5] <== receiver_pubkey[1];
  msgHasher.in[6] <== msg_size;

  component sigVerifier = EdDSAMiMCVerifier();
  sigVerifier.enabled <== 1;
  sigVerifier.Ax <== sender_pubkey[0];
  sigVerifier.Ay <== sender_pubkey[1];
  sigVerifier.R8x <== sender_sig_r[0];
  sigVerifier.R8y <== sender_sig_r[1];
  sigVerifier.S <== "355478921177370314588967779060252184056136316684566666998231454170941834911";
  sigVerifier.M <== msgHasher.out;
}

template RelayVerifier(n) {
  signal input sender_pubkey[n][2];
  signal input receiver_pubkey[n][2];
  signal input relay_pubkey[2];
  signal input msg_size[n];
  signal input total_size;
  signal input sender_sig_r[n][2];
  signal input sender_sig_s[n];

  var i;
  var size = 0;
  component singleVerifier[n];
  for (i=0; i<n; i++) {
    singleVerifier[i] = SingleRelayVerifier();
    singleVerifier[i].sender_pubkey <== sender_pubkey[i];
    singleVerifier[i].receiver_pubkey <== receiver_pubkey[i];
    singleVerifier[i].relay_pubkey <== relay_pubkey;
    singleVerifier[i].msg_size <== msg_size[i];
    singleVerifier[i].sender_sig_r <== sender_sig_r[i];
    singleVerifier[i].sender_sig_s <== sender_sig_s[i];
    size = size + msg_size[i];
  }

  size === total_size;
}

component main{public [relay_pubkey, total_size]} = RelayVerifier(10);
