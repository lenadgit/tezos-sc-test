type amt is nat;
type storage is unit

const noOperation : list(operation) = nil;
type return is list(operation) * storage

type transferParams is michelson_pair(adress, "KT1UjFQxXPbjptnDbMd5MkDZrdTN7DsDU9Lk", michelson_pair(adress, "to", amt, "value"), "")

type actions is unit

| Transfer of transferParams

function transfer(const from : adress; const to : adress; const value : amt; var s : storage) : return is block {
    var senderAccount : account = nil;
} with(noOperations, s)

function main(const p : actions; const p : storage) : return is
case p of 
    | Transfer(params) -> transfer(params.0, params.1.0, params.1.1, s) 
end