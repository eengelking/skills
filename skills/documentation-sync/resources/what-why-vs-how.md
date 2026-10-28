# Rules versus procedures: what belongs where

## The split

- **Project instruction files and agent definitions** (`CLAUDE.md`, `PROJECT.md`, an
  agent's definition) state **what and why**: the project's purpose, its rules and
  constraints, and who may do what. Every session reads them, so they stay short.
- **Skills** state **how**: steps, commands and checklists. They load only when the work
  calls for them.

## The test for a block

Ask of any block in an instruction file: *if I removed this, would what the agent is
allowed or required to do change?*

- **Yes:** it is a rule. It stays.
- **No, it only says how to carry a rule out:** it is a procedure. It moves to a skill
  and leaves behind a one-line pointer in the instruction file, plus a row in the
  project's Skills table.

The Skills table has these columns: **skill**, **load it when**, **orchestrator**,
**sub-agent**. "Load it when" names the trigger, so an agent knows when the pointer
applies.

## Do not weaken a rule while moving it

A constraint stays where it is. Only the steps move. If a block mixes a rule with the
steps for it, split the block: keep the rule in the instruction file in its original
strength ("never", "always", "only the user"), and move the steps. A rule that becomes
"see the skill" has been demoted to a suggestion.

## Method for a split

1. **Classify every section** as what/why or how, with a reason. Record the table in the
   PR description.
2. **Group the moved how into a few skills by when they load**, not one skill per
   paragraph. Steps that are always used together belong together. A skill nobody loads
   at the right moment is dead weight.
3. **Update references** to the moved text, in other docs, skills, agent definitions and
   scripts.
4. **Diff old against new** and confirm every rule is either kept in place or present in
   a named skill. Anything that disappeared is a finding.
5. **Run the project's doc checks** (link checkers, index builders, frontmatter checks)
   and fix what they report.

## Check the installed skills first

Before writing a new skill, read the skills already installed, including this plugin's.
Reference what they cover instead of restating it. A first draft that restates an
installed skill's sequence will drift from it, and has to be trimmed later anyway. A
project skill should hold only what the installed skills cannot know about this project.
