;;
;; Copyright 1337 (c) by Kirill Miazine <km@krot.org>
;;

;;; sla
(define (get-path-sla)
  (float (replace "," (slice (or (env "PATH_INFO") "/") 1) ".")))

(define (get-form-sla)
  (float (replace "," (or (Web:post "sla") (Web:get "sla") "") ".")))

(define (get-sla)
  (let
    (sla (or (get-form-sla) (get-path-sla) 99.9))
    (cond
      ((< sla 0.0) 0.0)
      ((> sla 100.0) 100.0)
      (true sla))))

(define (format-sla sla)
  (trim (trim (format "%f" sla) "0") "."))

;;; durations
(setq seconds-day (mul 3600 24))
(setq hours-day 24)
(setq days-week 7)
(setq days-year 365.2425) ; pick one at http://en.wikipedia.org/wiki/Year#Summary
(setq months-year 12)
(setq weeks-year (div days-year days-week))
(setq hours-year (mul hours-day days-year))
(setq days-month (div days-year months-year))
(setq seconds-year (mul seconds-day days-year))
(setq weeks-month (div days-month days-week))
(setq hours-month (mul hours-day days-month))
(setq seconds-month (mul seconds-day days-month))
(setq hours-week (mul hours-day days-week))
(setq seconds-week (mul seconds-day days-week))

;;; quick and ugly multilanguage format monster
;;; needs a rewrite...
(define (fmt-secs sec lang skip-days)
  (let
    (htag (if (= lang "no") "t" "h")) ; lang is not used anymore, but anyway
    (cond
      ((< sec 60)
       (format "%.1fs" (float sec)))
      ((< sec 3600)
       (letn
         (mins (/ sec 60)
          secs (sub sec (* mins 60)))
         (format "%dm %.1fs" mins (float secs))))
      ((or (< sec 86400) skip-days)
       (letn
         (hours (/ sec 3600)
          mins (/ (sub sec (* hours 3600)) 60)
          secs (sub sec (* hours 3600) (* mins 60)))
         (format "%d%s %dm %.1fs" hours htag mins (float secs))))
      (true
        (letn
          (days (/ sec 86400)
           hours (/ (sub sec (* days 86400)) 3600)
           mins (/ (sub sec (* days 86400) (* hours 3600)) 60)
           secs (sub sec (* days 86400) (* hours 3600) (* mins 60)))
          (format "%dd %d%s %dm %.1fs" days hours htag mins (float secs)))))))

; vim: set tw=76 ts=2 encoding=utf8 fileencoding=utf8 ft=lisp et:
