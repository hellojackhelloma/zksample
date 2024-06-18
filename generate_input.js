const fs = require("fs");
const { buildBabyjub, buildMimc7, buildEddsa } = require("circomlibjs");

async function main() {
    const babyJub = await buildBabyjub();
    const mimc7 = await buildMimc7();
    const eddsa = await buildEddsa();
    const F = babyJub.F;

    // setup accounts
    const senderPrvKey = Buffer.from("1".toString().padStart(64, "0"), "hex");
    const receiverPrvKey = Buffer.from("2".toString().padStart(64, "0"), "hex");
    const relayPrvKey = Buffer.from("3".toString().padStart(64, "0"), "hex");
    const senderPubKey = eddsa.prv2pub(senderPrvKey);
    const receiverPubKey = eddsa.prv2pub(receiverPrvKey);
    const relayPubKey = eddsa.prv2pub(relayPrvKey);
    const msgSize = 334455

    const msgHash = mimc7.multiHash(
        [relayPubKey[0], relayPubKey[1], senderPubKey[0], senderPubKey[1], receiverPubKey[0], receiverPubKey[1], msgSize],
        1
    );

    const signature = eddsa.signMiMC(senderPrvKey, msgHash);
    const n = 10;
    const inputs = {
        sender_pubkey: [],
        receiver_pubkey: [],
        relay_pubkey: [
            BigInt(F.toObject(relayPubKey[0])).toString(),
            BigInt(F.toObject(relayPubKey[1])).toString()
        ],
        msg_size: [],
        total_size: (msgSize * n).toString(),
        sender_sig_r: [],
        sender_sig_s: [],
    };
    for (var i=0; i<n; i++) {
        inputs.sender_pubkey.push([
            BigInt(F.toObject(senderPubKey[0])).toString(),
            BigInt(F.toObject(senderPubKey[1])).toString()
        ]);
        inputs.receiver_pubkey.push([
            BigInt(F.toObject(receiverPubKey[0])).toString(),
            BigInt(F.toObject(receiverPubKey[1])).toString()
        ]);
        inputs.msg_size.push(msgSize.toString());
        inputs.sender_sig_r.push([
            BigInt(F.toObject(signature.R8[0])).toString(),
            BigInt(F.toObject(signature.R8[1])).toString(),
        ]);
        inputs.sender_sig_s.push(BigInt(signature.S).toString());
    }


    fs.writeFileSync("input.json", JSON.stringify(inputs), 'utf-8');
}

main()
