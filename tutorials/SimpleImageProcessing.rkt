#! /usr/bin/env racket
#lang racket

;; Author: Petr Samarin
;; Date: 2012
;; Description:
;; 1) Load an image
;; 2) Set region of interest (ROI) rectangle
;; 3) Apply erosion on ROI
;; 4) Invert the whole image
;; This example was inspired by:
;; http://www.cs.iit.edu/~agam/cs512/lect-notes/opencv-intro/
;; and the book "Learning OpenCV" by Bradski and Kaehler, 2008

;;; Includes
(require "../src/types.rkt"
         "../src/highgui.rkt"
         "../src/core.rkt"
         "../src/imgproc.rkt")

;;; Load an image from the hard disk
(define img (cvLoadImage "images/test.png" CV_LOAD_IMAGE_COLOR))

;;; Get image properties
(define height     (IplImage-height img))
(define width      (IplImage-width img))
(define step       (- (IplImage-widthStep img) 1))
(define channels   (IplImage-nChannels img))

(printf "width: ~a, height: ~a, step: ~a, channels: ~a~n"
        width height step channels)

;;; Image processing
;; set image's region of interest to rectangle (100, 100) -> (200, 200)
(cvSetImageROI img (make-CvRect 100 100 200 200))

;; erode the ROI in-place 1 time for each pixel
(cvErode img img #f 1)

;; set back the ROI
(cvSetImageROI img (make-CvRect 0 0 width height))

;;; IplImage manipulation using Racket bytes
;; Get image data:
;; data is provided in a bytestring (without copying), so that it can be
;; manipulated in C and in Racket without copying back and forth
(define data (IplImage-data img))

;; Invert all pixel values
;; Doing this in Racket is slower than in C by a lot, but the speed is close to
;; Racket's native vectors
(time
(let loop ([i (- (* width height channels) 1)])
  (when (>= i 0)
    ;; invert each pixel channel-wise
    (bytes-set! data i (- 255 (bytes-ref data i)))
    (loop (- i 1)))))

;;; Show the image
;; it is not necessary to create a named window before showing the image
;; (cvNamedWindow "Main Window" CV_WINDOW_AUTOSIZE)
(cvShowImage "Main Window" img)
(define x (cvGetWindowHandle "Main Window"))
(cvMoveWindow "Main Window" 100 100)

;;; Wait for a key before destroying the window
(define key (cvWaitKey 0))
(printf "received key: ~a~n" key)

;;; Destroy image window
(cvDestroyWindow "Main Window")