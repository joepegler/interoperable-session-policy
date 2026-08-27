# Candidate interoperable session profile v0.1

## Status

This is a research proposal for review, not an ERC draft, ABI, or deployable interface. `interop-session-baseline/1` and all policy names below are working identifiers. The profile deliberately specifies semantic requirements before choosing a Solidity layout or canonical wire codec.

The proposal is derived from the pinned evidence in [SOURCES.md](./SOURCES.md) and the mappings in [COMPARISON.md](./COMPARISON.md). The central recommendation is a stable semantic grant with implementation-specific bindings beneath it.

## Objectives

The profile should let a dapp:

1. create one restricted secp256k1 session key;
2. request authority over one existing account on one chain without substituting another account or pool of funds;
3. name exact target-and-selector pairs, value bounds, direct ERC-20 transfer bounds, recipients, and a finite validity window;
4. receive the exact authority actually granted, including any wallet attenuation;
5. exercise the grant through different account and transaction systems without changing its meaning; and
6. rely on the root wallet/account to revoke a live grant.

A wallet should be able to decode and display every baseline field without interpreting an opaque manager configuration. An enforcement adapter should be able to decide every baseline call without dapp-specific logic.

## Non-goals

Baseline v1 should not define:

- root-account ownership, recovery, or wallet connection;
- a companion account, embedded wallet, alternate custody model, or fund migration;
- EIP-8130 Keystore internals or privileged protocol dispatch;
- an ERC-4337 `UserOperation`, EIP-8141 frame transaction, EIP-7702 delegation, or any other transaction envelope;
- a universal account execution ABI, manager address, policy programming language, or evaluator marketplace;
- gas sponsorship, paymaster selection, fee policy, or relayer trust;
- message-signing permissions;
- recurring or streaming allowances, general call counts, Boolean policy graphs, arbitrary calldata predicates, or cross-chain grants;
- token approvals, permits, `transferFrom`, NFTs, indirect asset movement, or guarantees about a token's economic behavior; or
- atomic multi-permission negotiation through the ERC-7715 request array.

Those capabilities remain in the observed union and can become typed extensions or separate profiles. Their exclusion is not a claim that they are unimportant.

## Semantic envelope

The following JSON-like shape is illustrative. Field ordering, integer representation, byte encoding, hash function, and identifier allocation remain open design choices.

```text
SessionGrantV1 {
  profile: "interop-session-baseline/1"
  chainId: eip155-chain-id
  account: evm-address
  actor: {
    type: "secp256k1-address/1"
    value: evm-address
  }
  validAfter: unix-time-seconds
  validUntil: unix-time-seconds
  salt: 32-byte-unique-value
  policies: [
    CallScopePolicyV1,
    NativeValueTotalPolicyV1?,
    ERC20TransferTotalPolicyV1?
  ]
}
```

The envelope describes authority. It contains no manager, module, entry point, paymaster, factory, `UserOperation`, frame, or ERC-7710 context. Those belong to a **binding** returned with the granted object.

Each named policy above is shorthand for a typed entry `{ type, version, data }`. Type and version are committed fields, not hints inferred from the data shape or an evaluator address. Baseline canonicalization fixes the policy order and permits at most one entry of each baseline type.

Baseline v1 is single-account and single-chain. `chainId` is positive; `account` and `actor.value` are nonzero EVM addresses. `account` is the account whose authority is delegated; `actor.value` is the session-key address and is required to differ from `account`. A wallet may resolve an omitted account in a request, but a granted object always contains both an exact `chainId` and exact `account`.

`salt` makes independently issued otherwise-identical grants distinguishable. It is not a substitute for chain, account, actor, or profile domain separation.

## Actor representation

Every baseline implementation supports an actor identified by the Ethereum address derived from a secp256k1 public key. This is the strongest narrow mapping across EIP-8130's [K1 authenticator](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/Keystore.sol#L189-L224), Smart Sessions' typed validators and test K1 adapter, Kernel's [`ECDSASigner`](https://github.com/zerodevapp/kernel-7579-plugins/blob/332deed6eeef3d6279cde50aa1d51eff53728bd4/src/signers/ECDSASigner.sol), and MetaMask's address delegate; the underlying systems' validator or authenticator contracts remain binding-specific.

