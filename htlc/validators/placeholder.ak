use aiken/builtin.{blake2b_256}
use aiken/collection/list
use cardano/transaction.{OutputReference, Transaction}
use cocktail/vodka_validity_range.{valid_before, valid_after}

pub type Datum {
  hash: ByteArray,
  timeout: Int,
  sender: ByteArray,
  receiver: ByteArray,
}

pub type Redeemer {
  Claim(ByteArray)
  Refund
}

fn signed_by(tx: Transaction, pkh: ByteArray) -> Bool {
  list.has(tx.extra_signatories, pkh)
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
          && signed_by(tx, datum.receiver)
      }
      Refund -> {
         valid_after(tx.validity_range, datum.timeout)
          && signed_by(tx, datum.sender)
      }
    }
  }
}
