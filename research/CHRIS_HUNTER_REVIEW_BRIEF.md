# Suggested answers for Chris Hunter review - 2 September 2026

## Executive summary

- Propose two distinct native EIP-8130 bindings, not one ambiguous binding. `eip8130-policy/1` should mean the external manager plus account trusted-executor path. `eip8130-inline/1` should mean `manager == account` with policy-aware account code. The current EIP permits both and calls its external-manager reference flow non-normative.
- On non-native chains, advertise the actual authentication, replay and account-execution route as a separate binding type. The most concrete current fallback is `eip8130-execute-for/1`. ERC-4337 and EIP-8141 routes need their own bindings and conformance tests. EIP-7702 is account-code installation, not a complete exercise binding by itself.
- Choose commitment option B. The companion ERC owns a transport-independent `semanticGrantHash`; `policy_commitment` should wrap that hash in an EIP-8130 binding domain covering the chain, account, actor, manager, evaluator and trusted account-execution configuration.
- Treat `SessionPolicy` as standards input and a test implementation, not as the portable ABI. V1 should standardise exact call scopes, explicit empty-calldata actions, finite validity and live revocation, while leaving all asset accounting as typed extensions.
- Support the typed ERC-7715 response `{ context, binding: { type, version, data } }`, with no dummy ERC-7710 fields. Chris's key confirmations are whether the proposed native manager path matches the implementation intent, whether `executeFor` is the preferred non-native starting point, and whether a wrapped semantic commitment is acceptable.

All names and wire shapes below are provisional pending Chris's review and, for ERC-7715 changes, review by the ERC-7715 and ERC-7710 authors. The evidence base is [FINDINGS.md](./FINDINGS.md), [POLICY-CAPABILITY-UNION.md](./POLICY-CAPABILITY-UNION.md), and [STANDARDS-SHAPE.md](./STANDARDS-SHAPE.md). Live primary sources were checked on 2 September 2026. The current [EIP-8130](https://eips.ethereum.org/EIPS/eip-8130) and the current canonical [EIP-8130 contracts](https://github.com/base/eip-8130/tree/d042296a89c234b0a9dbf40d4f21146d4c7054fa) are still moving and are not fully synchronised, so numeric scope values and ABI details must be version-pinned rather than copied into the semantic standard.

## Q1. Is the external manager plus trusted executor the standard EIP-8130 binding?

**Recommended**

Choose option C. Describe the two constructions as distinct advertised bindings, with `eip8130-policy/1` reserved for the external-manager plus trusted-executor route and `eip8130-inline/1` reserved for policy-aware account code where `manager == account`. Make only `eip8130-policy/1` a v1 reference binding until an inline implementation passes the same conformance vectors.

**Rationale**

EIP-8130 standardises a protocol gate to one manager, not the manager's policy vocabulary or its authority over the account. The current EIP explicitly permits `manager == account`, warns that ordinary self-trusting account code would make that route unrestricted, and labels its external-manager flow non-normative. The reference `PolicyManager` then calls the account, while `DefaultAccount` accepts that call only when the manager is registered as a live operational actor using `TRUSTED_EXECUTOR`. This is strong evidence for a concrete binding, but not evidence that the EIP mandates that account construction. See F-8130-01 to F-8130-03, [Actor Policies](https://eips.ethereum.org/EIPS/eip-8130#actor-policies), the current [`PolicyManager`](https://github.com/base/eip-8130/blob/d042296a89c234b0a9dbf40d4f21146d4c7054fa/src/policies/PolicyManager.sol), and [`DefaultAccount`](https://github.com/base/eip-8130/blob/d042296a89c234b0a9dbf40d4f21146d4c7054fa/src/accounts/DefaultAccount.sol).

**Concrete proposal**

- `eip8130-policy/1`: native EIP-8130 transaction; a secp256k1 actor is root-authorised with policy-only scope, `policy_manager = manager`, and the binding commitment; the manager is independently registered on the account as a live operational `TRUSTED_EXECUTOR`; exercise is account to manager to account to application.
- `eip8130-inline/1`: native EIP-8130 transaction; the actor is root-authorised with policy-only scope, `policy_manager = account`, and the binding commitment; pinned policy-aware account code authenticates the protocol actor, enforces the complete grant and performs the application `CALL`.
- Exact discovery tuples distinguish the two bindings. A wallet must not silently substitute one for the other.
- Both bindings return the complete semantic grant, reject unknown versions, permit one live binding for the grant ID, and produce application calls with the user's account as `msg.sender`.

