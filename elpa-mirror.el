(setq elpamr-default-output-directory "~/myelpa")

(defun elpamr--create-one-item-for-archive-contents (pkg)
  "We can use package-alist directly. This one just append my meta info into package-alist"
  (let ((name (car pkg))
        item
        package-content
        found
        (i 0))

    (while (and (not found)
                (< i (length package-archive-contents)))
      (setq package-content (nth i package-archive-contents))
      ;; well, all we need do it to write the actual version into package-content
      (when (string= name (car package-content))
        ;; we try to provide more information from archive-contents if possible
        (aset (cdr package-content) 0 (elt (cdr pkg) 0))
        (setq item package-content)
        (setq found t)
        )
      (setq i (1+ i)))

    (unless found
      (message "not found")
      ;; make do with installed package, looks it's deleted in archive-contents
      (setq item pkg))

    (let ((a (cdr item)) na)
      (when (= 5 (length a))
        ;; only need first four
        (setq na (vector (elt a 0)
                             (elt a 1)
                             (elt a 2)
                             (elt a 3)
                             ))
        (message "na=%s" na)
        (message "well item=%s" (nthcdr 1 item))
        (setq item (cons (car item) na))
        ;; (setcar (nthcdr 1 item) na)
        ))
    (message "item=%s" item)

    item
    ))

(defun elpamr--pkg-installed (pkg-info)
  (let ((name (nth 0 pkg-info))
        (version (nth 1 pkg-info)))
    (let ((i 0) found item)
      (while (and (not found)
                  (< i (length package-archive-contents)))
        (setq i (1+ i))
        ))
    ))

(defun elpamr--package-info (dirname)
  "return '(package-name integer-version-number) or nil"
  (interactive)
  (let (rlt name version)
    (when (string-match "\\(.*\\)-\\([0-9.]+\\)$" dirname)
      (setq name (match-string 1 dirname))
      (setq version (split-string (match-string 2 dirname) "\\."))
      (setq rlt (list name version))
      ;; (message "rlt=%s" rlt)
      )
    rlt
    ))

(defun elpamr--output-fullpath (file)
  "return full path of output file give the FILE"
  (file-truename (concat
                  (file-name-as-directory elpamr-default-output-directory)
                  file)))

(defun elpamr-create-mirror ()
  "export and packages pkg into a new directory.create all the necessary web files for a mirror site"
  (interactive)
  (let (item rlt pkg-dirname pkg-info tar-cmd len dirs)
    (dolist (pkg package-alist)
      (setq item (elpamr--create-one-item-for-archive-contents pkg))
      (push item rlt)
      )

    (unless (and elpamr-default-output-directory (file-directory-p elpamr-default-output-directory))
      (setq elpamr-default-output-directory (read-directory-name "Output directory:"))
      )

    (when (and elpamr-default-output-directory (file-directory-p elpamr-default-output-directory))
      (setq dirs (directory-files package-user-dir))
      (setq len (length dirs))
      (dolist (dir dirs)
        (unless (or (member dir '("archives" "." ".."))
                    (not (setq pkg-info (elpamr--package-info dir))))
          ;; package tar
          ;; (message "dir=%s" dir)
          ;; (message "elpamr-default-output-directory=%s" elpamr-default-output-directory)
          (setq tar-cmd (concat "cd " package-user-dir "; tar cf " (elpamr--output-fullpath dir) ".tar --exclude=*.elc --exclude=*~ " dir))
          ;; (message "tar-cmd=%s" tar-cmd)
          (shell-command tar-cmd))

        ;; extract dir with name and version, version should be converted into a number
        ;; compare with the version in the list (that version should also be a number
        ;; if both package name and version match, than package it, else just ignore
        ;; because we don't want to deal with orphan packages
        )

      ;; output archive-contents
      ;; that
      (with-temp-buffer
        (let ((print-level nil)  (print-length nil))
          ;; well, that's required, I don't know why
          (setq rlt (cons 1 rlt))
          (insert (format "%S" rlt)))
        (write-file (elpamr--output-fullpath "archive-contents")))
      )
    ))

(provide 'elpa-mirror)