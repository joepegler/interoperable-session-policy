# Standards Shape for Interoperable Session Permissions

## Status

This is an evidence-backed recommendation for review. It is not an ERC draft, an upstream diff, or implementer consensus. Field names are concrete enough to assess compatibility but remain provisional until ERC-7715 authors respond.

The evidence identifiers below refer to [`FINDINGS.md`](./FINDINGS.md).

## Decision

Recommend **option 3: a companion semantic ERC plus a narrow ERC-7715 generalisation intended to be backwards-compatible** as the preferred review direction.

The companion ERC would define what a session grant means. ERC-7715 would remain the wallet-facing request, approval, discovery, listing, and revocation transport. Its generalisation would add explicit binding negotiation, an exact-capability discovery shape, a typed non-ERC-7710 response, and a legacy-safe way to list grants without fake `delegationManager` or factory fields.

Backwards compatibility is not yet proven. Three conditions must all hold: legacy ERC-7710 responses remain valid with exactly their current fields and meaning; a bound response is returned only after the dapp explicitly negotiates an advertised exact binding configuration; and the unfiltered legacy list method never exposes a bound response to an old client. The third condition is a current blocker because `wallet_getGrantedExecutionPermissions` must return every live grant and has no filter (F-7715-05). If a versioned or filtered listing extension cannot preserve old clients, the fallback is option 4, a versioned successor.

## Why the decision is needed

ERC-7715 is already designed for permission types defined by other ERCs (F-7715-01), so its request can carry a complete session-grant request. Its response is not enforcement-neutral: it requires ERC-4337 deployment dependencies and an ERC-7710 Delegation Manager and prescribes ERC-7710 redemption (F-7715-02).

The mismatch cannot be solved by putting more opaque data in `context`. A dapp and wallet need the same inspectable semantic grant, while the binding may still need opaque proofs or calldata. Policy meaning and binding context have different responsibilities.

The response coupling was introduced deliberately in a January 2026 simplification (F-7715-07). Reopening it therefore needs explicit author review and implementation evidence; it must not be described as a trivial schema addition.

## Options

### Option 1: amend ERC-7715 only

ERC-7715 would define the canonical session vocabulary, encoding, commitment, conformance model, extensions, and every binding in addition to its RPC methods.

**Advantage:** one document and one visible wallet API.

**Problems:**

- It makes a wallet request standard also own security-critical policy semantics and EVM execution bindings.
- Changes to policy or binding semantics would force changes to the transport standard.
- It would make ERC-7715 substantially larger while its existing permission-type mechanism already delegates vocabulary to companion ERCs.
- It makes reuse through a non-ERC-7715 transport harder.

**Conclusion:** reject. Request transport and enforceable authority are independently reusable layers.

### Option 2: companion semantic ERC, ERC-7715 unchanged

A companion ERC would define the grant and one ERC-7715 permission type. Every response would still contain the current `context`, `dependencies`, and `delegationManager` fields and redeem through ERC-7710.

**Advantage:** no ERC-7715 text change.

**Problems:**

- Native EIP-8130 and EIP-8141 validation paths are not inherently ERC-7710 managers.
- Requiring them to implement ERC-7710 changes their execution integration and atomic batch contract.
- Returning dummy deployment or manager values would violate the response's documented meaning.
- A dapp could not discover the actual profile, extension, and binding versions through current discovery.

**Conclusion:** reject unless every intended binding voluntarily and truthfully converges on ERC-7710. Current evidence does not support that premise.

### Option 3: companion semantic ERC plus narrow ERC-7715 generalisation

The companion ERC owns the semantic grant and defines one ERC-7715 permission type. ERC-7715 gains exact binding negotiation, a versioned binding descriptor, tuple-based discovery, and legacy-safe listing for new permission types while retaining the legacy ERC-7710 response.

**Advantages:**

- reuses the current wallet-facing methods and permission-type extension point;
- keeps the semantic object usable through other transports;
- can preserve existing ERC-7710 responses and request-time clients;
- makes EIP-8130, EIP-8141, ERC-4337/EIP-7702, and ERC-7710 honest alternative bindings; and
- lets a dapp reject unsupported chain, profile, actor, extension, and binding combinations before asking the user.

**Costs:**

- ERC-7715 clients and wallets need request negotiation, response, discovery, and listing updates for new binding types;
- authors must agree how the response union is discriminated; and
- the existing unfiltered list method needs a legacy-safe version or filter; and
- a new permission ERC and an ERC-7715 change need coordinated review.