**Tradeoffs / risks Chris might raise**

- The external route gives the manager broad account-driving power. It adds a hop and a second actor configuration, so the manager and account interface need careful code-identity and upgrade assumptions.
- The inline route is cheaper and removes a trusted executor, but it is tied to particular account code. A conventional self-call-capable `executeBatch` is unsafe for it.
- Two identifiers increase discovery and testing surface. One identifier with a mode field would be smaller, but would hide a material trust-boundary difference.

**Validate with Chris**

Yes/no: should the review define option C, with `eip8130-policy/1` for the reference external-manager construction and a separately advertised `eip8130-inline/1` for policy-aware account code?

**Impact**

- If accepted: native conformance can be precise without claiming the reference account architecture is mandated by EIP-8130.
- If rejected: choose A or B explicitly. A excludes safe inline accounts; B leaves the reference external-manager path without a stable portable name. Reusing one identifier for both would weaken exact-capability discovery and should not enter the baseline.

## Q2. What is the intended non-native path?

**Recommended**

Use distinct identifiers whenever actor authentication, replay protection, account trust or exercise routing changes. Do not define a generic "EIP-8130-compatible" non-native mode. For v1, make `eip8130-execute-for/1` the first non-native candidate because the current manager implements and tests it; keep ERC-4337 and EIP-8141 bindings provisional until their policy confinement and account-originated execution are demonstrated end to end.

**Rationale**

