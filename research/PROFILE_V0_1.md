# Provisional Interoperable Session Profile v0.1

## Status

This file preserves a schema sketch from the first research pass for possible post-gate work. It predates the current review gate and is not an accepted profile, ERC draft, ABI, deployable interface, or current milestone deliverable. `interop-session-baseline/1` and all policy names below are working identifiers.

Do not implement or freeze this schema before review of [STANDARDS-SHAPE.md](./STANDARDS-SHAPE.md), [FRAMEWORK-COMPARISON.md](./FRAMEWORK-COMPARISON.md), and [POLICY-CAPABILITY-UNION.md](./POLICY-CAPABILITY-UNION.md). In particular, native and ERC-20 totals are unresolved baseline candidates. The requirement to commit to the complete semantic grant is candidate baseline material, but the canonical codec, hash, domain, ordering, identifiers, discovery shape, and binding interfaces remain open.

Where the retained sketch below says "baseline v1", "required", or "conformance", it describes the conditions of the earlier hypothesis if those elements are later selected. The classifications in `POLICY-CAPABILITY-UNION.md` govern the current review package.

## Objectives

The profile should let a dapp:

1. create one restricted secp256k1 session key;
2. request authority over one existing account on one chain without substituting another account or pool of funds;
3. name exact target-and-selector pairs and a finite validity window, with value and direct ERC-20 bounds available only if their unresolved semantics are promoted;
4. receive the exact authority actually granted, accepting an adjustment only when that type has a decidable equal-or-narrower relation and otherwise treating the result as a counter-offer;
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
- token approvals, permits, `transferFrom`, NFTs, indirect asset movement, or guarantees about a token's economic behaviour; or
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

Each named policy above is shorthand for a typed entry `{ type, version, data }`. Type and version are committed fields, not hints inferred from the data shape or an evaluator address. Any later selected profile would need canonicalisation rules for policy ordering and multiplicity.

Baseline v1 is single-account and single-chain. `chainId` is positive; `account` and `actor.value` are nonzero EVM addresses. `account` is the account whose authority is delegated; `actor.value` is the session-key address and is required to differ from `account`. A wallet may resolve an omitted account in a request, but a granted object always contains both an exact `chainId` and exact `account`.

`salt` makes independently issued otherwise-identical grants distinguishable. It is not a substitute for chain, account, actor, or profile domain separation.

## Actor representation

Every baseline implementation supports an actor identified by the Ethereum address derived from a secp256k1 public key. This is the strongest narrow mapping across EIP-8130's [K1 authenticator](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/Keystore.sol#L189-L224), Smart Sessions' typed validators and test K1 adapter, Kernel's [`ECDSASigner`](https://github.com/zerodevapp/kernel-7579-plugins/blob/332deed6eeef3d6279cde50aa1d51eff53728bd4/src/signers/ECDSASigner.sol), and MetaMask's address delegate; the underlying systems' validator or authenticator contracts remain binding-specific.

Baseline v1 does not standardise passkeys, WebAuthn, multisignature actors, ERC-1271 actors, or opaque validator initialisation data. Those require typed actor extensions rather than overloading an address with wallet-specific meaning.

The authorisation that creates a binding must prove that the root account approved both the semantic grant and the chosen enforcement integration. Possession of the session key alone must never install, widen, or replace its own grant.

## Baseline policy types

The earlier hypothesis proposed all three types below. The current review classifies exact action scope as a candidate mandatory baseline, while per-call native value, lifetime native value, and direct ERC-20 totals remain unresolved. The two asset sections are retained as concrete definitions to test, not current conformance requirements. No profile conformance claim exists at this stage.

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

`maxNativeValuePerCall` is part of the earlier hypothesis and remains unresolved. If it is not promoted, the mandatory exact-action subset permits zero native value only and a separately versioned extension must authorise value.

Its semantics are:

- A normal EVM `CALL` is eligible when its target matches one entry and either its first four calldata bytes equal one selector in that same entry or its calldata is empty and `allowEmptyCalldata` is true.
- One-to-three-byte calldata never matches. At least one selector or the explicit empty-calldata flag must be present.
- Targets are nonzero. Selectors within an entry and entries within the policy are unique and canonically ordered. A wildcard target, wildcard selector, fallback wildcard, `DELEGATECALL`, `CALLCODE`, contract creation, and account self-call are unavailable in baseline v1.
- The call value must not exceed the matched entry's `maxNativeValuePerCall`. Zero means no native value, not unlimited value.
- If several entries could match, canonical validation must yield the same effective maximum; the simplest v1 rule is to reject duplicate target-selector/empty-call alternatives.