**Conclusion:** recommend as the preferred direction for discussion, conditional on resolving the listing blocker and the other rejection conditions below.

### Option 4: versioned ERC-7715 successor

A new RPC or explicit v2 response would replace the current response assumptions and make the binding descriptor mandatory.

**Advantages:** clean schema, explicit version negotiation, and no ambiguous optional fields.

**Costs:** duplicate methods or migration, fragmented wallet support, greater dapp burden, and less reuse of existing ERC-7715 methods and tooling. Current evidence does not establish broad cross-wallet ERC-7715 deployment.

**Conclusion:** keep as fallback if option 3 cannot keep bound variants out of legacy request and list paths, or if its negotiation and capability tuples cannot be made unambiguous.

## Comparison matrix

Scores are relative: **strong**, **mixed**, or **weak**.

| Criterion | 1. ERC-7715 only | 2. Companion only | 3. Companion plus generalisation | 4. Successor |
| --- | --- | --- | --- | --- |
| Backwards compatibility | Mixed | Strong superficially, weak for truthful non-7710 use | Mixed until legacy-safe listing is agreed | Weak to mixed |
| Separation of layers | Weak | Strong | Strong | Strong |
| EIP and transport independence | Weak | Mixed because response stays ERC-7710-bound | Strong | Strong |
| Wallet implementation burden | High, one large standard | High for non-7710 adapters | Moderate and explicit | High during migration |
| Dapp interoperability | Mixed | Weak outside ERC-7710 | Strong if exact negotiation and listing are solved | Mixed until adoption |
| Deterministic semantic ownership | Ambiguous | Strong | Strong | Strong |
| Enforcement clarity | Mixed | Weak for non-7710 | Strong through typed bindings | Strong |
| Extension and versioning safety | Mixed | Strong in companion, weak discovery | Strong | Strong |
| Discoverability | Requires large ERC-7715 change | Insufficient unchanged | Strong with exact supported tuples | Clean but new |
| Testability | Mixed | Mixed | Strong layer-specific suites | Strong but duplicated |
| Adoption likelihood | Low to mixed | Mixed | Mixed; reuses tooling but deployment breadth is unproven | Low to mixed |

## Responsibility boundary

### Companion session-policy ERC

The companion ERC should eventually define:

- canonical requested and granted semantic objects;
- profile, actor, policy, extension, and version identifiers;
- exact policy meaning, applicability, composition, accounting, and failure rules;
- deterministic encoding and semantic commitment;
- request-to-grant equality and safe narrowing;
- wallet presentation data and unknown-type rejection;
- conformance roles; and
- normative mappings to supported wallet transports and enforcement bindings.

It must not define ERC-4337, EIP-8141, EIP-8130, or wallet-specific transaction envelopes, root authentication, account deployment, or one mandatory policy manager.

### ERC-7715

ERC-7715 should continue to define:

- wallet RPC methods;
- top-level account, session-account, and chain selection;
- request, response, discovery, listing, and revocation transport;
- generic permission and rule extension points; and
- generic transport errors.

The generalisation should define how a request negotiates acceptable response bindings, how a response identifies its selected enforcement binding, how discovery advertises exact supported configurations, and how old listing clients avoid new variants. It should also let a permission-type ERC define that type's adjustment relation while retaining existing behaviour for legacy types. ERC-7715 should not duplicate the session-policy vocabulary.

### Binding definitions

Each binding should define:

- how the session actor authenticates;
- what root-authorised action installs or authorises the grant;
- how the semantic commitment is bound to manager, module, or account code;
- where counters and revocation state live;
- how single calls and supported batches are presented and evaluated;
- how calls execute as the user's account;
- how exercise, status, expiry, replay, and revocation fail; and
- what account or protocol cooperation is required.

Bindings may have different calldata and storage. They may not change the semantic grant.

## Field-level ERC-7715 straw man

### Extend the request only for typed bindings

Retain the existing `PermissionRequest` fields, define one companion permission type provisionally named `interop-session-grant`, and add explicit binding negotiation for requests that can return a bound response.

```text
BoundPermissionRequest = PermissionRequest & {
  chainId
  from?
  to
  permission {
    type: "interop-session-grant"
    isAdjustmentAllowed
    data: RequestedSessionBody
  }
  rules: absent
  responseBindings: { type: string, version: string }[]
}
```