EIP-8130 says its accounts may use another transport such as ERC-4337 on non-native chains, but the native policy gate and transaction-context actor identity do not appear automatically in ERC-4337, EIP-7702 or EIP-8141. The current example `BackwardsCompatible4337Account` explicitly rejects a policy-only actor because it does not reproduce the native target gate. In contrast, the current `PolicyManager.executeFor` derives the actor from `msg.sender`, re-checks the actor, manager and commitment, and then drives the account through the trusted-executor path. See [EIP-8130 Portability](https://eips.ethereum.org/EIPS/eip-8130#portability), the current [ERC-4337 example account](https://github.com/base/eip-8130-examples/blob/9ce821d18bce42243e726149fd292026b9f6cb60/src/accounts/erc4337/BackwardsCompatible4337Account.sol), [ERC-4337](https://eips.ethereum.org/EIPS/eip-4337), [EIP-7702](https://eips.ethereum.org/EIPS/eip-7702), [EIP-8141](https://eips.ethereum.org/EIPS/eip-8141), and F-POLICY-06.

**Concrete proposal**

| Path | Root-authorised account configuration | Identifier and v1 treatment |
| --- | --- | --- |
| Native EIP-8130 external manager | Authorise the session actor with policy-only scope, exact manager and binding commitment. Register the manager as a live operational `TRUSTED_EXECUTOR` on the account. | `eip8130-policy/1`. V1 reference binding. |
| ERC-4337 account validation or hook | Install or select policy-aware account code. Trust one exact EntryPoint. Authorise the session actor in the Keystore. `validateUserOp` must recover the actor ID, require the policy lane, reject an unrestricted/operator lane, and force execution through the authenticated actor's manager or equivalent policy hook. The actor must not supply another actor ID in calldata. | `erc4337-eip8130-policy/1`. Separate from native. Provisional until an implementation reproduces the target gate, finite runtime validity, replay and revocation. The current reduced example is not conformant because it rejects policy actors rather than enforcing them. |
| EIP-7702 delegated account code | The root EOA authorises one exact delegated implementation. That code must implement the chosen session validation and account-execution path, and its removal or replacement must make the binding inactive without allowing a stale grant to revive on reinstall. | EIP-7702 alone is not a binding. If it only installs the account code used by ERC-4337, record `accountCode.mode = "eip7702"` inside `erc4337-eip8130-policy/1`. If it defines a distinct relay or validation path, use a separate `eip7702-forwarded-policy/1`. |
| `PolicyManager.executeFor` | Register the dapp's session address as a policy-only external caller using the reference external-policy authenticator sentinel, with the exact manager and binding commitment. Separately register the manager as a live operational `TRUSTED_EXECUTOR`. Never register the dapp actor itself as `TRUSTED_EXECUTOR`. | `eip8130-execute-for/1`. Separate from native because identity comes from `msg.sender`, replay comes from the outer transaction system, and there is no protocol target gate. Best current non-native candidate. |
| EIP-8141 account validation | Root-install policy-aware account code or a root-authorised frame-validator module. Validation must authenticate the session actor, bind the complete frame transaction, and ensure every authorised `SENDER` frame reaches the policy-consuming account entry point. Stateful use must be consumed in an execution hook with defined rollback, not only in read-only `VERIFY`. | `eip8141-account-validation/1`. Separate and provisional. Do not freeze it before complete-frame and state-consumption vectors pass against the current EIP and execution-specs revision. |
| Hybrid route | Root configuration must enumerate every trusted component and the one effective execution route. Shared counters and revocation must be proved, not assumed. | No generic hybrid identifier in v1. A concrete hybrid gets its own versioned binding only after its full trust, replay, status and revocation model is specified. |

Native and non-native exercise therefore use distinct binding identifiers. Installation technology may remain a discriminated field within a binding only when it does not change validation or exercise semantics. For example, a deployed ERC-4337 account and an EIP-7702 EOA running byte-identical ERC-4337 account code may share the ERC-4337 binding with distinct `accountCode.mode` values, provided reinstallation and code-identity tests are included.

**Tradeoffs / risks Chris might raise**

- More binding types create more adapters and capability entries.
- `executeFor` uses caller identity rather than a Keystore-authenticated transaction signature. It is suitable for one address actor, but it needs an explicit statement that this is the intended session actor model rather than only a subscription-provider example.
- Registering an EntryPoint or manager as `TRUSTED_EXECUTOR` is powerful and may be unacceptable to some account implementations.
- EIP-7702 code can be replaced independently of the session grant, so code status and stale-grant revival need explicit handling.
- EIP-8141 remains moving and may not yet support a stable binding test suite.

**Validate with Chris**

A/B: should the first non-native reference be A, `executeFor`, or B, a new ERC-4337 policy-aware account path? Separately, yes/no: should every non-native exercise route use a distinct binding identifier from `eip8130-policy/1`?

**Impact**

- If accepted: discovery states the exact security path, and conformance tests can verify account identity, replay and revocation per transport without changing the semantic grant.
- If rejected: putting all paths under `eip8130-policy/1` makes that identifier too weak to predict authentication or replay behaviour. Cross-path interoperability should then be removed from the v1 claim rather than hidden in `binding.data`.

## Q3. What should `policy_commitment` commit to?

**Recommended**

Choose option B. The semantic ERC should define `semanticGrantHash`; the EIP-8130 binding should set `policy_commitment` to a domain-separated `bindingCommitment` that includes `semanticGrantHash` and the selected enforcement context. Do not equate the current reference commitment with the portable grant ID, and do not leave the semantic hash only in wallet transport data.

**Rationale**

Option A binds portable meaning but not the code and route trusted to enforce it. Option C preserves the current ABI but does not prove onchain that the root-authorised policy is the structured grant the wallet returned. The reference commitment currently hashes the account, evaluator, configuration hash, validity and salt, while the EIP treats the commitment as opaque. This makes a nested semantic hash both compatible with the protocol model and stronger than a wallet-only mapping. See F-8130-01, F-8130-05, COMMIT-01, and [`PolicyManager.commitmentOf`](https://github.com/base/eip-8130/blob/d042296a89c234b0a9dbf40d4f21146d4c7054fa/src/policies/PolicyManager.sol).

**Concrete proposal**

Provisional conceptual hashes:

```text
semanticGrantHash = keccak256(
  canonicalSemanticEncoding(
    authorityDomain = "interop-session-grant",
    semanticCodecVersion,
    complete SessionGrant
  )
)

bindingCommitment = keccak256(abi.encode(
  keccak256("eip8130-policy/1"),
  semanticGrantHash,
  chainId,
  account,
  actorId,
  keystore,
  manager,
  evaluator,
  accountExecutionCodeIdentity,
  bindingSalt
))

policy_commitment = bindingCommitment
```

The complete `SessionGrant` includes the exact account, chain, address actor, finite validity interval, exact action alternatives, restriction types and all semantic type versions. It excludes wallet display labels and other descriptive metadata. The final codec and typehash are deferred, but these layers and fields should be normative.

To adapt the current reference manager, define `policyConfig` as a versioned binding preimage whose first authoritative field is `semanticGrantHash`, or revise `PolicyBinding` directly. Do not duplicate validity or identity fields across layers unless the binding requires it; if duplicated, equality is mandatory and a mismatch fails closed.

The root wallet signs the EIP-8130 actor change containing:

- the exact actor ID and authenticator;
- policy-only scope and finite actor expiry matching or narrowing the semantic validity;
- `manager || bindingCommitment` as the policy data;
- the account-change chain/replay domain and sequence or epoch; and
- where needed, the account-code and trusted-executor configuration in the same atomic setup or in prerequisites whose live state is verified before activation.

The Keystore stores the actor configuration, manager and `bindingCommitment`. The manager receives the complete binding preimage on each exercise, recomputes both hashes, checks live Keystore state, then invokes the evaluator. A stateless manager need store only mutable evaluator state, such as counters, keyed by `bindingCommitment`. With one live binding per grant, `semanticGrantHash` remains the portable grant ID and `bindingCommitment` remains the enforcement ID.

**Tradeoffs / risks Chris might raise**

- Including chain ID deliberately gives up the reference commitment's cross-chain portability. That is appropriate for the single-chain baseline, but multichain will need a new semantic profile or explicit chain-set domain.
- Binding code identity makes upgrades invalidate grants or requires a governance-aware identity. Omitting it makes an upgrade authority part of the hidden trust model.
- The wider preimage adds calldata and hashing work. The current reference shape is simpler.
- Chris may prefer the root signature over `manager || commitment` to bind the manager rather than including the manager again in `bindingCommitment`. Including it is redundant cryptographically but improves standalone reproducibility and prevents adapters from comparing only the 32-byte commitment out of context.

**Validate with Chris**

A/B: should `policy_commitment` be A, exactly the portable semantic hash, or B, a binding-domain wrapper around it? If B, yes/no: is including manager and account-code identity inside the wrapper acceptable even though the signed actor change also carries the manager?

**Impact**

- If accepted: the root signature, onchain actor state and exact wallet-returned grant are cryptographically connected, while the semantic ID remains transport-independent.
- If rejected in favour of A: the baseline needs a separate signed binding descriptor proving which code enforces the semantic hash.
- If rejected in favour of C: full conformance cannot claim that the onchain EIP-8130 commitment is the returned semantic grant until a normative adapter mapping and test vectors provide an equally strong link.

## Q4. Is `SessionPolicy` standards input or only an example?

**Recommended**

Treat `SessionPolicy` as standards input and an executable source of positive and negative test cases, but not as a canonical ABI. Promote only behaviours that match the minimal cross-framework semantics below. The current implementation's own warnings about approvals, unknown token methods and policy configuration reinforce this boundary.

**Rationale**

The reference combines unrelated behaviours because one manager hook evaluates one policy object, not because those behaviours have established portable meanings. Cross-framework evidence supports exact target-selector pairing, conjunctive restrictions and account self-call rejection. Asset accounting conflicts on charged amount, period, recipient, failure, reentrancy and standing approvals. See F-POLICY-01 to F-POLICY-04, F-POLICY-08, and the current [`SessionPolicy`](https://github.com/base/eip-8130/blob/d042296a89c234b0a9dbf40d4f21146d4c7054fa/src/policies/SessionPolicy.sol).

**Concrete proposal**

| Behaviour | Classification | Portable v1 rule |
| --- | --- | --- |
| Paired `(target, selectors[])` call scopes | Baseline candidate | Normalise to an OR of exact `(target, selector)` alternatives. Never flatten targets and selectors into independent sets. |
| Empty-selector wildcard or empty calldata implicitly allowed for every scoped target | Reject for portable profile | Define one explicit `(target, emptyCalldata)` action. It authorises exactly zero bytes. Reject 1 to 3 bytes. A named selector does not imply the empty action, and an empty selector array must not mean any selector. |
| Native value accounting, per-call or grant-lifetime | Typed extension | Use separately named types. Define charged value, batch aggregation, mutation point, reentrancy, revert and display. No native-value cap is mandatory in v1. |
| ERC-20 direct transfer totals | Typed extension | Limit to an exact token action and state whether the requested amount or observed balance delta is charged, including false returns, fee-on-transfer tokens, batches and rollback. |
| Recipient restrictions | Typed extension | Attach the recipient role to one exact decoded action. Do not reuse one generic recipient field for transfer recipient, spender, redeemer or submitter. |
| Approval and `transferFrom` authority | Typed extension | Use distinct high-risk types. Approval can outlive the session; `transferFrom` must bind source, owner, spender/actor, recipient and accounting. Neither is in v1 baseline. |
| Period or recurring limits | Typed extension | Define the time anchor, boundary rule, rollover, partial periods, accumulation, failure and rollback. Do not call this the same type as a lifetime total. |
| Account self-call rejection | Baseline candidate | Reject the account itself and account-administration entry points as application targets. No session action may reach a generic self-trusting batch executor. |
| Commitment-keyed state counters | Implementation-specific | The extension defines observable counter semantics. The binding defines storage keys and atomic mutation. Keying by the reference commitment is not portable meaning and does not permit a second live binding. |

The baseline remains ordinary `CALL` only. It excludes delegatecall, contract creation, approvals, NFTs, general message signing, usage counters, fallback actions and account administration.

**Tradeoffs / risks Chris might raise**

- A call-only baseline is less useful than the complete reference policy and may under-represent the intended EIP-8130 use cases.
- Explicit empty-calldata actions and exact 1 to 3 byte rejection require small adapter changes.
- Typed asset extensions create more identifiers and conformance work.
- Rejecting target-only wildcard scopes may make common app sessions verbose, but avoids an authority increase that is hard to display safely.

**Validate with Chris**

Yes/no: should `SessionPolicy` be cited as executable standards input while the portable v1 profile includes only exact call scopes, explicit empty calldata, self-call rejection and finite validity, with all asset behaviours moved to typed extensions?

**Impact**

- If accepted: v1 is small enough to implement consistently and `SessionPolicy` supplies valuable tests without becoming a de facto ABI.
- If rejected: making the whole `SessionPolicy` shape portable would require agreement on every asset and approval edge case before baseline publication. If Chris regards it as only an example with no standards intent, the cross-framework evidence still supports the same minimal baseline.

## Q5. What role should ERC-8340 play?

**Recommended**

Use ERC-8340 as layering precedent and as one codec candidate for later evaluation, not as a normative v1 encoding or commitment dependency. Its current commitment machinery is for inert transaction metadata and selectively disclosed offchain documents, not for enforceable session authority.

**Rationale**

The draft defines deterministic CBOR for EIP-8130 transaction metadata, plus a salted commitment and disclosure protocol. It also requires consumers not to infer execution effects from metadata and permits unknown keys to be ignored. Those are correct properties for annotations but wrong defaults for an authority object, where unknown required fields must fail closed and the commitment must survive independently of a particular exercise transaction. See draft [ERC-8340 PR 1883](https://github.com/ethereum/ERCs/pull/1883), COMMIT-U01, and F-8130-01.

**Concrete proposal**

- Layering precedent: yes. An EIP-8130 carrier can remain opaque while a companion ERC defines interoperable meaning. The same separation should apply to ERC-7715 transport, the semantic session ERC and each enforcement binding.
- Encoding primitive: investigate deterministic CBOR beside EIP-712-style encoding only after the grant schema and type-version rules stabilise. Reuse would require a closed session-specific schema, canonical collection ordering, explicit version tags and rejection of unknown required fields.
- Commitment primitive: do not reuse ERC-8340's `commit(value)` directly. Define an authority-specific domain separator and the two-layer hashes in Q3. No salt intended for selective disclosure may change the semantic grant ID.
- Metadata: wallets may include a descriptive grant reference or attribution in ERC-8340 metadata, but it is non-authoritative. The manager and wallet must derive authority from the signed semantic and binding commitments, never from transaction metadata or display strings.
- V1 dependency: none. Keep the canonical semantic codec explicitly TBD pending implementer review.

**Tradeoffs / risks Chris might raise**

- Deferring CBOR loses an available deterministic encoding and delays cross-language test vectors.
- Selecting a different codec may duplicate canonicalisation work.
- Adopting ERC-8340 now would reduce codec choices, but would couple authority to a young metadata draft whose unknown-key and disclosure rules serve a different threat model.

**Validate with Chris**

A/B: was ERC-8340 shared primarily as A, companion-layering precedent and possible codec input, or B, intended commitment machinery for session grants? If B, which exact subset should be profiled with a separate authority domain?

**Impact**

- If accepted: v1 can agree the security layering without prematurely fixing a codec or making descriptive metadata authoritative.
- If rejected: the baseline should pause hash finalisation until an authority-safe ERC-8340 profile defines closed-schema parsing, domain separation, canonical ordering and fail-closed version behaviour.

## Additional question. Typed ERC-7715 binding response

**Recommended**

Support the typed response for `interop-session-grant` and do not return dummy `delegationManager` or `dependencies` fields. Use mutually exclusive response variants and require explicit request-time binding negotiation. Keep `context` as the stable wallet grant and revocation handle, but never as the only source of policy meaning.

**Rationale**

Current ERC-7715 requires an ERC-7710 manager, ERC-4337 deployment dependencies and ERC-7710 redemption. A native EIP-8130 manager or inline account is not truthfully represented by those fields. ERC-7715 already expects companion ERCs to define permission types, while the complete granted object is needed for comparison, display and exercise. The remaining compatibility blocker is its unfiltered list method, which promises every live grant in the legacy shape. See F-7715-01 to F-7715-07, [ERC-7715](https://eips.ethereum.org/EIPS/eip-7715), and [STANDARDS-SHAPE.md](./STANDARDS-SHAPE.md#field-level-erc-7715-straw-man).

**Concrete proposal**

```typescript
type BoundPermissionResponse = {
  chainId: Hex;
  from: Address;
  to: Address;
  permission: {
    type: "interop-session-grant";
    isAdjustmentAllowed: boolean;
    data: GrantedSessionBody;       // complete structured semantics
  };
  rules?: never;
  responseBindings: BindingPair[];  // repeated unchanged from request
  context: Hex;                     // stable wallet handle
  binding: {
    type: "eip8130-policy";
    version: "1";
    data: Eip8130PolicyBindingV1;
  };
};
```

The legacy response retains `delegationManager` and `dependencies` exactly as today and has no `binding`. The bound response has `binding` and has neither legacy field. Mixed shapes, unknown type-version pairs, unadvertised tuples and top-level/body duplication fail closed.

Provisional minimal `Eip8130PolicyBindingV1`:

```typescript
type Eip8130PolicyBindingV1 = {
  specRevision: Hex32;              // reviewed EIP/contracts revision or profile ID
  keystore: Address;

  actor: {
    actorId: Hex32;
    authenticator: Address;
    scope: Hex;                     // exact installed bits, not only a label
    expiry: Hex;                    // exact installed endpoint
  };

  policy: {
    manager: Address;
    managerCodeHash: Hex32;
    evaluator: Address;
    evaluatorCodeHash: Hex32;
    semanticGrantHash: Hex32;
    policyCommitment: Hex32;
    bindingPreimage: Hex;           // canonical manager input needed to recompute
  };

  accountExecution: {
    mode: "trusted-executor";
    accountCodeMode: "native-default" | "deployed" | "eip7702";
    accountCodeIdentity: Hex32;
    managerActorId: Hex32;
    trustedExecutorAuthenticator: Address;
    requiredScope: Hex;
  };

  installation:
    | {
        state: "applied";
        transactionHash: Hex32;
        blockHash: Hex32;
      }
    | {
        state: "submit";
        format: "eip8130-account-changes/1";
        actorChange: Hex;
        managerExecutorChange?: Hex;
        signedChangeBundle: Hex;
      };

  exercise: {
    target: Address;                // manager
    entrypoint: Hex4;               // execute(...)
    encoding: "eip8130-policy-execute/1";
  };

  status: {
    type: "eip8130-policy-status/1";
    actorQuery: Hex;
    executorQuery: Hex;
  };

  revoke: {
    type: "eip8130-revoke-actor/1";
    actorId: Hex32;
    changePayload: Hex;
  };
};
```

The `installation` union avoids returning meaningless install calldata after the configuration is already live. A past receipt is evidence of installation, not proof of current authority. Current activity must be derived from live state queries. A wallet may keep raw submission material in `context` if it does not need to be interpreted by the dapp, but all fields needed to identify and verify the selected binding remain structured.

`binding.data` must not repeat the semantic policies. It carries only the mechanism-specific identities, preimage, installation or receipt, exercise encoder, and status/revocation routes. `chainId`, account and address actor remain authoritative in the outer response and reconstructed semantic grant; any repeated binding values must match exactly.

**Tradeoffs / risks Chris might raise**

- The descriptor is larger than an opaque context and exposes implementation details that may change.
- Code hashes make upgrades explicit but can invalidate otherwise functioning grants. Profile IDs backed by conformance vectors may be preferable for governed proxies.
- Returning signed installation material to the dapp changes who may submit it. The wallet may prefer to submit and return only a receipt.
- ERC-7715 authors may reject the response union or require a successor RPC because the current list method has no version filter.

**Validate with Chris**

Yes/no: would the EIP-8130 implementation support this typed response boundary, with a structured binding descriptor, no fake ERC-7710 fields and a live status query instead of a static trusted-executor proof?

**Impact**

- If accepted: option 3 remains viable, subject to ERC-7715 author agreement on exact discovery, response discrimination and legacy-safe listing.
- If rejected: either EIP-8130 must truthfully implement ERC-7710 redemption, or the session proposal needs a versioned successor to ERC-7715. Opaque `context` plus dummy legacy fields is not an acceptable fallback.

## Proposed binding spec sketch: `eip8130-policy/1`

### Scope and invariants

The binding supports one existing account on one EIP-155 chain, one secp256k1 address actor, finite timestamp validity, OR over exact `(target, selector)` and explicit empty-calldata alternatives, AND across restrictions on one action, and ordinary account `CALL` only. It excludes account self-calls, delegatecall, create, administration, message signing, redelegation and asset limits unless separately typed extensions are negotiated.

One `semanticGrantHash` has at most one live binding. Unknown semantic or binding types and versions fail during discovery, approval, import, installation, listing, status and exercise. The wallet returns and displays the complete effective grant.

### Minimal fields

- Semantic reference: `semanticGrantHash`, semantic profile and codec versions in `permission.data`.
- Actor: exact actor ID, authenticator, installed scope and expiry.
- Enforcement: Keystore, manager, evaluator, their immutable code identities or explicit governance profile, `bindingCommitment`, and the full manager binding preimage.
- Account path: account code identity, manager trusted-executor actor ID, authenticator and operational scope.
- Operations: typed installation or confirmed receipt, exercise target and encoder, live status queries, and root revocation payload.
- Revision: exact EIP-8130 and canonical-contract revision used by the adapter. This is required while prose and contract constants are changing.

### Install flow

1. The wallet resolves `chainId`, account and actor and confirms the exact chain-profile-actor-extension-binding tuple is advertised.
2. It validates the complete semantic grant, renders every authoritative field, obtains root approval and computes `semanticGrantHash`.
3. It resolves pinned manager, evaluator and account-execution identities, then computes `bindingCommitment`.
4. The root authorises the session actor with policy-only scope, finite expiry, manager and `bindingCommitment`. If not already configured, the root separately registers the manager as a live operational `TRUSTED_EXECUTOR`. These changes should be atomic where the account-change mechanism permits it.
5. The wallet checks live state. It must not report the binding active until the actor, manager, commitment, expiry, account code and trusted-executor path all match.
6. The wallet records `context -> exact grant + one binding`, then returns the complete grant and typed descriptor. A changed grant is either a provably equal-or-narrower result for a fully defined type or an explicit counter-offer, never an implicit widening.

### Exercise flow

1. The dapp constructs one allowed action and encodes `PolicyManager.execute(bindingPreimage, executionData)`.
2. The session key signs a native EIP-8130 transaction for the user's account. Its only application-phase target is the selected manager.
3. Protocol authentication resolves the actor, checks expiry and gates every call to the manager.
4. The manager derives the actor from transaction context, recomputes `bindingCommitment`, compares it with live Keystore state and invokes the evaluator.
5. The evaluator reconstructs or checks `semanticGrantHash`, rejects unknown versions, rejects account self-calls and enforces the exact action and every applicable restriction.
6. The manager calls the account's pinned execution entry point as the registered trusted executor. The account performs an ordinary `CALL`, so the application observes the user's account as `msg.sender`.
7. Any stateful extension consumes state with specified pre-call, reentrancy, failure and rollback rules. V1 baseline has no stateful asset or usage extension.

### Revocation flow

1. The root requests revocation using the stable ERC-7715 `context`.
2. The wallet submits a root-authorised `RevokeActor` for the session actor. Removing the shared manager trusted-executor registration is not the grant-specific revocation operation.
3. Status is `revocation-pending` until the binding-specific effectiveness rule is met. Local key deletion or cancellation of an unused signed change is not live revocation.
4. Once the live actor no longer resolves, exercise fails before or at the manager. Stale evaluator counters may remain but confer no authority.
5. Expiry, effective revocation and local epoch cancellation remain separately reported lifecycle events.

### Status model

Use one lifecycle state plus a separate finality field:

- `install-pending`: exact grant approved, binding not yet live.
- `active`: all actor, commitment, manager, evaluator, account-code and trusted-executor checks pass and time is within the semantic interval.
- `expired`: the committed interval or actor expiry has elapsed without a live revoke.
- `revocation-pending`: a revoke was submitted but is not yet effective by the selected finality rule.
- `revoked`: the root-controlled live actor authorisation is absent or explicitly revoked.
- `misconfigured`: a required implementation, code identity or trusted-executor dependency no longer matches.
- `failed`: installation or revocation failed and no replacement is pending.

`finality` should be one of `unsubmitted`, `pending`, `confirmed`, `finalised`, or `reorged`, with the chain-specific confirmation evidence. Exercise is permitted only in `active`. A wallet must not infer `revoked` merely because it removed the grant from local storage.

Where a Keystore read resolves both an expired actor and a revoked actor to zero, the wallet combines the committed expiry with event or transaction evidence. It reports `revoked` only for an observed root revoke, and otherwise reports `expired` once the endpoint passes. The two lifecycle events remain distinct even when both make exercise fail.

## Proposed commitment layering

```text
Complete structured SessionGrant
  |  canonical semantic codec + "interop-session-grant" authority domain
  v
semanticGrantHash                         portable grant ID
  |  + chain + account + actor + Keystore
  |  + manager + evaluator + code identity
  |  + "eip8130-policy/1" + binding salt
  v
bindingCommitment == policy_commitment   enforcement ID
  |  included with manager in root-signed AuthorizeActor change
  v
Keystore live actor state                source of install, expiry and revoke truth
  |  checked on every exercise
  v
manager -> evaluator -> account CALL     application sees the user's account
```

The root signature authorises the binding, not merely the descriptive presentation. The wallet presentation and ERC-7715 response return the exact semantic preimage. The manager or evaluator receives the binding preimage and checks both hashes. Transaction metadata may refer to either hash, but never becomes an authority source.

## Open disagreements we'd defer

- **Canonical semantic codec:** EIP-712-style encoding, a closed deterministic-CBOR profile, or another canonical codec. Decide after the semantic object and version rules stabilise, then publish cross-language positive and negative vectors.
- **Code identity and upgrades:** exact code hash, immutable deployment identity, implementation slot plus governance assumptions, or conformance-profile identifier. Evidence needed: realistic manager, evaluator and account upgrades that do not widen a live grant.
- **ERC-7715 listing and revocation wire:** versioned list method versus filter/version parameter, and generic versus binding-routed status. ERC-7715 authors must decide whether option 3 can preserve legacy clients.
- **ERC-4337 policy confinement:** account-side policy hook versus an attested actor route into the manager. Evidence needed: an implementation showing the actor cannot select a more privileged identity or bypass the manager.
- **EIP-8141 binding:** complete `SENDER` frame inspection, persistent state consumption, rollback and EIP-7702 installation. Freeze only against a stable specification and execution-specs test revision.
- **Asset extensions:** native value, direct ERC-20 totals, recipients, approvals and periods. Promote only after implementations agree the charged unit, mutation point, reentrancy, failure, batch and display semantics.

## Questions we'd still ask Chris

1. The 2 September EIP text and the 1 September canonical contract revision use different scope assignments and composition language. Which exact revision should binding authors treat as authoritative, and should every binding advertise both a prose-spec revision and canonical-contract commit?
2. Is `PolicyManager.executeFor` intended as a supported address-session-key route for dapps, or specifically as a subscription-provider pattern? If it is general, is it the preferred first non-native binding?
3. Is the manager's `TRUSTED_EXECUTOR` authority intentionally shared at account level across all of its policy bindings, or is a grant-local executor capability planned? What immutability or upgrade governance is expected for that manager?
4. Is supplying the complete `PolicyBinding` preimage on every exercise an intended stable property, with the manager storing only usage state, or should an interoperable binding assume an installation record and shorter execution context?
