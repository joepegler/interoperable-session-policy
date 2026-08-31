# Sources and Evidence Manifest

## Status and cutoff

This manifest supports the first standards-shape review package. The research cutoff is **27 August 2026, Europe/Dublin**. All fixed repositories and specification files are identified by a full commit SHA. Dynamic issue and discussion pages also record the retrieval date.

The corresponding checkout manifest is [`SOURCE_PINS.tsv`](./SOURCE_PINS.tsv). A source called current in this repository means current at this cutoff and revision, not stable or final.

## Source hierarchy

Use the source that is authoritative for the claim's layer:

1. A published EIP or ERC controls its normative protocol or interface requirements at the pinned revision.
2. Where the specification delegates details to a canonical repository, that repository controls those details. EIP-8130 expressly makes `base/eip-8130` authoritative for canonical contract internals.
3. Official specification implementations and tests establish the behaviour of the implementation branch, not additional normative requirements.
4. Default-branch contracts, tests, and encoders establish one implementation's behaviour.
5. Open pull requests, experimental branches, PoCs, and discussions are provisional and must be labelled as such.
6. README and SDK display schemas are supporting evidence only.

No common ABI, type name, contract address, or hash function proves common permission semantics without matching enforcement and failure behaviour.

## Pinned specification repositories

| ID | Repository | Commit | Relevant sources |
| --- | --- | --- | --- |
| `EIPS` | [`ethereum/EIPs`](https://github.com/ethereum/EIPs) | [`dbfa6bee8329650969b95080f23f7059c015c2ba`](https://github.com/ethereum/EIPs/tree/dbfa6bee8329650969b95080f23f7059c015c2ba) | EIP-5792, EIP-7702, EIP-8130, and EIP-8141. |
| `ERCS` | [`ethereum/ERCs`](https://github.com/ethereum/ERCs) | [`98469bc93b6add1e3bc9501dafaa73311071145b`](https://github.com/ethereum/ERCs/tree/98469bc93b6add1e3bc9501dafaa73311071145b) | ERC-4337, ERC-7579, ERC-7710, ERC-7715, and ERC-8286. |
| `ERC8340-PR` | [`ethereum/ERCs` PR 1883](https://github.com/ethereum/ERCs/pull/1883) | head [`e496579b121cf83232abecfa9d5fa88ead367174`](https://github.com/ethereum/ERCs/blob/e496579b121cf83232abecfa9d5fa88ead367174/ERCS/erc-8340.md) | Open transaction-metadata proposal. Encoding precedent only. |

| Specification | Status at cutoff | Pinned file |
| --- | --- | --- |
| EIP-7702 | Final | [`EIPS/eip-7702.md`](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-7702.md) |
| EIP-8130 | Draft | [`EIPS/eip-8130.md`](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-8130.md) |
| EIP-8141 | Draft | [`EIPS/eip-8141.md`](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-8141.md) |
| ERC-4337 | Final | [`ERCS/erc-4337.md`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-4337.md) |
| EIP-5792 | Final | [`EIPS/eip-5792.md`](https://github.com/ethereum/EIPs/blob/dbfa6bee8329650969b95080f23f7059c015c2ba/EIPS/eip-5792.md) |
| ERC-7579 | Draft | [`ERCS/erc-7579.md`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7579.md) |
| ERC-7710 | Draft | [`ERCS/erc-7710.md`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7710.md) |
| ERC-7715 | Draft | [`ERCS/erc-7715.md`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-7715.md) |
| ERC-8286 | Draft | [`ERCS/erc-8286.md`](https://github.com/ethereum/ERCs/blob/98469bc93b6add1e3bc9501dafaa73311071145b/ERCS/erc-8286.md) |

## Pinned implementation repositories

| ID | Repository and branch | Commit | Role |
| --- | --- | --- | --- |
| `E8130` | [`base/eip-8130`, `main`](https://github.com/base/eip-8130) | [`bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b`](https://github.com/base/eip-8130/tree/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b) | Canonical EIP-8130 contracts, reference account, manager, policy, and tests. |
| `VIEM-8130` | [`chunter-cb/viem`, `feat/eip-8130`](https://github.com/chunter-cb/viem/tree/feat/eip-8130) | [`24aa695819c535ca4eac941c34cf8614cc331b05`](https://github.com/chunter-cb/viem/tree/24aa695819c535ca4eac941c34cf8614cc331b05) | Experimental transaction types, serializers, and RPC tooling. |
| `SS-V1` | [`erc7579/smartsessions`, `main`](https://github.com/erc7579/smartsessions) | [`f5aaf867f7e22f3b9d746ce6f404f3a56833757f`](https://github.com/erc7579/smartsessions/tree/f5aaf867f7e22f3b9d746ce6f404f3a56833757f) | ERC-7579 session module, policies, hashing, lifecycle, and tests. |
| `SS-V2` | [`rhinestonewtf/smart-sessions-v2`, `main`](https://github.com/rhinestonewtf/smart-sessions-v2) | [`bcf7ce653921a9dab5a79e30e4a85e403cdf24fe`](https://github.com/rhinestonewtf/smart-sessions-v2/tree/bcf7ce653921a9dab5a79e30e4a85e403cdf24fe) | Current lifecycle, claim policies, emissary integration, and hashing. |
| `KERNEL` | [`zerodevapp/kernel`, `dev`](https://github.com/zerodevapp/kernel) | [`f2a84a332ec5a722e7e95a0d64601905c3c87fe9`](https://github.com/zerodevapp/kernel/tree/f2a84a332ec5a722e7e95a0d64601905c3c87fe9) | Permission installation, validation, account execution, and module lifecycle. |
| `K-PLUG` | [`zerodevapp/kernel-7579-plugins`, `master`](https://github.com/zerodevapp/kernel-7579-plugins) | [`332deed6eeef3d6279cde50aa1d51eff53728bd4`](https://github.com/zerodevapp/kernel-7579-plugins/tree/332deed6eeef3d6279cde50aa1d51eff53728bd4) | Concrete signer and policy modules. |
| `MM-DF` | [`MetaMask/delegation-framework`, `main`](https://github.com/MetaMask/delegation-framework) | [`9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411`](https://github.com/MetaMask/delegation-framework/tree/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411) | Delegations, caveats, redemption, account execution, and revocation. |
| `MM-KIT` | [`MetaMask/smart-accounts-kit`, `main`](https://github.com/MetaMask/smart-accounts-kit) | [`d042c145660acddd241d6eb9bc27ccab5249d2e9`](https://github.com/MetaMask/smart-accounts-kit/tree/d042c145660acddd241d6eb9bc27ccab5249d2e9) | ERC-7715 permission schemas, encoders, decoders, and wallet presentation data. |
| `MM-7715` | [`MetaMask/snap-7715-permissions`, `main`](https://github.com/MetaMask/snap-7715-permissions) | [`bfa810be21d8d98ec123ebfde2848f9fc3bb8fdc`](https://github.com/MetaMask/snap-7715-permissions/tree/bfa810be21d8d98ec123ebfde2848f9fc3bb8fdc) | Current wallet-side request, attenuation, storage, and ERC-7710-oriented grant handling evidence. |
| `BASE-POL` | [`base/account-policies`, `main`](https://github.com/base/account-policies) | [`6a834cad1c529181b467b72dbc7efedd3b34a5e6`](https://github.com/base/account-policies/tree/6a834cad1c529181b467b72dbc7efedd3b34a5e6) | Separate manager, lifecycle, transfer, and recurring-accounting precedents. |

## EIP-8141 implementation horizon

EIP-8141 implementation work is active and does not form one settled source.

| ID | Source | Revision at cutoff | Treatment |
| --- | --- | --- | --- |
| `EXEC-8141` | [`ethereum/execution-specs`, `eips/amsterdam/eip-8141`](https://github.com/ethereum/execution-specs/tree/6798542ebd017b683b688489d770bf206c8bd3ba) | [`6798542ebd017b683b688489d770bf206c8bd3ba`](https://github.com/ethereum/execution-specs/commit/6798542ebd017b683b688489d770bf206c8bd3ba) | Closest official executable specification branch inspected. |
| `EXEC-PR-3047` | [`execution-specs` PR 3047](https://github.com/ethereum/execution-specs/pull/3047) | head `50bf605196f5b3de4cff074cd85e8addc9ef186b` | Active implementation review and history. The branch above, not an old PR snapshot, is used for current behaviour. |
| `EXEC-TRACKER` | [`execution-specs` issue 2829](https://github.com/ethereum/execution-specs/issues/2829) | retrieved 27 August 2026 | Open tracker. It records incomplete specification, tests, hardening, benchmarking, client, and devnet work. |
| `EXEC-DEVNET` | [`execution-specs` issue 3368](https://github.com/ethereum/execution-specs/issues/3368) | retrieved 27 August 2026 | Open first-frames-devnet release tracker. Its release and launch dates remain unset and its status checklist remains incomplete. |
| `E8141-POC` | [`sm-stack/eip8141-poc`, `main`](https://github.com/sm-stack/eip8141-poc) | [`fe02e01b21ed660c857a9fab5646e871cf886cd1`](https://github.com/sm-stack/eip8141-poc/tree/fe02e01b21ed660c857a9fab5646e871cf886cd1) | Practical but experimental Geth, Solidity, viem, account, policy, and E2E examples. It lags the current EIP in material areas. |

The pinned EIP remains normative. The execution-specs branch is the primary implementation evidence. The PoC is used only to expose practical adapter choices and mismatches.

## Discussions and history

The following pages are mutable. Claims based on them include the retrieval date.

- [ERC-7715 discussion](https://ethereum-magicians.org/t/erc-7715-grant-permissions-from-wallets/20100), retrieved 27 August 2026.
- [ERC-7715 example request handler](https://eips.ethereum.org/assets/eip-7715/Example7715PermissionsRequestHandler.html), retrieved 27 August 2026.
- [ERC-8340 discussion](https://ethereum-magicians.org/t/erc-8340-transaction-metadata-encoding/29022), retrieved 27 August 2026.
- [EIP-8130 discussion](https://ethereum-magicians.org/t/eip-8130-account-abstraction-by-account-configurations/25952), retrieved 27 August 2026.
- Git history for `ERCS/erc-7715.md` and `EIPS/eip-8130.md` in the pinned repositories. History is used to distinguish current text from earlier assumptions, not as current normative text.

## Evidence routing

Detailed claim-level links are in [`FINDINGS.md`](./FINDINGS.md). The primary code entry points are:

- EIP-8130: [`Keystore.sol`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/Keystore.sol), [`PolicyManager.sol`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/PolicyManager.sol), [`SessionPolicy.sol`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/policies/SessionPolicy.sol), and [`DefaultAccount.sol`](https://github.com/base/eip-8130/blob/bc41a9715d0eecc3fdd27a6d9ed422aa4a151f7b/src/accounts/DefaultAccount.sol).
- Smart Sessions: v1 [`DataTypes.sol`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/DataTypes.sol), [`PolicyLib.sol`](https://github.com/erc7579/smartsessions/blob/f5aaf867f7e22f3b9d746ce6f404f3a56833757f/contracts/lib/PolicyLib.sol), and v2 [`DataTypes.sol`](https://github.com/rhinestonewtf/smart-sessions-v2/blob/bcf7ce653921a9dab5a79e30e4a85e403cdf24fe/src/types/DataTypes.sol).
- Kernel: [`ValidationManager.sol`](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/core/ValidationManager.sol) and [`IERC7579Modules.sol`](https://github.com/zerodevapp/kernel/blob/f2a84a332ec5a722e7e95a0d64601905c3c87fe9/src/interfaces/IERC7579Modules.sol).
- MetaMask: [`Types.sol`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/utils/Types.sol), [`DelegationManager.sol`](https://github.com/MetaMask/delegation-framework/blob/9e7fd80dc5a1f74bcb5efdff6aa91b228fb86411/src/DelegationManager.sol), and the [permission schemas](https://github.com/MetaMask/smart-accounts-kit/tree/d042c145660acddd241d6eb9bc27ccab5249d2e9/packages/7715-permission-types/src/permissions).
- Base policies: [`PolicyManager.sol`](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/PolicyManager.sol), [`TransferSettingsPolicy.sol`](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/policies/TransferSettingsPolicy.sol), and [`RecurringAllowance.sol`](https://github.com/base/account-policies/blob/6a834cad1c529181b467b72dbc7efedd3b34a5e6/src/policies/accounting/RecurringAllowance.sol).
- EIP-8141 PoC: [`Kernel8141.sol`](https://github.com/sm-stack/eip8141-poc/blob/fe02e01b21ed660c857a9fab5646e871cf886cd1/contracts/src/example/kernel/Kernel8141.sol), [`IPolicy8141.sol`](https://github.com/sm-stack/eip8141-poc/blob/fe02e01b21ed660c857a9fab5646e871cf886cd1/contracts/src/example/kernel/interfaces/IPolicy8141.sol), and [`ValueLimitPolicy8141.sol`](https://github.com/sm-stack/eip8141-poc/blob/fe02e01b21ed660c857a9fab5646e871cf886cd1/contracts/src/example/kernel/policies/ValueLimitPolicy8141.sol).

## Reproduction

Restore or verify every ignored checkout with:

```sh
./scripts/fetch-references.sh
./scripts/fetch-references.sh --verify
```

The script refuses to alter dirty worktrees and verifies both origin and exact `HEAD`.

## Verification limitations

- The source revisions were inspected, but no claim is made that a Draft proposal will retain its current behaviour.
- Upstream tests are supporting implementation evidence. They are not conformance tests for the proposed cross-system semantics.
- EIP-8141's implementation and first-devnet trackers remain open. The PoC's modified Geth, Solidity, and viem submodules are not treated as current specification authority.
- Smart Sessions v1 and v2 are separate snapshots. V2 is not presumed to preserve every v1 lifecycle or policy field.
- MetaMask SDK and Snap schemas establish what one wallet stack can request and display, not universal wallet support.
- The comparison does not prove that MetaMask, Rabby, Coinbase Wallet, or Ambire currently implement the complete target flow over the same existing EOA.
- Canonical encoding, hashing, global identifier governance, and a shared enforcement ABI remain deliberately undecided.