The transport mapping avoids duplicate sources of truth. The canonical requested or granted `SessionGrant` is reconstructed from authoritative outer fields plus `permission.data`: `chainId` supplies the chain, resolved `from` supplies the account, `to` supplies the address actor, and `RequestedSessionBody` supplies profile, validity, salt, policies, and extensions. The body must not repeat chain, account, or actor.

The companion type and ERC-7715 binding must later define these invariants:

- `from` may be omitted in a request for wallet selection but is required in every response;
- outer `chainId`, resolved `from`, and `to` are the only wire authorities for chain, account, and the baseline address actor;
- `responseBindings` is non-empty and contains only exact type-version pairs from one advertised supported configuration;
- the response carries the complete granted object, not a delta;
- `rules` is absent or empty because all session restrictions live inside the companion semantic body;
- the session grant is the sole element in the request array until cross-entry atomicity and composition are defined; and
- adjustment means equal-or-narrower only for this permission type (F-7715-04).

Making the last rule effective requires an ERC-7715 normative change: a permission-type ERC may define its own adjustment relation, while types without one retain the current base behaviour. If authors reject that override, the session request must set `isAdjustmentAllowed: false` and any changed result must use a separate counter-offer flow. The request and grant body schemas remain post-review work.

### Preserve the legacy response

The existing response remains valid and unchanged:

```text
LegacyERC7710PermissionResponse = PermissionRequest & {
  context: Hex
  dependencies: { factory: Address, factoryData: Hex }[]
  delegationManager: Address
}
```

Its normative behaviour remains ERC-7710 redemption. No field, meaning, or redemption rule in a legacy response changes.

### Add a binding-discriminated response

For a permission type that advertises typed-binding support, add this alternative:

```text
BoundPermissionResponse = Omit<BoundPermissionRequest, "from"> & {
  from: Address
  context: Hex
  binding: {
    type: string
    version: string
    data: Record<string, unknown>
  }
}

PermissionResponse =
  | LegacyERC7710PermissionResponse
  | BoundPermissionResponse
```

Normative behaviour:

1. The two variants are mutually exclusive. A bound response contains `binding` and no `delegationManager` or `dependencies`; a legacy response contains the two legacy fields and no `binding` or `responseBindings`. Any mixed shape is invalid.
2. `binding.type` and `binding.version` select an ERC-defined binding schema. Unknown values fail closed.
3. `binding.data` contains mechanism-specific deployment, exercise, status-query, and revocation data. It is not the canonical permission and malformed data for a known binding is rejected.
4. `context` remains the stable wallet grant/revocation handle and may carry opaque binding proof. The complete canonical authority is reconstructible from resolved outer fields and returned `permission.data`.
5. An ERC-7710 binding may continue to use the legacy response. A future typed ERC-7710 binding may be added only with explicit compatibility rules.
6. A wallet returns a bound response only when its exact binding pair was included in `responseBindings` and the complete chain-profile-actor-extension-binding configuration was advertised.
7. The response repeats `responseBindings` unchanged, resolves `from`, and returns the complete granted semantic body. It does not silently substitute chain, account, or actor.
8. A dapp rejects a mixed variant, absent `from`, malformed known binding data, an unadvertised configuration, a binding not negotiated in the request, any top-level/body duplication or mismatch, an unknown required type, or a semantically broader or substituted grant.
9. A wallet rejects a session request with external `rules` or another request-array element until the companion standard defines their composition and atomic approval.

Possible binding types include `erc7710/1`, `eip8130-policy/1`, `eip8141-account-validation/1`, and `erc4337-account-validation/1`. These are working identifiers, not allocated names.

### Extend discovery additively

Independent lists of chains, profiles, actors, extensions, and bindings would imply unsupported Cartesian products. For permission types that need nested discovery, extend the existing per-permission result with exact supported configurations:

```text
{
  chainIds: Hex[]
  ruleTypes: string[]
  supportedConfigurations?: {
    chainId: Hex
    profile: { type: string, version: string }
    actor: { type: string, version: string }
    extensions: { type: string, version: string }[]
    binding: { type: string, version: string }
  }[]
}
```

Legacy permission entries may omit `supportedConfigurations`. The companion session permission requires it and uses an empty `ruleTypes` list. Each entry represents one complete supported tuple, including the exact extension set; wallets list multiple entries rather than implying independent mix-and-match support. A wallet must not advertise an entry unless it supports every mandatory semantic and the complete binding on that chain.

### Listing and revocation

