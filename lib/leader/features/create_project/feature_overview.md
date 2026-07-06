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
| `/create-project/upload-images` | Optional project images (create wizard; skip → review) |
| `/create-project/selected-images` | 114×114 grid, max **5** images; upload tile hidden at cap |
| `/create-project/review` | Review & submit |
| `/create-project/success` | Post-launch success |

## Project images (wizard)

| Rule | Implementation |
|------|----------------|
| Max count | `CreateProjectImageLimits.maxImages` (5) |
| State | `CreateProjectForm.projectImagePaths` (local file paths) |
| Add / remove | `CreateProjectCubit.addProjectImages` / `removeProjectImageAt` |
| UI | `CreateProjectSelectedImagesGrid` — upload tile until 5 images |
| API upload | Deferred — paths held in form until backend endpoint ships |

## Trace (create)

`CreateProjectCubit` → `POST /projects` + `POST /projects/{id}/launch`

## Edit project (leader)

Entry: project detail menu → `hydrateFromProjectDetail` → details (`CreateProjectEntryMode.editFromProjectDetail`, category locked) → settings → review → success.

**Review “Edit” (create wizard):** `editFromReview` — same create titles/step badges; category and visibility stay editable; Next continues through settings steps like the normal wizard (not project-detail edit UX).

| Concern | Implementation |
|---------|----------------|
| API | `PUT /projects/{id}` via `UpdateProjectUseCase` / `CreateProjectUpdateCubit` |
| Pre-fill | `CreateProjectFormFromDetail` from `ProjectDetailEntity` |
| Permission | `canEditProject` (group leader only) before navigation |
| Copy | Review **Edit**, success **Project Edited** (`AppStrings`) |
| State | Same `CreateProjectCubit` + shared validators as create |

## See also

- [`PROJECT_FLOW_MAP.md`](../../../../../PROJECT_FLOW_MAP.md) §4 Leader flow