Baseline v1 does not standardize passkeys, WebAuthn, multisignature actors, ERC-1271 actors, or opaque validator initialization data. Those require typed actor extensions rather than overloading an address with wallet-specific meaning.

The authorization that creates a binding must prove that the root account approved both the semantic grant and the chosen enforcement integration. Possession of the session key alone must never install, widen, or replace its own grant.

## Baseline policy types

Support for all three types below is required for profile conformance. A particular zero-value grant need not contain both asset policies. Every included policy is required and enforceable; baseline has no advisory or silently ignorable entries.

### `call-scope/1`

Exactly one call-scope policy is present. It contains a non-empty set of entries of this illustrative shape:

```text
CallScope {
  target: evm-address
  selectors: 4-byte-selector[]
  allowEmptyCalldata: boolean
  maxNativeValuePerCall: nonnegative-integer
}
```

Its semantics are:

- A normal EVM `CALL` is eligible when its target matches one entry and either its first four calldata bytes equal one selector in that same entry or its calldata is empty and `allowEmptyCalldata` is true.
- One-to-three-byte calldata never matches. At least one selector or the explicit empty-calldata flag must be present.
- Targets are nonzero. Selectors within an entry and entries within the policy are unique and canonically ordered. A wildcard target, wildcard selector, fallback wildcard, `DELEGATECALL`, `CALLCODE`, contract creation, and account self-call are unavailable in baseline v1.
- The call value must not exceed the matched entry's `maxNativeValuePerCall`. Zero means no native value, not unlimited value.
- If several entries could match, canonical validation must yield the same effective maximum; the simplest v1 rule is to reject duplicate target-selector/empty-call alternatives.

