;;; composite-completion.el --- Completion style that composes all-completion results -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Taiki Sugawara

;; Author: Taiki Sugawara <buzz.taiki@gmail.com>
;; Keywords: convenience, completion
;; URL: https://github.com/buzztaiki/composite-completion.el
;; Version: 0.0.1
;; Package-Requires: ((emacs "26.1"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Example
;; (setq composite-completion-styles '(basic partial-completion orderless))
;; (setq completion-styles '(composite-completion))
;; (setq vertico-sort-function #'identity)

;;; Code:

(require 'minibuffer)
(require 'seq)

(defgroup composite-completion nil
  "Completion style that composes all-completion results."
  :group 'minibuffer)

(defcustom composite-completion-styles nil
  "List of completion styles to compose."
  :type `(repeat (choice ,@(thread-last
                             (mapcar #'car completion-styles-alist)
                             (delq 'composite-completion)
                             (mapcar (lambda (x) (list 'const x)))))))

(defun composite-completion-all-completions (string table pred point)
  "Return completion candidates of TABLE by STRING and PRED.
POINT is the position of point within STRING.

The function returns the result of all styles of
`composite-completion-styles' with duplicates removed while
preserving order."
  (unless composite-completion-styles
    (error "`composite-completion-styles' should be non-nil"))
  (let ((styles (if (string-empty-p string)
                    (list (car composite-completion-styles))
                  composite-completion-styles)))
    (let (candidates)
      (dolist (style styles)
        (let* ((completion-styles (list style))
               (xs (completion-all-completions string table pred point)))
          (when-let ((last (last xs)))
            ;; remove base-size from last cell
            (setcdr last nil))
          (setq candidates
                (nconc candidates (seq-filter (lambda (x) (not (member x candidates))) xs)))))
      candidates)))

(defun composite-completion-try-completion (string table pred point)
  "Return first completion candidate of TABLE by STRING and PRED.
POINT is the position of point within STRING.

This function returns the first result found of all styles of
`composite-completion-styles'."

  (let ((completion-styles composite-completion-styles))
    (completion-try-completion string table pred point)))

(add-to-list 'completion-styles-alist '(composite-completion
                                        composite-completion-try-completion
                                        composite-completion-all-completions
                                        "Completion style that composes all-completion results."))


(provide 'composite-completion)
;;; composite-completion.el ends here
