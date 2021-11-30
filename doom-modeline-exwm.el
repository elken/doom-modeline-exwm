;;; doom-modeline-exwm.el --- Segment for Doom Modline to show EXWM workspaces -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021 Ellis Kenyő
;;
;; Author: Ellis Kenyő <me@elken.dev>
;; Maintainer: Ellis Kenyő <me@elken.dev>
;; Created: November 30, 2021
;; Modified: November 30, 2021
;; Version: 0.0.1
;; Homepage: https://github.com/elken/doom-modeline-exwm
;; Package-Requires: ((emacs "24.4") (doom-modeline "3.0.0") (exwm "0.26"))
;; SPDX-License-Identifier: GPL3
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  All that needs to be done is adding the segment to your modeline config
;;
;;; Code:

(require 'doom-modeline)
(require 'exwm-workspace)

;;
;; Custom variables
;;

(defgroup 'doom-modeline-exwm nil
  "Settings related to doom-modeline-exwm"
  :group 'doom-modeline)

(defgroup 'doom-modeline-exwm-faces nil
  "Faces related to doom-modeline-exwm"
  :group 'doom-modeline-faces)

(defcustom doom-modeline-exwm t
  "Whether to display the exwm segment.

Non-nil to display in the modeline"
  :type 'boolean
  :group 'doom-modeline-exwm)

;;
;; Faces
;;

(defface doom-modeline-exwm-current-workspace
  '((t (:inherit underline :weight bold)))
  "Face for the current workspace."
  :group 'doom-modeline-exwm-faces)

(defface doom-modeline-exwm-populated-workspace
  '((t (:inherit success :weight bold)))
  "Face for any workspace populated with an X window."
  :group 'doom-modeline-exwm-faces)

(defface doom-modeline-exwm-empty-workspace
  `((t (:foreground ,(face-foreground 'mode-line-inactive))))
  "Face for any workspace without an X window."
  :group 'doom-modeline-exwm-faces)

(defface doom-modeline-exwm-urgent-workspace
  '((t (:inherit warning :weight bold)))
  "Face for any workspace that is tagged as urgent by X."
  :group 'doom-modeline-exwm-faces)

;;
;; Segment
;;

(doom-modeline-def-segment exwm-workspaces
  (when (and doom-modeline-exwm
             (doom-modeline--active)
             (fboundp 'exwm--connection)
             exwm--connection)
    (exwm-workspace--update-switch-history)
    (concat
     (doom-modeline-spc)
     (elt (let* ((num (exwm-workspace--count))
                 (sequence (number-sequence 0 (1- num)))
                 (not-empty (make-vector num nil)))
            (dolist (i exwm--id-buffer-alist)
              (with-current-buffer (cdr i)
                (when exwm--frame
                  (setf (aref not-empty
                              (exwm-workspace--position exwm--frame))
                        t))))
            (mapcar
             (lambda (i)
               (mapconcat
                (lambda (j)
                  (format (if (= i j) "[%s]" " %s ")
                          (propertize
                           (apply exwm-workspace-index-map (list j))
                           'face
                           (cond ((frame-parameter (elt exwm-workspace--list j)
                                                   'exwm-urgency)
                                  'doom-modeline-exwm-urgent-workspace)
                                 ((= i j) 'doom-modeline-exwm-current-workspace)
                                 ((aref not-empty j) 'doom-modeline-exwm-populated-workspace)
                                 (t 'doom-moelinde-exwm-empty-workspace)))))
                sequence ""))
             sequence))
          (exwm-workspace--position (selected-frame))))))

(provide 'doom-modeline-exwm)
;;; doom-modeline-exwm.el ends here