Pairing is security-critical. Independent target and selector lists could turn intended pairs `(A, x)` and `(B, y)` into four allowed actions. EIP-8130's [`CallScope`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/SessionPolicy.sol#L77-L89) and Smart Sessions' hashed [`ActionData`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/IdLib.sol#L13-L30) both support the paired model.

An adapter must also reserve its own privilege-changing account, manager, validator, installation, and revocation paths. If a requested scope intersects one of those paths, the wallet rejects or attenuates the request before grant; it must not return a grant it knows it will interpret differently.

### `native-value-total/1`

This policy contains one positive `maxAmount` for the whole grant lifetime. It is required whenever any call scope permits non-zero native value and absent otherwise.

For every permitted call, the charged amount is the EVM call value. The adapter checks and consumes the amount before the external call so reentrancy cannot reuse the same capacity. Consumption rolls back only when the enclosing state transition reverts. Calls in a batch are evaluated in execution order against the aggregate counter.

The total is deliberately not periodic or streaming. Those models differ on start anchors, partial periods, reset behavior, and unused capacity across EIP-8130, MetaMask, and Base Account Policies.

### `erc20-transfer-total/1`

This policy contains one or more entries:

```text
ERC20TransferLimit {
  token: evm-address
  recipients: evm-address[]
  maxAmount: nonnegative-integer
}
```

Each token, recipient, and maximum is nonzero; tokens and recipient entries are unique and canonically ordered. The policy authorizes only a direct `transfer(address,uint256)` call made by `account` to the exact `token`, with zero native value, exactly 68 bytes of canonical ABI calldata, a recipient in the non-empty recipient set, and a cumulative decoded `amount` no greater than the positive `maxAmount`. The matching `(token, transfer(address,uint256))` pair must also appear in `call-scope/1`.

The charged amount is the calldata argument, not an observed balance delta. It is consumed before the token call and rolled back only if the enclosing state transition reverts. A token returning `false` without reverting may therefore consume capacity. Wallet display must say **direct requested transfer amount**, not promise the recipient's received balance.

Any call-scope alternative using selector `0xa9059cbb` must have a matching token-limit entry; a selector collision is rejected rather than treated as an unmetered generic call. `approve`, allowance increase/decrease, `permit`, `transferFrom`, ERC-721/1155 transfers, token-specific methods, and transfers caused indirectly by a permitted dapp call are not covered. An implementation must not market this policy as a bound on all possible asset effects of the session.

Direct-transfer limits have concrete but non-identical precedents in EIP-8130 [`SessionPolicy`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/SessionPolicy.sol#L321-L404), Smart Sessions [`ERC20SpendingLimitPolicy`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/external/policies/ERC20SpendingLimitPolicy.sol), MetaMask's transfer enforcers, and Base's [`TransferSettingsPolicy`](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/policies/TransferSettingsPolicy.sol). The narrow definition above intentionally does not inherit their approval, `transferFrom`, recurrence, or balance-check differences.

## Validity

`validAfter` and `validUntil` are Unix timestamps in seconds. A grant is valid exactly when:

```text
validAfter <= block timestamp < validUntil
```

`validUntil` is mandatory and finite, and must be greater than `validAfter`. The adapter must convert this half-open interval conservatively when an underlying system uses inclusive expiry or ERC-4337 validation ranges. It must never round or translate the window into broader authority.

Expiry stops future exercise but does not replace live revocation. Neither expiry nor revocation reverses effects of calls that already succeeded.

## Composition and evaluation

Baseline composition is conjunctive at the policy layer:

1. `call-scope/1` selects one explicitly enumerated call alternative.
2. Every constraint attached to that scope passes.
3. Every applicable grant-wide value or direct-transfer constraint passes.
4. The binding's actor authentication, validity, replay, and revocation checks pass.

The OR is confined to alternatives inside `call-scope/1`; it is not a general Boolean policy operator. All policies that govern a matched call compose with AND/intersection. Smart Sessions' policy intersection and Kernel's policy/signer intersection are the clearest implementation precedents. General OR wrappers and nested policy graphs stay outside the baseline.

A direct token-transfer policy is applicable only to the exact direct call shape it defines. It does not inspect or certify arbitrary downstream token effects. This explicit applicability rule avoids presenting a partial decoder as a universal spending guard.

Each stateful policy has one logical counter per `grantId`. Selecting another supported transport must not create fresh spending capacity. A wallet either returns one live enforcement binding or ensures that every route for the grant shares the same usage and revocation state.

## Requested versus granted authority

The response always contains the complete canonical **granted** object. A wallet UI must compare it with the requested object and identify every change; it must not make the dapp reconstruct changes from opaque context.

If adjustment is disallowed, request and response are semantically identical after canonicalization, except that the wallet may fill an omitted `account`. If adjustment is allowed, the granted object is acceptable only when it is no broader under all of these rules:

| Field | Permitted narrowing |
| --- | --- |
| Profile, chain, actor | No change. An unsupported value causes rejection. |
| Account | No change when requested; an omitted request account may resolve to one user-selected account. |
| Validity | `validAfter` may move later; `validUntil` may move earlier. |
| Call alternatives | Remove exact alternatives or remove empty-calldata permission. Do not substitute a target or selector. |
| Per-call native value | Reduce the maximum. |
| Grant-lifetime native value | Reduce the maximum. |
| ERC-20 transfer | Keep the same token, reduce `maxAmount`, and/or take a subset of recipients. |
| Extension | Apply that exact extension version's decidable narrowing relation. |

Changing the session actor is never attenuation because the dapp would no longer control the approved key. Removing a positive call alternative narrows authority; removing a restrictive limit widens it. Array length alone is not a safe comparison.

An adjusted response must not introduce a policy type/version that was absent from the request. Even if the wallet considers it restrictive, the dapp may not know its operational or failure semantics. Such a change is a separately reviewed counter-offer.

ERC-7715 currently describes adjustment in language broad enough to include increases. This permission type should define `isAdjustmentAllowed` more narrowly: increases and substitutions require a new user-approved request, not an attenuated response.

## Commitment and replay domain

The semantic grant needs a deterministic identifier of the following conceptual form:

```text
grantId = HASH(domain || canonicalEncode(granted SessionGrantV1))
```

The encoded preimage must bind the profile and policy versions, chain, account, actor, validity window, salt, policy contents, and collection ordering. It must distinguish absent fields from zero values and prevent alternate encodings of the same grant. Hash algorithm, canonical encoding, exact domain string, and extension encoding are deliberately not selected in this first pass; they are priority-zero decisions in [OPEN_QUESTIONS.md](./OPEN_QUESTIONS.md).

The semantic `grantId` should not include a transport, manager address, factory dependency, or opaque ERC-7710 context, because that would prevent the same meaning from being bound by different systems. Instead, root authorization must separately bind `grantId` to the selected manager/module/account integration and its replay domain. A portable semantic hash without binding-specific authorization would let an attacker route an approved grant through an unintended evaluator.

The current EIP-8130 reference manager's [commitment](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/PolicyManager.sol#L248-L271) is not this proposed grant identifier: it commits to account, policy contract, config hash, validity, and salt but not a named semantic profile. An adapter could nest `grantId` in its config or use a new binding, but equivalence must be specified and tested rather than assumed.

## Extension mechanism

The envelope may later carry typed policies outside the baseline. Every extension definition must provide:

- a stable, namespaced type identifier and explicit version;
- one canonical encoding and semantic interpretation;
- applicability, composition, evaluation order, state, and failure behavior;
- a deterministic wallet-display schema;
- a decidable attenuation relation, or a declaration that adjustment is forbidden;
- security considerations and test vectors; and
- capability-discovery information for each supported chain and binding.

Every policy included in a grant is required. Unknown type identifiers, unknown versions, malformed data, unsupported required profiles, and unsupported combinations fail closed during discovery/request validation, import, installation, validation, and redemption. No implementation may ignore an entry and still claim that it enforces the same grant.

Wallet-specific types can use namespaces, but are not part of baseline conformance merely because they share the envelope. General OR, recurring allowance, streaming allowance, arbitrary argument predicates, redeemer identity, message signing, approvals, NFTs, and batch-shape policies are plausible first extensions from the union in [COMPARISON.md](./COMPARISON.md#observed-union-taxonomy).

## Rough ERC-7715 binding

The least ambiguous ERC-7715 mapping is one permission entry containing the whole semantic grant, rather than several separately granted permissions whose atomicity and composition are unclear. This is a shape sketch only:

```text
PermissionRequest {
  chainId: <same single chain>
  from?: <requested account, or omitted for wallet selection>
  to: <session actor address>
  permission: {
    type: "interop-session-grant"
    isAdjustmentAllowed: true | false
    data: <requested SessionGrantV1 without a resolved account when `from` is omitted>
  }
  rules: null
}

PermissionResponse {
  ...request fields rewritten to contain the exact granted SessionGrantV1
  context: <opaque binding/redemption and revocation handle>
  dependencies: <binding-specific deployment dependencies>
  delegationManager: <ERC-7710-compatible manager required by current ERC-7715>
}
```

The profile's restrictions remain inside the one typed permission; duplicating expiry, payee, or redeemer constraints as external ERC-7715 `rules` would create two sources of truth. The response's `context`, `dependencies`, and `delegationManager` are binding artifacts and are not hashed into the semantic grant. Because current ERC-7715 requires an ERC-7710 manager, a native EIP-8130 binding cannot use this response unchanged unless its manager is compatible or ERC-7715 evolves; this is an explicit open question, not an optional field.

The binding needs a capability response that says at minimum: supported profile versions, actor types, extension type/versions, chains, and available enforcement bindings. ERC-7715's current permission-type discovery may carry the top-level permission name, but the exact nested-profile discovery format remains open.

## Exercise and revocation information

The response or a separately discoverable binding descriptor must provide enough information to:

- reproduce and verify `grantId` from the exact granted object;
- authenticate as the session actor;
- identify the target chain and account;
- select the manager/module/validator and account integration;
- encode a single call or supported batch without changing its semantic interpretation;
- supply any binding authorization proof, manager-specific context, nonce, or deployment dependency;
- determine whether the final application call executes from `account`;
- query active, expired, and revoked status; and
- submit root-authorized revocation of this live binding.

A conforming revocation binding guarantees that the root wallet/account can disable a live grant without the session actor's cooperation and that, once the revocation state is effective on the target chain, every later validation attempt fails. Destroying the session key, revoking an unused installation signature, or hiding a grant from wallet UI is not sufficient. Bindings may expose different revocation ABIs and finality models, but the wallet must identify them and must not claim success before the binding's revocation condition is met.

## Mapping to observed enforcement systems

| Binding | Plausible mapping | Required caveat |
| --- | --- | --- |
| Native EIP-8130 | K1 actor with `POLICY` scope; manager/evaluator commits to and enforces the grant; protocol/account path dispatches approved calls. | The exact component that preserves account identity and whether a canonical manager is intended need confirmation. Current `SessionPolicy` is evidence, not an exact baseline implementation. |
| Non-native EIP-8130 / ERC-4337 | Account hook consults Keystore or trusted manager; an adapter validates the same grant; account executes. | `executeFor` or a common ABI alone does not make arbitrary accounts trust the manager. |
| EIP-7702 delegated EOA code | Delegated account code installs or trusts a baseline validator/manager and executes approved calls from the existing EOA address. | EIP-7702 sets account code but does not define the permission, counter, or live-grant revocation semantics. The chosen code and authorization lifecycle are binding data. |
| Smart Sessions / ERC-7579 | Compile paired actions and intersecting policies into a session module; account executes. | The canonical grant, not Smart Sessions' narrower `PermissionId`, must be committed; unsupported selectors such as approvals remain excluded. |
| Kernel | Install a baseline adapter plus the session signer; Kernel account executes. | Existing four-byte permission IDs and generic policy ABI do not encode the portable grant by themselves. |
| MetaMask / ERC-7710 | Compile to exact execution/call and asset caveats; redeem through a manager that calls the delegator account. | Separate target and method caveats must not widen intended pairs; opaque ERC-7710 contexts are not the semantic object. |
| EIP-8141 | Validator inspects every relevant `SENDER` frame and aggregate limits before approval; approved frames execute as the account. | Validation of only one frame could miss batch authority or total use. The binding must define frame selection and accounting. |

## Conformance boundary

The following must remain identical across wallets claiming `interop-session-baseline/1`:

- actor, account, chain, validity, call-scope, value, recipient, and direct-transfer meaning;
- pairing, composition, applicability, counter charging, batch aggregation, and failure rules;
- request-to-grant attenuation and complete response disclosure;
- canonical semantic encoding and `grantId` once selected;
- rejection of unknown or unsupported required content;
- preservation of account execution identity where the binding claims it;
- live root revocation and status semantics; and
- the minimum wallet display: actor, account, chain, every target-selector pair, empty-call permission, per-call and cumulative native value, every token/recipient/cap, validity, and all request/grant differences.

Wallets may vary:

- transaction transport, relayer, bundler, and fee path;
- account code, validator/authenticator, policy module, manager, and storage layout;
- how the root authorization is signed and installed;
- ERC-7710 context, nonce, factory/deployment dependencies, and calldata packaging;
- internal counter representation and gas optimization, provided observable semantics match; and
- additional explicitly requested, supported, and displayed extension policies.

A wallet claiming baseline conformance must advertise support before the request, return the full granted semantic object, bind it to an actual enforcing integration, reject rather than ignore unsupported content, preserve the promised account execution identity, and offer root-controlled live revocation. Merely accepting a JSON shape or returning opaque executable bytes is not conformance.

## Recommendation

1. **Smallest useful standard:** define the versioned semantic envelope, exact paired-call policy, finite validity, per-call and grant-lifetime native bounds, narrow direct ERC-20 transfer totals and recipients, deterministic commitment, narrowing-only grant adjustment, discovery, truthful account-execution binding, and live revocation requirements.
2. **Keep outside:** universal execution/account ABIs, one mandatory manager, transport envelopes, gas policy, approvals and indirect asset guarantees, message signing, multi-chain grants, recurring/streaming accounting, general Boolean composition, arbitrary calldata programs, and wallet-specific lifecycle machinery.
3. **One ERC or two:** one semantic-profile ERC with an ERC-7715 binding appears sufficient for the first proposal. If implementers also converge on a reusable onchain evaluator/manager ABI, specify that separately; its account trust and execution guarantees are a different standardization boundary and may require Core-EIP cooperation for native dispatch.
4. **Next milestone:** ask Chris and implementers to resolve the priority-zero questions, then freeze the schema and codec in a small TypeScript package with canonical encode/decode/hash, attenuation, negative parsing cases, and cross-binding conformance vectors before drafting ERC text or Solidity.
