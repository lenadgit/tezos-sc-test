#include "../partials/Lambda.ligo"

type storage is 
record[ 
    counter : nat;
    threshold : nat;
    pubKeys : list(key);
]

type return is list(operation) * storage

type changeParams is michelson_pair(nat, "threshold", list(key), "keys")
type actionParam is
 Action of func
 KeyChange of changeParams

type inputParam is michelson_pair(mainParam, "action", list(option(signature)), "sigs")
type mainParam is michelson_pair(nat, "counter", actionParam, "action")

type actions is 
 Default of unit
 MainAction of inputParam

 function checkSignatures(const sigs: list(option(signature)); const pubKeys : list(key); const input: mainParam ) : nat is block {
    var sigCounter := 0n;
    var signatures := b.1;

//Loop checks all signatures
    for key in list stor.pubKeys block {
        case List.head_opt(signatures) of 
        None -> skip;
        | Some(s) -> block {
            case s of 
            None -> skip
            | Some(h) -> block {
                if Crypto.check(key, h, Bytes.pack(b.0)) = True then sigCounter := sigCounter +1n else skip;
                
            } end;
        } end;
//Remove head element
    case List.tail_opt(signatures) of
    None -> signatures :=(nil : list(option(signature)))
    | Some(tail) -> signatures := tail
    end;        
    } with sigCounter

function processAction(var stor: storage; const b : inputParam) : return is 
block {
    if b.0.0 =/= stor.counter then failwith "Counter does not match") else skip;

    if checkSignatures(b.1, stor.pubKeys, b.0) < stor.threshold then failwith ("Quorum does not presented") else skip;

    stor.counter := stor.counter + 1n;
    var resp := (nil : list(operation));
//Process action
    case b.0.1 of
    | Action(n) -> resp := n(unit)
    | KeyChange(n) -> skip //todo
} with (resp, stor)

function main(const param : actions; const contractStorage : storage) : return is
case param of
 Default -> ((nil : list(operation)), contractStorage)
 MainAction(p) -> processAction(contractStorage, p)
end