#! /usr/bin/env racket
#lang racket

;; Author: Petr Samarin
;; Date: 2012
;; Description:
;; Load an image and invert all pixel values
;; Using built-in Racket primitives

;; TODO: Add interaction between opencv and racket:
;;       manipulate image in opencv
;;       visualize using Racket opengl

;;; Includes
(require racket/system
         racket/gui/base
         racket/draw)

;;; Get image name from command line arguments
(define arguments (current-command-line-arguments))
(define image-name #f)

(if (zero? (vector-length arguments))
  (begin
    (printf "provide image name~n")
    (exit))
  (set! image-name (vector-ref arguments 0)))

;;; Load an image from the hard disk
(define bm (make-object bitmap% image-name))
;; Get image data
(define W (send bm get-width))
(define H (send bm get-height))
;; Copy the image into a bytes array
(define pixels (make-bytes (* W H 4)))
(send bm get-argb-pixels 0 0 W H pixels)

;; Invert each pixel channel-wise
(define (get-brightness x y a-bitmap pixels)
  (send a-bitmap get-argb-pixels x y 1 1 pixels)
  (bytes-ref pixels 1))

(time (let loop ([i (- (* W H 4) 1)])
        (when (>= i 0)
          ;; invert each pixel channel wise
          (bytes-set! pixels i (- 255 (bytes-ref pixels i)))
          (loop (- i 1)))))

(send bm set-argb-pixels 0 0 W H pixels)

; Make a frame by instantiating the frame% class
(define frame (new frame%
                   [label "Main Window"]
                   [width W]
                   [height H]))

(define canvas (new canvas% [parent frame]))
(define dc (send canvas get-dc))

(send frame show #t)
(sleep/yield 0.01)

(send dc draw-bitmap bm 0 0)

;;(exit)