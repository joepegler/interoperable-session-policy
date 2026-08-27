# Prioritized open questions

## How to use this list

These are decisions, not missing research citations. **P0** blocks a stable semantic schema or a truthful EIP-8130 mapping. **P1** blocks an ERC structure and conformance claim. **P2** can be deferred from baseline v1 but should be recorded so the envelope does not foreclose it.

Each recommendation is a default for discussion, not a statement about an implementer's intent. Source revisions and links are in [SOURCES.md](./SOURCES.md); the consequences of each observed difference are in [COMPARISON.md](./COMPARISON.md).

## P0 — resolve before freezing the profile and codec

### 1. What executes an approved EIP-8130 policy action as the account?

**Ask Chris:** In the intended native path, does protocol dispatch invoke the account, does the policy manager invoke an account execution function, or is another privileged executor planned? Which component guarantees that the final dapp sees `msg.sender == account`?

**Why it blocks:** The current draft gives a `POLICY` actor access only to its manager, while the reference manager and [`DefaultAccount`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/accounts/DefaultAccount.sol#L63-L95) together demonstrate one execution path. An ordinary manager calling a dapp directly cannot preserve the account's caller identity.

**Recommended default:** Keep the ERC semantic and require every binding to prove account-originated execution. Do not specify a canonical privileged executor without a Core-EIP guarantee.

### 2. How should the same grant execute without EIP-8130 transaction context?

**Ask Chris:** On a chain without native EIP-8130 transactions, is the intended route EIP-7702-delegated account code, an account-specific ERC-4337 hook, a Keystore-aware account method, the reference manager's `executeFor`, an EIP-8141 validator, or some combination? What exact account authorization makes the manager trusted?

**Why it blocks:** [`executeFor`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/PolicyManager.sol#L141-L192) can derive an external actor, but that alone does not make an arbitrary account execute the resulting call. The product claim must distinguish a portable grant from a portable account integration.

**Recommended default:** Define independent binding descriptors for native EIP-8130, EIP-7702/account-code, ERC-4337/account-module, and later EIP-8141 paths. Require semantic conformance across them; allow their authorization and calldata to differ.

### 3. Is the current `PolicyManager` mandatory, or merely one reference binding?

**Ask Chris:** Should baseline implementations use the current manager bytecode/address and `PolicyBinding`, implement a standard external validation/execution interface, or only satisfy behavioral conformance? Is a canonical manager or precompile actually planned?

**Why it blocks:** The current [`PolicyManager`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/PolicyManager.sol#L20-L271) combines one commitment format, one policy hook ABI, native transaction context, `executeFor`, and account dispatch assumptions. Mandating it would move implementation-specific choices into the semantic profile.

**Recommended default:** Require semantics and a small binding descriptor first. Treat the current manager as a reference implementation. Standardize an onchain interface separately only if at least two account systems can implement the same caller, revocation, and failure guarantees.

### 4. Is `SessionPolicy` intended to seed a standard or only illustrate extensibility?

**Ask Chris:** Which details are intentional candidates for common semantics: paired call scopes, an empty-selector wildcard, native/ERC-20 accounting, recipients, `transferFrom`, approvals, periods, self-call rejection, and state keyed by commitment?

**Why it blocks:** The reference [`SessionPolicy`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/SessionPolicy.sol#L10-L104) is the richest direct EIP-8130 evidence, but some of its selector and approval behavior is too broad or ambiguous for a universal wallet display. A copied struct would silently inherit those choices.

**Recommended default:** Treat it as evidence, not the baseline ABI. Retain exact paired scopes and grant-lifetime accounting; remove wildcards, approvals, `transferFrom`, and recurrence from baseline v1.

### 5. What exactly is the canonical commitment?

**Ask Chris:** Should EIP-8130's `policy_commitment` equal the transport-independent `grantId`, wrap it in a manager-specific commitment, or commit directly to manager configuration? Which hash, domain, versioning, collection order, and canonical encoding should be used? Should any ERC-8340 CBOR machinery be reused?

**Why it blocks:** EIP-8130 stores an opaque commitment. The reference manager hashes account, evaluator/config, validity, and salt, while Smart Sessions and MetaMask use different typed hashes. ERC-8340 is a useful deterministic-encoding precedent, but its metadata is non-authoritative and security semantics differ.

**Recommended default:** Define `grantId` as a domain-separated hash of only the canonical semantic grant, then bind `grantId` separately to the selected manager/account integration in the root authorization. Compare EIP-712-style encoding and deterministic CBOR using test vectors before choosing; do not reuse metadata commitments by implication.

### 6. Is the proposed direct-asset subset useful enough for every baseline wallet?

**Ask Chris and account implementers:** Will Coinbase, MetaMask, Smart Sessions, and Kernel implementations commit to exact target-selector pairs, per-call and cumulative native value, and grant-lifetime direct ERC-20 `transfer` totals with recipient sets? Does any implementation need approval, `transferFrom`, period, or indirect dapp spending in the mandatory profile?

**Why it blocks:** All systems can approximate value limits, but their tracked selectors, balance checks, period semantics, and recipients differ. The profile cannot safely label these all as one generic "spending limit."

**Recommended default:** Make native value and direct `transfer(address,uint256)` support mandatory capabilities, but require them in a grant only when used. Charge decoded/requested amounts. Put approvals, `transferFrom`, balance-delta guarantees, periodic/streaming limits, and indirect movement in extensions.

### 7. Are the composition and attenuation rules acceptable?

**Ask Chris and implementers:** Is the baseline model acceptable: one call-scope policy with OR across exact paired alternatives, AND across the selected scope and all applicable limits, and wallet adjustment limited to a formally defined narrowing relation?

**Why it blocks:** Smart Sessions selects alternative action pairs and intersects their policies; Kernel intersects policies and signer; MetaMask intersects caveats but also has an explicit OR wrapper. A blanket "all policy entries pass" is insufficient unless applicability and internal alternatives are defined.

**Recommended default:** Adopt the restricted model in [PROFILE_V0_1.md](./PROFILE_V0_1.md#composition-and-evaluation). Exclude general Boolean graphs. Treat an increase or substitution as a new request, even though current ERC-7715 wording describes adjustment more broadly.

### 8. What constitutes revoking a live grant?

**Ask Chris:** For native and non-native EIP-8130 paths, which root-authorized state change disables an already usable grant, and when may the wallet report it revoked? Does revoking the actor always invalidate every manager binding and cached authorization derived from it? If one grant is exercisable through multiple transports, where do they share revocation and spending state?

**Why it blocks:** EIP-8130 deletes actor configuration; Smart Sessions distinguishes removing a live session from revoking an unused enable signature; MetaMask disables a delegation hash; Kernel and Base uninstall stored policy state. These operations do not have identical propagation or identity.

**Recommended default:** Require a binding-specific root operation that makes every later use of the live `grantId` fail once effective onchain. One `grantId` has one logical counter and revocation state: either expose one live binding or make every route share state. Report nonce cancellation, key deletion, expiry, and live revocation as separate states.

## P1 — resolve before drafting an ERC

### 9. Must one baseline grant be negotiated atomically?

**Ask Chris and ERC-7715 implementers:** Should exact calls, value limits, token limits, expiry, and actor be one indivisible permission object? If multiple entries are sent in an ERC-7715 request array, must the wallet grant all or none, and are their policies intended to compose?

**Why it blocks:** The profile needs one authority and one attenuation comparison. The inspected systems atomically enforce related constraints inside one binding, but the current wallet RPC accepts arrays of permission requests without supplying the semantic composition model needed here.

**Recommended default:** Carry the entire baseline grant in one new ERC-7715 permission type. Treat request-array atomicity and cross-permission composition as outside this profile until ERC-7715 defines them explicitly.

### 10. Is ERC-7715 the normative wallet binding or one optional transport?

**Ask Chris:** Should a wallet claim baseline conformance only through ERC-7715 request/list/revoke methods, or may another RPC carry the same canonical object? How should the profile handle ERC-7715's manager and ERC-4337 deployment fields while remaining transport-independent?

**Why it blocks:** ERC-7715 is the closest dapp-facing surface, but its current [`PermissionResponse`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7715.md#request-specification) requires `context`, `dependencies`, and `delegationManager`. Those are binding artifacts, not semantic fields.

**Recommended default:** Make the semantic object independently canonical and define a normative ERC-7715 mapping for wallet interoperability. Other request transports may conform if they return exactly the same grant and binding guarantees.

### 11. Is ERC-7710 compatible with the intended manager path?

**Ask Chris and ERC-7710 implementers:** Should an EIP-8130 manager implement `redeemDelegations`, can its permission context carry an EIP-8130 binding without changing actor identity, and can its required atomic batch behavior coexist with native/account-specific execution paths?

**Why it blocks:** ERC-7710 standardizes only `redeemDelegations(bytes[],bytes32[],bytes[])`; contexts and account invocation remain manager-specific. The EIP-8130 reference manager exposes different entry points, and EIP-8130's multi-account helper has different failure behavior.

**Recommended default:** Treat ERC-7710 as an optional redemption binding. Require a round-trip conformance vector proving identical grant checks and account-originated calls before claiming compatibility; do not make ERC-7710 context the canonical grant.

### 12. How are profiles and extension types advertised and governed?

**Ask Chris and wallet implementers:** What discovery response should state support for `interop-session-baseline/1`, actor types, exact extension versions, chains, and bindings? Who allocates policy identifiers, and how are incompatible semantic revisions prevented from reusing a name?

**Why it blocks:** ERC-7715 discovers permission and rule types, while MetaMask's SDK has concrete schemas and every onchain framework allows arbitrary module/enforcer addresses. None supplies an ecosystem-wide nested profile/type registry.

**Recommended default:** Discovery must enumerate exact profile and policy type/version pairs before grant time. Use namespaced provisional identifiers until an ERC defines stable identifiers and change control. Unknown required content always fails closed.

### 13. What exact guarantees accompany a conformance claim?

**Ask all implementers:** Is support a claim about parsing, wallet display, request handling, onchain enforcement, account-originated execution, revocation, or all of them? How will a dapp distinguish partial support?

**Why it blocks:** Every surveyed stack separates wallet SDK, semantic configuration, policy evaluator, account integration, and transaction transport differently. A single Boolean that only means "accepted the JSON" would reproduce opaque wallet-specific permissions.

**Recommended default:** Full baseline conformance requires discovery, complete request/grant disclosure, exact semantic enforcement, unknown-type rejection, account-identity preservation, status, and live root revocation. If useful, define separately named request-only and enforcement-adapter test attestations, but neither alone should claim full profile support.

### 14. Should an onchain interface be a separate ERC?

**Ask Chris:** Does the first proposal need only the semantic profile plus bindings, or does adoption require one manager validation/execution ABI immediately?

**Why it blocks:** Semantics and wallet display can be common while trusted account execution remains EIP-8130-, ERC-7579-, Kernel-, or delegator-specific. Coupling them could delay the useful layer or imply caller privileges an ERC cannot create.

**Recommended default:** Start with one semantic-profile ERC and its ERC-7715/EIP-8130 mapping. Pursue a separate manager/evaluator-interface ERC only after two independent integrations prove the interface and caller semantics.

### 15. What must an EIP-8141 adapter inspect before approval?

**Ask EIP-8141/ERC-8286 implementers:** Must a baseline validator inspect all `SENDER` frames and aggregate value/token counters before `APPROVE`, and how are unsupported frame modes rejected?

**Why it blocks:** Once an EIP-8141 transaction is approved, relevant frames can execute as the account. Per-frame checks against the same pre-transaction counter can undercount a batch.

**Recommended default:** Validate all account-originated frames, call shapes, and aggregate limits before approval; reject unrecognized modes. Specify this in an EIP-8141 binding, not the semantic envelope.

## P2 — preserve as explicit extension work

### 16. Which batch semantics deserve a typed policy?

Should the union define exact ordered batches, unordered action sets, atomic batches, and best-effort batches as separate types? **Default:** baseline authorizes each call and aggregates stateful limits in execution order, while the binding truthfully reports actual atomicity. Do not claim a universal batch permission yet.

### 17. What is the next actor and chain-scope profile?

Should WebAuthn/ERC-1271/module actors and multichain grants share one envelope extension or require new profiles? **Default:** keep baseline to a K1-address actor on one EIP-155 chain; design actor and multichain replay domains only with cross-wallet test vectors.

### 18. Which accounting model should extensions standardize first?

Should recurring allowances, streams, call counts, attempted-versus-successful consumption, and balance-delta policies use stored counters, stateless proofs, or either? **Default:** define observable state transitions and rollback behavior per type, not a storage mechanism. Start with recurring allowance only after comparing period boundaries across EIP-8130, MetaMask, and Base.

### 19. Can ERC-8340 encoding machinery be reused safely?

Is deterministic CBOR or selective disclosure useful for authorization, or was ERC-8340 shared only as a companion-ERC layering example? **Default:** reuse a proven primitive only after security review and distinct domain separation. Never let descriptive metadata authorize a call, and never let selective disclosure hide a restriction from enforcement or wallet review.

## Suggested review order

Chris can unblock the work fastest by answering questions 1–5 and 8 first. A short joint review with Coinbase, MetaMask, Rhinestone/Biconomy, and ZeroDev can then test questions 6–7 and 9–13 against real integration constraints. Only after those answers should the project freeze canonical encoding or start formal ERC prose.