The current list method is an ambient compatibility blocker: it has no parameters and must return every non-revoked grant (F-7715-05). The preferred option 3 resolution is an additive versioned list method, provisionally `wallet_getGrantedExecutionPermissionsV2`, that can return bound variants, paired with an amendment that confines the legacy method to legacy response shapes. An explicit response-version parameter with a legacy default is another design to assess. If authors consider either behaviour incompatible with the current promise to return all grants, use option 4.

The versioned listing path returns the same response variant originally granted, including resolved outer fields, the complete granted semantic body, and the binding descriptor. A legacy listing call must never receive a bound response.

`wallet_revokeExecutionPermission` can retain its `permissionContext` request and use stored binding data to start root-controlled revocation, but its current success result is internally inconsistent and it has no status method (F-7715-06). The next draft must choose one of these models:

- wait for binding-specific effectiveness and return a defined effective result;
- return a defined pending result plus a generic status method; or
- identify a binding-specific status query in `binding.data` and define how the wallet reports pending, effective, failed, and finalised states.

Merely hiding the grant, deleting a local key, or cancelling an unused authorisation must never be represented as effective live revocation. Exact result and finality semantics remain an open design decision, not a property of current ERC-7715.

## Backwards compatibility and migration

1. Existing ERC-7710 request and response shapes remain unchanged.
2. A new dapp discovers an exact supported configuration, includes acceptable binding pairs in its request, and validates the selected response against both.
3. An existing request-time client does not request the new companion permission and therefore does not receive a bound response from that request.
4. The existing unfiltered list method is not safe as written. Bound grants require a versioned or filtered listing path whose legacy default cannot return the new variant.
5. Unknown permissions, configurations, bindings, and required content fail rather than falling back to legacy redemption.
6. The companion permission either receives a type-specific narrowing rule in ERC-7715 or disables base adjustment and uses a separate counter-offer flow.
7. If authors or existing consumers cannot accept the response and listing separation without violating current ERC-7715 guarantees, use an explicitly versioned successor. Do not weaken the structural discriminant, hide dummy fields, or make legacy fields meaningless.

## Why opaque context is retained but limited

Binding proofs, nonces, deployment instructions, and calldata can remain opaque to a dapp that understands the selected binding encoder. The effective policy cannot. The complete canonical granted object must be reconstructible from the resolved outer fields and structured `permission.data`, and its commitment must be reproducible independently of `context`.

This boundary preserves implementation flexibility without treating opaque bytes as semantic interoperability.

## Questions for Chris Hunter

1. Is the external `PolicyManager` plus separately registered trusted executor intended as the common EIP-8130 account path, or only one reference account construction?
2. Should native and non-native EIP-8130 exercise use distinct binding types?
3. Should `policy_commitment` equal a semantic grant ID, wrap it, or commit to manager-specific configuration containing it?
4. Would EIP-8130 implementers support the typed binding response above rather than an ERC-7710 compatibility shim?
5. Is ERC-8340 relevant as an encoding primitive or only as a companion-ERC layering precedent?

## Questions for ERC-7715 and ERC-7710 authors

1. Can a legacy response remain unchanged while a bound variant is returned only after explicit binding negotiation?
2. How can the no-parameter legacy list method avoid returning bound variants while honouring its current promise to return all live grants: a new list method, an optional version/filter with a legacy default, or only a successor RPC?
3. Should `context` remain the common revocation handle for non-ERC-7710 bindings?
4. Is an array of exact chain-profile-actor-extension-binding configurations acceptable discovery, or is a permission-type-namespaced capability object preferable?
5. May a permission-type ERC define equal-or-narrower adjustment while legacy types retain the current base behaviour?
6. Must all permission responses remain redeemable through ERC-7710, and how should the January 2026 response simplification inform that decision?
7. Should revocation wait for onchain effectiveness, return a pending result plus status, or route status through the binding descriptor?
8. Would authors prefer an explicitly versioned successor rather than the request, response, discovery, and listing changes required by option 3?

## Discussion sequence

1. Joe reviews the evidence, boundaries, and field straw man internally.
2. Chris reviews EIP-8130 source interpretation, commitment layering, and binding feasibility.
3. ERC-7715 and ERC-7710 authors assess the response union, discovery, revocation, and compatibility claim.
4. Coinbase, MetaMask, Rhinestone/Biconomy, ZeroDev, and EIP-8141 implementers test the candidate baseline and bindings against real integration constraints.
5. The repository records responses and revises the recommendation.
6. Only after agreement, open an Ethereum Magicians discussion for the semantic proposal and any ERC-7715 change.
7. Do not open an upstream ERC pull request or request a number until public discussion and semantic conformance vectors exist.
