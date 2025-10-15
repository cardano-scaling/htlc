use aiken/builtin.{blake2b_256}
use aiken/crypto.{VerificationKeyHash}
use cardano/transaction.{OutputReference, Transaction}
use cocktail/vodka_extra_signatories.{key_signed}
use cocktail/vodka_validity_range.{valid_before, valid_after}

pub type Datum {
  hash: ByteArray,
  timeout: Int,
  sender: VerificationKeyHash,
  receiver: VerificationKeyHash
}

pub type Redeemer {
  Claim(ByteArray)
  Refund
}

validator htlc {
  spend(
    datum_opt: Option<Datum>,
    redeemer: Redeemer,
    _input: OutputReference,
    tx: Transaction,
  ) {
    expect Some(datum) = datum_opt

    when redeemer is {
      Claim(preimage) -> {
        blake2b_256(preimage) == datum.hash
          && valid_before(tx.validity_range, datum.timeout)
          && key_signed(tx.extra_signatories, datum.receiver)
      }
      Refund -> {
         valid_after(tx.validity_range, datum.timeout)
          && key_signed(tx.extra_signatories, datum.sender)
      }
    }
  }
}
