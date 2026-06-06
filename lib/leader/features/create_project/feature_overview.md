# Feature: Create Project (leader)

**Owner folder:** `lib/leader/features/create_project/`

## Purpose

Multi-step wizard to create and launch vacation, emergency, or investment projects.

## Dependencies

- `CreateProjectCubit` (provided at `MainApp` — survives wizard steps)
- `CreateProjectUseCase`, `LaunchProjectUseCase`
- `CreateProjectFlow` entry helpers
- `inject_project.dart`

## Routes

| Route | Step |
|-------|------|
| `/create-project/amount` | Goal amount |
| `/create-project/details` | Name, description, image |
| `/create-project/saving-settings` | Collaborative saving branch |
| `/create-project/funds-borrowing` | Vacation/emergency borrow rules |
| `/create-project/investment-settings` | ROI branch |
| `/create-project/review` | Review & submit |
| `/create-project/success` | Post-launch success |

## Trace

`CreateProjectCubit` → `POST /projects` + `POST /projects/{id}/launch`

## See also

- [`PROJECT_FLOW_MAP.md`](../../../../../PROJECT_FLOW_MAP.md) §4 Leader flow
