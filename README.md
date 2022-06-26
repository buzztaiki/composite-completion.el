# composite-completion

Completion style that composes all-completion results.

Since this style is incompatible with sorting, you may want to disable the sort order in your completion system.

## Usage example
```lisp
(setq vertico-sort-function #'identity)
(setq composite-completion-styles '(basic partial-completion orderless))
(setq completion-styles '(composite-completion))
```
