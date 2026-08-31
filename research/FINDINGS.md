# Findings and Conflict Ledger

## How to read this file

Each finding has a stable identifier and one classification:

- **Specification**: a requirement in a pinned EIP or ERC.
- **Implementation**: behaviour of a pinned implementation or test.
- **Inference**: a conclusion derived from identified primary evidence.
- **Recommendation**: a proposed standards decision.
- **Unresolved**: evidence or implementer intent is insufficient.

When sources differ, the finding names the conflict and the source used for the present conclusion. Source metadata and the research cutoff are in [`SOURCES.md`](./SOURCES.md).

## Wallet request and standards boundary

### F-7715-01: ERC-7715 is intentionally extensible at the permission-type layer

**Classification:** Specification.

ERC-7715 defines generic `BasePermission` and `BaseRule` objects and expects additional ERCs to define unique type names and data shapes. A complete session grant can therefore be investigated as one new permission type without first changing the request envelope.

**Evidence:** [`Permission Types, Rule Types`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7715.md#permission-types-rule-types) and [`PermissionRequest`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7715.md#request-specification).

**Limit:** This establishes request extensibility only. It does not establish that the response or redemption model supports multiple enforcement systems.

### F-7715-02: The current response is coupled to ERC-4337 deployment data and ERC-7710 redemption

**Classification:** Specification.

Every current `PermissionResponse` requires `context`, `dependencies`, and `delegationManager`. The text makes `dependencies` use ERC-4337 factory fields, requires `delegationManager` under ERC-7710, and instructs the dapp to redeem through `redeemDelegations`.

**Evidence:** [`PermissionResponse`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7715.md#response-specification) and [`Sending transaction to redeem permissions`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7715.md#sending-transaction-to-redeem-permissions).

**Consequence:** An EIP-8130 manager or EIP-8141 validator cannot be labelled an ERC-7710 Delegation Manager unless it implements that interface and its execution semantics. Dummy manager or factory values would be false interoperability.

### F-7715-03: Current discovery cannot express nested profile and binding support

**Classification:** Specification.

`wallet_getSupportedExecutionPermissions` reports top-level permission names, chain IDs, and compatible rule names. It has no standard field for profile versions, policy-extension versions, actor types, or enforcement binding versions.

**Evidence:** [`wallet_getSupportedExecutionPermissions`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7715.md#wallet_getsupportedexecutionpermissions).

**Resolution for this milestone:** The standards-shape proposal includes additive, permission-type-specific capability metadata. The exact final wire name remains for ERC-7715 author review.

### F-7715-04: ERC-7715 uses attenuation language that includes increases

**Classification:** Specification.

ERC-7715 says `isAdjustmentAllowed` permits a wallet to attenuate by reducing or increasing authority. An increase is not attenuation under a security partial order and cannot be accepted silently by a dapp that requested a maximum grant.

**Evidence:** [`BasePermission`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7715.md#permissions).

**Recommendation:** A session permission type must define its own adjustment rule as equal-or-narrower only. A wider or substituted result is a new counter-offer requiring explicit dapp and user handling.

### F-7715-05: Discovery gating does not protect legacy clients of the unfiltered list method

**Classification:** Specification and inference.

`wallet_getGrantedExecutionPermissions` accepts no filter or response-version parameter and requires the wallet to return all granted permissions that are not revoked. A legacy client can therefore encounter a new bound response after another client creates that grant, even if the legacy client never requested or discovered the new permission type.

**Evidence:** [`wallet_getGrantedExecutionPermissions`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7715.md#wallet_getgrantedexecutionpermissions).

**Consequence:** Request-time discovery does not by itself make a response union backwards-compatible. Option 3 needs a legacy-safe versioned or filtered listing design. If ERC-7715 authors reject that change, option 4 is the fallback.

### F-7715-06: Revocation result and status semantics are internally incomplete

**Classification:** Specification conflict.

The revocation prose says the wallet returns an empty response on success, while the adjacent response schema declares an object containing `chainIds`. The ERC has no generic permission-status method, and its list method excludes revoked grants.

**Evidence:** [`wallet_revokeExecutionPermission`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7715.md#wallet_revokeexecutionpermission) and [`wallet_getGrantedExecutionPermissions`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7715.md#wallet_getgrantedexecutionpermissions).

**Consequence:** A live-revocation profile cannot yet report pending, effective, failed, or finalised state through a common current shape. This must be resolved in ERC-7715 or in an explicitly selected binding-status interface.

### F-7715-07: Mandatory ERC-7710-shaped response fields were a deliberate simplification

**Classification:** Specification history.

The January 2026 simplification replaced conditional account and signer metadata with mandatory `dependencies` and `delegationManager` fields. Generalising the response again may still be justified, but it is not cost-free or obviously aligned with the most recent simplification intent.

**Evidence:** [`2adc3783667334a371eab433fecbe9953dc848e2`](https://github.com/ethereum/ERCs/commit/2adc3783667334a371eab433fecbe9953dc848e2), "Simplify specification to ease wallet implementation".

**Resolution for this milestone:** Treat the implementation-cost and author-intent question as open. Do not describe broad cross-wallet adoption or the response change as established.

### F-7710-01: ERC-7710 is a redemption interface, not a portable permission vocabulary

**Classification:** Specification.

ERC-7710 leaves delegation acquisition out of scope. Its permission contexts are manager-specific, and its manager calls a privileged function on the delegator. It also requires atomic interpretation of redemption tuples.

**Evidence:** [`Obtaining Delegations`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7710.md#obtaining-delegations), [`Redeeming a Delegation`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7710.md#redeeming-a-delegation), and [`Interfaces`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7710.md#interfaces).

**Inference:** ERC-7710 can be one binding, but its `permissionContext` cannot be the only canonical representation of a cross-system session grant.

### F-5792-01: ERC-5792 is transaction capability transport, not grant semantics

**Classification:** Specification.

ERC-5792 supplies wallet call and capability RPCs. It does not define persistent session authority, policy composition, or live grant revocation.

**Evidence:** [`EIP-5792`](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-5792.md).

**Inference:** Its capability-negotiation patterns may inform transport integration, but they do not remove the need for ERC-7715 or a permission semantic standard.

## EIP-8130

### F-8130-01: POLICY scope is a protocol gate to one manager, not a policy vocabulary

**Classification:** Specification.

When an actor has `POLICY` scope, EIP-8130 gates its top-level call to the stored `policy_manager`. The associated `policy_commitment` is opaque to the protocol; manager logic supplies the vocabulary and enforcement.

**Evidence:** [`Actor Policies`](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-8130.md#actor-policies).

**Consequence:** EIP-8130 can bind a transport-independent semantic commitment but does not define that commitment's encoding or meaning.

### F-8130-02: Native dispatch already preserves account identity to the policy manager

**Classification:** Specification.

The old question "what executes the approved action?" is too broad. EIP-8130 specifies that protocol call execution originates from the account and gates the actor's call to the manager. A manager equal to the account requires policy-aware account code.

**Evidence:** [`Actor Policies`](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-8130.md#actor-policies) and [`Call Execution`](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-8130.md#call-execution).

**Remaining question:** How an external manager drives the account, and whether one reference construction is intended for standardisation, remains below the protocol gate.

### F-8130-03: The reference external-manager path needs a separately trusted executor

**Classification:** Implementation.

The reference `PolicyManager` receives the account-originated call, enforces the binding, then calls the account. `DefaultAccount` accepts that second call only when the manager is registered as a live actor using the `TRUSTED_EXECUTOR` authenticator and operational scope.

**Evidence:** [`PolicyManager.execute`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/PolicyManager.sol#L110-L139), [`PolicyManager._enforce`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/PolicyManager.sol#L227-L247), and [`DefaultAccount._isAuthorizedCaller`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/accounts/DefaultAccount.sol#L138-L150).

**Conflict correction:** Earlier notes treated the complete execution component as unknown. The protocol-to-manager leg and reference manager-to-account leg are known. What remains unresolved is whether the two-actor trusted-executor construction is the intended normative binding, especially off native EIP-8130 chains.

### F-8130-04: Actor expiry, live revocation, and unlanded-signature cancellation are distinct

**Classification:** Specification.

Actor expiry is checked at inclusion; `RevokeActor` removes a live actor; the local epoch cancels outstanding local change signatures but does not revoke a live actor.

**Evidence:** [`Actor Expiry`](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-8130.md#actor-expiry), [`RevokeActor` change](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-8130.md#config-change-format), and [`Epoch System`](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-8130.md#epoch-system).

**Consequence:** Wallet status and presentation must not collapse expiry, live revocation, and pending-authorisation cancellation into one state.

### F-8130-05: The reference manager commitment is not a transport-independent semantic grant ID

**Classification:** Implementation.

The reference manager hashes the account, policy evaluator, configuration hash, validity bounds, and salt. It does not name a portable profile or extension versions.

**Evidence:** [`PolicyManager._commitment`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/PolicyManager.sol#L248-L271).

**Inference:** A future semantic grant hash must either be nested in this manager-specific commitment or use a new binding. Equality must not be assumed.

### F-8130-06: The viem branch corresponds to transport, not policy semantics

**Classification:** Inference.

The pinned viem branch adds EIP-8130 transaction, account-change, signature, RPC, and serializer support aligned to the same experimental transaction family. It does not encode the reference `SessionPolicy` as a common wallet permission vocabulary.

**Evidence:** [`feat/eip-8130` tree](https://github.com/chunter-cb/viem/tree/24aa695819c535ca4eac941c34cf8614cc331b05) and the canonical contract revision paired in [`SOURCES.md`](./SOURCES.md).

**Resolution:** Use viem as transport correspondence evidence only. Do not cite it for baseline policy semantics or wallet display.

## EIP-8141

### F-8141-01: One execution approval authorises every later SENDER frame

**Classification:** Specification.

EIP-8141 maintains one transaction-scoped execution-approval flag. Once approved, every subsequent `SENDER` frame executes with the transaction sender as caller. Custom validation must bind approval to the complete authorised frame set.

**Evidence:** [`Execution Approval Authorizes All Subsequent Sender Frames`](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-8141.md#execution-approval-authorizes-all-subsequent-sender-frames).

**Consequence:** Checking one selected sender frame is insufficient for a restricted session actor, even when that actor signs the full transaction. The actor is the adversary constrained by the policy.

### F-8141-02: Validation can inspect later frames but cannot consume persistent policy state in VERIFY

**Classification:** Specification and implementation.

Frame parameter and data instructions let validation inspect later frames. The PoC separates read-only policy checking in `VERIFY` from stateful consumption in a later account `SENDER` hook.

**Evidence:** EIP-8141 [`VERIFY` state restrictions](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-8141.md#L423-L430) and [`Cross-frame Data Visibility During Validation`](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-8141.md#cross-frame-data-visibility-during-validation), PoC [`IPolicy8141`](https://github.com/sm-stack/eip8141-poc/blob/fe02e01b21ed660c857a9fab5646e871cf886cd1/contracts/src/example/kernel/interfaces/IPolicy8141.sol#L7-L35), and [`_consumeStatefulPolicies`](https://github.com/sm-stack/eip8141-poc/blob/fe02e01b21ed660c857a9fab5646e871cf886cd1/contracts/src/example/kernel/core/ValidationManager8141.sol#L461-L480).

**Unresolved:** A conforming stateful adapter still needs a complete frame-shape restriction, aggregate pre-check, mutation point, rollback rule, and mempool-race analysis.

### F-8141-03: The current PoC permission path checks only the first later account SENDER frame

**Classification:** Implementation.

`Kernel8141._findSenderFrameIndex` returns the first later `SENDER` frame that targets the account. That single index is passed into permission-policy checks before approval.

**Evidence:** [`_findSenderFrameIndex`](https://github.com/sm-stack/eip8141-poc/blob/fe02e01b21ed660c857a9fab5646e871cf886cd1/contracts/src/example/kernel/Kernel8141.sol#L734-L747) and [`validatePermission`](https://github.com/sm-stack/eip8141-poc/blob/fe02e01b21ed660c857a9fab5646e871cf886cd1/contracts/src/example/kernel/Kernel8141.sol#L342-L384).

**Conflict:** This does not satisfy F-8141-01 for a policy actor that appends another direct `SENDER` frame.

**Authority choice:** Use the EIP for required security behaviour. Treat the PoC as evidence of an incomplete experimental adapter, not conformance.

### F-8141-04: The PoC and current draft have material format drift

**Classification:** Implementation conflict.

The PoC documentation and opcode wrapper reflect an earlier transaction and frame-parameter surface. The current EIP and active execution-specs branch include later fee, state-gas, signature, and frame changes not fully represented by the PoC.

**Evidence:** PoC [`eip-8141-overview.md`](https://github.com/sm-stack/eip8141-poc/blob/fe02e01b21ed660c857a9fab5646e871cf886cd1/docs/eip-8141-overview.md), PoC [`FrameTxLib.sol`](https://github.com/sm-stack/eip8141-poc/blob/fe02e01b21ed660c857a9fab5646e871cf886cd1/contracts/src/FrameTxLib.sol#L44-L53), current [`EIP-8141`](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-8141.md), and [`execution-specs` branch](https://github.com/ethereum/execution-specs/tree/6798542ebd017b683b688489d770bf206c8bd3ba).

**Authority choice:** Use the current EIP for normative shape and execution-specs for current implementation evidence.

### F-8141-05: Implementation maturity is insufficient for a frozen binding

**Classification:** Unresolved.

The official implementation and first-devnet trackers remain open with incomplete specification, tests, hardening, benchmarking, client, release, and launch work.

**Evidence:** [`EIP-8141 implementation tracker`](https://github.com/ethereum/execution-specs/issues/2829) and [`frames-devnet release tracker`](https://github.com/ethereum/execution-specs/issues/3368), retrieved 27 August 2026.

**Recommendation:** The first review package may define binding requirements and adversarial cases, but must not claim a complete current EIP-8141 adapter.

### F-8141-06: The PoC permission path discards policy validity bounds

**Classification:** Implementation conflict.

`TimestampPolicy8141` returns packed `validAfter` and `validUntil` values, but `Kernel8141.validatePermission` extracts only the validation result and explicitly does not enforce the returned time bounds. Deployment of the policy therefore does not demonstrate grant-level validity enforcement in the current permission path.

**Evidence:** [`TimestampPolicy8141.checkFrameTxPolicy`](https://github.com/sm-stack/eip8141-poc/blob/fe02e01b21ed660c857a9fab5646e871cf886cd1/contracts/src/example/kernel/policies/TimestampPolicy8141.sol#L25-L39) and [`Kernel8141.validatePermission`](https://github.com/sm-stack/eip8141-poc/blob/fe02e01b21ed660c857a9fab5646e871cf886cd1/contracts/src/example/kernel/Kernel8141.sol#L372-L384).

**Authority choice:** Treat finite session validity as an adapter requirement, not an implemented PoC capability. EIP-8141's separate expiry verifier is transaction-level and does not by itself limit a malicious session actor's reusable grant.

### F-8141-07: The PoC selector policy does not demonstrate nested dapp-action scope

**Classification:** Implementation conflict.

`SelectorPolicy8141` reads the first four bytes of the selected outer account-targeted `SENDER` frame, so it observes an account entry selector such as `executeHooked`, not necessarily the nested application target and selector. The permission E2E test also marks that policy `SKIP_FRAMETX` because its storage reads violate the current validation restrictions.

**Evidence:** [`SelectorPolicy8141.checkFrameTxPolicy`](https://github.com/sm-stack/eip8141-poc/blob/fe02e01b21ed660c857a9fab5646e871cf886cd1/contracts/src/example/kernel/policies/SelectorPolicy8141.sol#L23-L37) and [`kernel-permission.ts`](https://github.com/sm-stack/eip8141-poc/blob/fe02e01b21ed660c857a9fab5646e871cf886cd1/contracts/e2e/kernel/kernel-permission.ts#L127-L140).

**Resolution:** Count this as code-level account-entry inspection evidence only. A conforming adapter still has to decode and constrain every nested application action.

## Framework semantics

### F-POLICY-01: Exact target-selector pairing is portable; independent sets can widen authority

**Classification:** Implementation and inference.

Smart Sessions hashes an action's target and selector as one identity. EIP-8130's reference `CallScope` also keeps one target with its selectors. MetaMask's independent allowed-target and allowed-method enforcers express a Cartesian product unless compiled through an exact-execution shape.

**Evidence:** Smart Sessions [`IdLib.toActionId`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/IdLib.sol#L13-L30), EIP-8130 [`SessionPolicy.CallScope`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/SessionPolicy.sol#L77-L89), and MetaMask [`ExactExecutionEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/ExactExecutionEnforcer.sol).

**Recommendation:** Keep exact action pairs in the candidate baseline. Never flatten them unless the Cartesian product is the requested grant.

### F-POLICY-02: AND within an action and OR across explicit alternatives is the narrow common composition model

**Classification:** Inference.

Smart Sessions selects a target-selector action and intersects its policies. Kernel intersects all policies with the signer result. MetaMask runs every caveat while offering an explicit, system-specific OR wrapper.

**Evidence:** Smart Sessions [`PolicyLib.check`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/PolicyLib.sol#L27-L78), Kernel [`_validateUserOpPermission`](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/core/ValidationManager.sol#L398-L425), and MetaMask [`LogicalOrWrapperEnforcer`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers/LogicalOrWrapperEnforcer.sol).

**Recommendation:** Candidate baseline composition is OR over enumerated exact actions and AND over all applicable restrictions. General Boolean graphs remain outside baseline.

### F-POLICY-03: A generic spending-limit label would hide incompatible semantics

**Classification:** Inference.

The inspected systems differ on decoded selectors, requested amount versus balance delta, recipient identity, approvals, `transferFrom`, period anchors, streaming accrual, state keys, and failed-call consumption.

**Evidence:** EIP-8130 [`SessionPolicy`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/SessionPolicy.sol), Smart Sessions [`ERC20SpendingLimitPolicy`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/external/policies/ERC20SpendingLimitPolicy.sol), MetaMask [asset enforcers](https://github.com/MetaMask/delegation-framework/tree/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/enforcers), and Base [`TransferSettingsPolicy`](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/policies/TransferSettingsPolicy.sol).

**Resolution:** Native and direct ERC-20 totals remain unresolved baseline candidates pending implementer agreement. Periodic, streaming, approval, `transferFrom`, balance-delta, and indirect-effect models require distinct extensions.

### F-POLICY-04: Wallet display requires common decoded semantics, not enforceable opaque bytes

**Classification:** Inference.

Every onchain framework permits arbitrary module, policy, or enforcer configuration. MetaMask's SDK demonstrates displayable typed schemas for one wallet stack, but no surveyed framework supplies an ecosystem-wide decoder and version registry.

**Evidence:** MetaMask [ERC-7715 permission schemas](https://github.com/MetaMask/smart-accounts-kit/tree/d042c145660acddd241d6eb9bc27ccab5249d2e9/packages/7715-permission-types/src/permissions), Smart Sessions [`PolicyData`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/DataTypes.sol#L15-L45), and MetaMask [`Caveat`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/utils/Types.sol#L19-L42).

**Recommendation:** Baseline and extension conformance must include a deterministic display schema and exact version discovery.

### F-POLICY-05: Revocation operations are analogous but not equivalent

**Classification:** Implementation and inference.

EIP-8130 deletes actor configuration; Smart Sessions removes a live session and separately revokes unused enable signatures; Kernel uninstalls modules; MetaMask toggles a delegation hash; Base uninstalls a policy record.

**Evidence:** EIP-8130 [`_applyRevoke`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/Keystore.sol#L720-L759), Smart Sessions [`removeSession`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/core/SmartSessionBase.sol#L309-L352), Kernel [`_uninstallValidation`](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/core/ValidationManager.sol#L220-L261), and MetaMask [`disableDelegation`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/DelegationManager.sol#L85-L113).

**Recommendation:** Portable semantics require an observable root-controlled live-revocation guarantee, while the operation and finality remain binding-specific.

### F-POLICY-06: Account-originated execution always needs protocol or account cooperation

**Classification:** Inference.

The observed working paths use protocol dispatch, account code, or a trusted account executor. An ordinary manager calling a dapp directly changes `msg.sender` to the manager.

**Evidence:** F-8130-02, F-8130-03, Smart Sessions account execution in [`PolicyLib`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/PolicyLib.sol#L160-L303), Kernel [`execute`](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/Kernel.sol#L220-L292), and MetaMask [`redeemDelegations`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/DelegationManager.sol#L178-L291).

**Recommendation:** Every binding must prove the account execution path. A common manager ABI alone is not sufficient.

### F-POLICY-07: One semantic grant across simultaneous bindings can duplicate stateful capacity

**Classification:** Inference and unresolved.

The surveyed counters and revocation records are keyed in binding-specific storage. Installing the same semantic grant through two managers can create two independent spending counters even if both use the same semantic hash.

**Recommendation:** Until shared state is demonstrated, one grant identifier should expose one live binding. Multi-route exercise remains a later design problem.

### F-POLICY-08: Exact empty-calldata semantics need adapter checks in current frameworks

**Classification:** Implementation conflict.

The candidate semantic model distinguishes empty calldata from named selectors and rejects one-to-three-byte calldata. EIP-8130's reference `SessionPolicy` permits empty calldata for any explicitly scoped target even when selectors are listed. Smart Sessions maps every calldata length below four bytes to the same `VALUE_SELECTOR`, combining empty and one-to-three-byte cases.

**Evidence:** EIP-8130 [`SessionPolicy._onExecute`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/SessionPolicy.sol#L343-L381), Smart Sessions [`IdLib.toActionId`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/IdLib.sol#L7-L20), and [`PolicyLib.checkSingle7579Exec`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/PolicyLib.sol#L176-L193).

**Recommendation:** Keep explicit empty-call semantics as a candidate, but require an adapter-level exact-length check. Do not claim that either current implementation maps without widening.

### F-POLICY-09: Smart Sessions permission IDs are not complete semantic-grant commitments

**Classification:** Implementation conflict.

Smart Sessions v1 and v2 derive `PermissionId` from the session validator, validator initialisation data, and salt. The action and policy collections are not part of that identifier, so policy configuration can change while the permission ID remains stable. The signed enable or session digest covers more material, but it is a framework-specific authorisation object rather than the proposed transport-independent commitment.

**Evidence:** v1 [`IdLib.toPermissionId`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/IdLib.sol#L73-L82), v1 [`HashLib.sessionDigest`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/HashLib.sol#L140-L192), and v2 [`IdLibV2.toPermissionId`](https://github.com/rhinestonewtf/smart-sessions-v2/blob/bcf7ce653921a9dab5a79e30e4a85e403cdf24fe/src/lib/IdLibV2.sol#L37-L61).

**Consequence:** A binding may use `PermissionId` for storage and routing, but it must separately prove that root authorisation commits to the complete semantic grant and the selected implementation configuration.

### F-POLICY-10: Smart Sessions v2 enable expiry is signature freshness, not live grant validity

**Classification:** Implementation conflict.

Smart Sessions v2 checks `SmartSessionEmissaryEnable.expires` while enabling a configuration. That value is not stored as the session's runtime validity and is not checked by the later action-enforcement path. V2 therefore does not supply finite grant validity merely because the enable object has an expiry.

**Evidence:** v2 [`SmartSessionManager._enableSession`](https://github.com/rhinestonewtf/smart-sessions-v2/blob/bcf7ce653921a9dab5a79e30e4a85e403cdf24fe/src/core/SmartSessionManager.sol#L82-L147), [`SmartSessionStorage`](https://github.com/rhinestonewtf/smart-sessions-v2/blob/bcf7ce653921a9dab5a79e30e4a85e403cdf24fe/src/core/SmartSessionStorage.sol#L20-L61), and [`SmartSessionMixin._enforceActionPolicies`](https://github.com/rhinestonewtf/smart-sessions-v2/blob/bcf7ce653921a9dab5a79e30e4a85e403cdf24fe/src/core/SmartSessionMixin.sol#L184-L243).

**Recommendation:** Treat runtime validity as a separately enforced semantic requirement. Display signed-config expiry and live-grant expiry as different fields and states.

## Standards recommendation

### F-SHAPE-01: The current evidence favours a companion semantic ERC plus a narrow ERC-7715 generalisation

**Classification:** Recommendation.

F-7715-01 shows the request can carry a companion-defined permission. F-7715-02 shows the unchanged response cannot truthfully carry non-ERC-7710 bindings. Keeping semantics in ERC-7715 alone would conflate request transport with authority and conformance. A complete replacement may be unnecessary, but F-7715-05 means request-time discovery alone cannot make a response union backwards-compatible because the current list method is unfiltered.

**Recommendation:** Use option 3 as the preferred implementer-discussion direction, not as a proven compatibility result. Preserve the legacy response exactly for ERC-7710. Add explicit binding negotiation, exact supported-configuration discovery, a typed binding response, and a legacy-safe versioned or filtered listing path. If ERC-7715 authors determine that the response and listing separation cannot be backwards-compatible, use a versioned successor rather than ambiguous optional fields.

**Status:** Evidence-backed proposal, not consensus. The detailed comparison is in [`STANDARDS-SHAPE.md`](./STANDARDS-SHAPE.md).
