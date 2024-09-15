;;; magit-fill-column.el --- Set magit commit message fill-column based on project -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Paul D. Nelson

;; Author: Paul D. Nelson <nelson.paul.david@gmail.com>
;; Version: 0.1
;; URL: https://github.com/ultronozm/magit-fill-column
;; Package-Requires: ((emacs "26.1") (magit "3.0.0"))
;; Keywords: convenience, git, magit, text

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

;; This package helps work with Git projects that have different line
;; lengths conventions for commit messages when using Magit.  It does
;; so by setting the `fill-column' variable appropriately.
;;
;; To use, add the following to your init file:
;;
;;   (require 'magit-fill-column)
;;   (add-hook 'git-commit-setup-hook #'magit-fill-column-set)
;;
;; or, if you have use-package available:
;;
;;   (use-package magit-fill-column
;;     :hook (git-commit-setup . magit-fill-column-set))
;;
;; Customize `magit-fill-column-alist' to specify your projects and desired
;; fill columns.

;;; Code:

(require 'magit)

(defgroup magit-fill-column nil
  "Automatically set `fill-column' based on Git project."
  :group 'magit
  :prefix "magit-fill-column-")

(defcustom magit-fill-column-alist
  '(("emacs" . 64)
    ("auctex" . 64))
  "Alist mapping Git project names to desired `fill-column' values.
Each element should be a cons cell where the car is the project name as
derived from the Git remote URL, and the cdr is the integer value for
`fill-column'."
  :type '(alist :key-type string :value-type integer)
  :group 'magit-fill-column)

(defun magit-fill-column--extract-remote-name ()
  "Extract the project name from the REMOTE-URL.
Assumes the project name is the base name of the repository without the
.git suffix."
  (when-let (remote-url (magit-get "remote.origin.url"))
    (file-name-base
     (directory-file-name
      (replace-regexp-in-string "\\.git$" "" remote-url)))))

(defun magit-fill-column-set ()
  "Set `fill-column' based on the current Git project's name.
Look up the project name in `magit-fill-column-alist' and set
`fill-column' accordingly if a match is found."
  (interactive)
  (when-let* ((project-name (magit-fill-column--extract-remote-name))
              (fill-col (and project-name
                             (cdr (assoc project-name magit-fill-column-alist)))))
    (setq-local fill-column fill-col)
    (message "Set `fill-column' to %d for project '%s'" fill-col project-name)))

(provide 'magit-fill-column)

;;; magit-fill-column.el ends here