Pairing is security-critical. Independent target and selector lists could turn intended pairs `(A, x)` and `(B, y)` into four allowed actions. EIP-8130's [`CallScope`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/SessionPolicy.sol#L77-L89) and Smart Sessions' hashed [`ActionData`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/IdLib.sol#L13-L30) support paired targets and selectors, but not the exact short-calldata rule above. The current EIP-8130 reference permits empty calldata for every explicit target scope, while Smart Sessions maps all calldata shorter than four bytes to one sentinel. Both need an adapter check to avoid widening (F-POLICY-08).

An adapter must also reserve its own privilege-changing account, manager, validator, installation, and revocation paths. If a requested scope intersects one of those paths, the wallet rejects or attenuates the request before grant; it must not return a grant it knows it will interpret differently.

### Unresolved sketch: `native-value-total/1`

This policy contains one positive `maxAmount` for the whole grant lifetime. It is required whenever any call scope permits non-zero native value and absent otherwise.

For every permitted call, the charged amount is the EVM call value. The adapter checks and consumes the amount before the external call so reentrancy cannot reuse the same capacity. Consumption rolls back only when the enclosing state transition reverts. Calls in a batch are evaluated in execution order against the aggregate counter.

The total is deliberately not periodic or streaming. Those models differ on start anchors, partial periods, reset behaviour, and unused capacity across EIP-8130, MetaMask, and Base Account Policies.

### Unresolved sketch: `erc20-transfer-total/1`

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

The retained hypothesis scopes each selected stateful policy counter to `grantId`. The exact counter-group model is not accepted: current frameworks scope counters to permissions, actions, delegation hashes, IDs, or policy configurations. Selecting another supported transport must not create fresh spending capacity. The current baseline projection therefore returns one live enforcement binding; multi-route exercise stays unresolved until every route demonstrably shares usage and revocation state.

## Requested versus granted authority

The response always contains the complete canonical **granted** object. A wallet UI must compare it with the requested object and identify every change; it must not make the dapp reconstruct changes from opaque context. No wider or substituted result is an attenuated success.

If adjustment is disallowed, request and response are semantically identical after canonicalisation, except that the wallet may fill an omitted `account`. If adjustment is allowed, the granted object is acceptable only when it is no broader under the retained rules below. This table is an earlier design hypothesis, not a completed partial order. Adjustment remains forbidden for any policy type or version whose relation has not been reviewed and made decidable:

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

The encoded preimage must bind the profile and policy versions, chain, account, actor, validity window, salt, policy contents, and collection ordering. It must distinguish absent fields from zero values and prevent alternate encodings of the same grant. Hash algorithm, canonical encoding, exact domain string, and extension encoding are deliberately not selected in this first pass; they remain deferred design questions in [OPEN_QUESTIONS.md](./OPEN_QUESTIONS.md).

The semantic `grantId` should not include a transport, manager address, factory dependency, or opaque ERC-7710 context, because that would prevent the same meaning from being bound by different systems. Instead, root authorisation must separately bind `grantId` to the selected manager/module/account integration and its replay domain. A portable semantic hash without binding-specific authorisation would let an attacker route an approved grant through an unintended evaluator.

The current EIP-8130 reference manager's [commitment](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/PolicyManager.sol#L248-L271) is not this proposed grant identifier: it commits to account, policy contract, config hash, validity, and salt but not a named semantic profile. Smart Sessions' `PermissionId` also omits the actions and policies ([F-POLICY-09](./FINDINGS.md#f-policy-09-smart-sessions-permission-ids-are-not-complete-semantic-grant-commitments)). An adapter could nest `grantId` in framework configuration or use a new binding, but equivalence must be specified and tested rather than assumed.

## Extension mechanism

The envelope may later carry typed policies outside the baseline. Every extension definition must provide:

- a stable, namespaced type identifier and explicit version;
- one canonical encoding and semantic interpretation;
- applicability, composition, evaluation order, state, and failure behaviour;
- a deterministic wallet-display schema;
- a decidable attenuation relation, or a declaration that adjustment is forbidden;
- security considerations and test vectors; and
- capability-discovery information for each supported chain and binding.

Every policy included in a grant is required. Unknown type identifiers, unknown versions, malformed data, unsupported required profiles, and unsupported combinations fail closed during discovery/request validation, import, installation, validation, and redemption. No implementation may ignore an entry and still claim that it enforces the same grant.

Wallet-specific types can use namespaces, but are not part of baseline conformance merely because they share the envelope. Target-only and fallback actions, recurring and streaming allowances, bounded usage, declared gas budgets, argument predicates, runtime witnesses, redeemer identity, message and claim signing, approval grant and revocation, NFT authority, exact batches, permission-use payment, and ownership transfer are extension candidates in [POLICY-CAPABILITY-UNION.md](./POLICY-CAPABILITY-UNION.md). Delegatecall, wildcard actors, named shared quota groups, and portable redelegation remain unresolved rather than implied extension support.

## ERC-7715 binding direction

The least ambiguous request mapping is one permission entry containing the semantic body, rather than several separately granted permissions whose atomicity and composition are unclear. Outer ERC-7715 fields are the only wire authorities for chain, account, and the address actor:

```text
PermissionRequest {
  chainId: <same single chain>
  from?: <requested account, or omitted for wallet selection>
  to: <session actor address>
  permission: {
    type: "interop-session-grant"
    isAdjustmentAllowed: true | false
    data: <requested semantic body without chain, account, or actor>
  }
  rules: absent
  responseBindings: <non-empty advertised type-version pairs>
}
```

The session grant must be the sole request-array element until cross-entry atomicity is defined. `from` may be omitted for wallet selection in the request but is required in the response. The canonical full grant is reconstructed from `chainId`, resolved `from`, `to`, and the returned semantic body, so mismatched duplicates cannot compete.

The current option 3 recommendation then distinguishes two response variants:

```text
PermissionResponse =
  | LegacyERC7710PermissionResponse
  | BoundPermissionResponse {
      ...request fields rewritten to contain the exact granted object
      from: <resolved account>
      context: <wallet grant, exercise, and revocation handle>
      binding: {
        type: <advertised binding type>
        version: <advertised binding version>
        data: <binding-specific deployment, exercise, status, and revocation data>
      }
    }
```

The legacy response retains its current `context`, `dependencies`, `delegationManager`, and ERC-7710 redemption meaning. A bound response is mutually exclusive with that legacy variant and must not return dummy legacy fields. Its selected binding must be one exact pair negotiated in `responseBindings` and present in an advertised chain-profile-actor-extension-binding configuration. The profile's restrictions remain inside the one typed permission; duplicating expiry, payee, or redeemer constraints as external ERC-7715 `rules` would create two sources of truth. Neither legacy nor typed binding data is part of the semantic grant commitment.

Discovery must advertise exact supported chain-profile-actor-extension-binding configurations before request time rather than independent lists that imply a Cartesian product. The current no-parameter list method is a separate compatibility blocker because it returns all live grants; option 3 needs a legacy-safe versioned or filtered listing path. The field-level straw man, normative behaviour, compatibility conditions, and versioned-successor fallback are in [STANDARDS-SHAPE.md](./STANDARDS-SHAPE.md).

## Exercise and revocation information

The response's typed binding descriptor or an explicitly versioned wallet status method must provide enough information to:

- reproduce and verify `grantId` from the exact granted object;
- authenticate as the session actor;
- identify the target chain and account;
- select the manager/module/validator and account integration;
- encode a single call or supported batch without changing its semantic interpretation;
- supply any binding authorisation proof, manager-specific context, nonce, or deployment dependency;
- determine whether the final application call executes from `account`;
- query active, expired, and revoked status; and
- submit root-authorised revocation of this live binding.

A conforming revocation binding guarantees that the root wallet/account can disable a live grant without the session actor's cooperation and that, once the revocation state is effective on the target chain, every later validation attempt fails. Destroying the session key, revoking an unused installation signature, or hiding a grant from wallet UI is not sufficient. Bindings may expose different revocation ABIs and finality models. The current ERC-7715 revoke result is internally inconsistent and has no status method ([F-7715-06](./FINDINGS.md#f-7715-06-revocation-result-and-status-semantics-are-internally-incomplete)), so pending, effective, failed, and finalised result semantics remain to be selected.

## Mapping to observed enforcement systems

| Binding | Plausible mapping | Required caveat |
| --- | --- | --- |
| Native EIP-8130 | K1 actor with `POLICY` scope; manager/evaluator commits to and enforces the grant; protocol/account path dispatches approved calls. | The protocol-to-manager leg preserves account identity. The reference manager then forwards through a separately authorised trusted executor; whether that two-actor construction is the normative binding needs confirmation. Current `SessionPolicy` is evidence, not an exact baseline implementation. |
| Non-native EIP-8130 / ERC-4337 | Account hook consults Keystore or trusted manager; an adapter validates the same grant; account executes. | `executeFor` or a common ABI alone does not make arbitrary accounts trust the manager. |
| EIP-7702 delegated EOA code | Delegated account code installs or trusts a baseline validator/manager and executes approved calls from the existing EOA address. | EIP-7702 sets account code but does not define the permission, counter, or live-grant revocation semantics. The chosen code and authorisation lifecycle are binding data. |
| Smart Sessions / ERC-7579 | Compile paired actions and intersecting policies into a session module; account executes. | The canonical grant, not Smart Sessions' narrower `PermissionId`, must be committed. The baseline adapter rejects approval and other excluded action types even though v1 policies can decode some of them. V2 enable expiry is signed-config freshness rather than live-grant validity. |
| Kernel | Install a baseline adapter plus the session signer; Kernel account executes. | Existing four-byte permission IDs and generic policy ABI do not encode the portable grant by themselves. |
| MetaMask / ERC-7710 | Compile to exact execution/call and asset caveats; redeem through a manager that calls the delegator account. | Separate target and method caveats must not widen intended pairs; opaque ERC-7710 contexts are not the semantic object. |
| EIP-8141 | Validator constrains all subsequent `SENDER` frames before approval; approved frames execute as the account. | The current PoC checks one selected frame, discards returned timestamp bounds, and does not demonstrate nested dapp-action selector enforcement. Stateful totals need an aggregate read-only pre-check plus a later account hook, with mutation, rollback, reentrancy, and race rules. |

## Conformance boundary

A later accepted profile would require the following to remain identical across conforming wallets:

- actor, account, chain, validity, and exact call-scope meaning;
- pairing, composition, applicability, and failure rules;
- if a value or asset capability is selected, that exact version's value, recipient, charging, batch, rollback, and failure meaning;
- no implicit widening, complete response disclosure, and adjustment only under a selected type's decidable equal-or-narrower relation;
- canonical semantic encoding and `grantId` once selected;
- rejection of unknown or unsupported required content;
- preservation of account execution identity where the binding claims it;
- live root revocation and status semantics; and
- the minimum wallet display: actor, account, chain, every target-selector pair, empty-call permission, validity, all request/grant differences, and every field of any selected value or asset capability.

Wallets may vary:

- transaction transport, relayer, bundler, and fee path;
- account code, validator/authenticator, policy module, manager, and storage layout;
- how the root authorisation is signed and installed;
- ERC-7710 context, nonce, factory/deployment dependencies, and calldata packaging;
- internal counter representation and gas optimisation, provided observable semantics match; and
- additional explicitly requested, supported, and displayed extension policies.

If a profile identifier is allocated after review, a wallet claiming conformance must advertise support before the request, return the full granted semantic object, bind it to an actual enforcing integration, reject rather than ignore unsupported content, preserve the promised account execution identity, and offer root-controlled live revocation. Merely accepting a JSON shape or returning opaque executable bytes is not conformance.

## Current treatment

1. Preserve the one-chain address actor, replay-resistance, exact-action, finite-validity, complete-commitment, fail-closed, display, no-implicit-widening, account-originated-execution, one-live-binding, and live-revocation analysis as candidate semantic material.
2. Treat native and direct ERC-20 limits as unresolved baseline candidates pending implementer agreement on observable accounting.
3. Use a companion semantic ERC plus a narrow ERC-7715 binding generalisation as the current standards-shape recommendation, subject to author review.
4. Resolve the first review gate before selecting a codec, commitment, identifier scheme, binding interface, TypeScript package, or Solidity artefact.
