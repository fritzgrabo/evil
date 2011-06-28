;;;; Integrate Evil with other modules

(require 'evil-states)
(require 'evil-motions)

(dolist (cmd evil-motions)
  (evil-add-command-properties cmd :keep-visual t :repeat nil))

(dolist (cmd '(dabbrev-expand hippie-expand))
  (evil-add-command-properties cmd :repeat 'change))

;;; Custom

(add-to-list 'evil-emacs-state-modes 'Custom-mode)

;;; Debugger

(add-to-list 'evil-emacs-state-modes 'debugger-mode)

;;; ERT

(add-to-list 'evil-emacs-state-modes 'ert-results-mode)

;;; Undo tree visualizer

(add-to-list 'evil-motion-state-modes 'undo-tree-visualizer-mode)

(when (boundp 'undo-tree-visualizer-map)
  (define-key undo-tree-visualizer-map [remap evil-backward-char]
    'undo-tree-visualize-switch-branch-left)
  (define-key undo-tree-visualizer-map [remap evil-forward-char]
    'undo-tree-visualize-switch-branch-right)
  (define-key undo-tree-visualizer-map [remap evil-next-line]
    'undo-tree-visualize-redo)
  (define-key undo-tree-visualizer-map [remap evil-previous-line]
    'undo-tree-visualize-undo))

(defadvice show-paren-function (around evil)
  "Match parentheses in Normal state."
  (if (or (evil-insert-state-p)
          (evil-replace-state-p)
          (evil-emacs-state-p))
      ad-do-it
    (let ((pos (point)) syntax)
      (setq pos
            (catch 'end
              (dotimes (var (1+ (* 2 evil-show-paren-range)))
                (if (evenp var)
                    (setq pos (+ pos var))
                  (setq pos (- pos var)))
                (setq syntax (syntax-class (syntax-after pos)))
                (cond
                 ((eq syntax 4)
                  (throw 'end pos))
                 ((eq syntax 5)
                  (throw 'end (1+ pos)))))))
      (if pos
          (save-excursion
            (goto-char pos)
            ad-do-it)
        ;; prevent the preceding pair from being highlighted
        (when (overlayp show-paren-overlay)
          (delete-overlay show-paren-overlay))
        (when (overlayp show-paren-overlay-1)
          (delete-overlay show-paren-overlay-1))))))

(provide 'evil-integration)

;;; evil-integration.el ends here
