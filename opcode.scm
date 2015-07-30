;;;--------------opcode provider----------------------
(define (check-byte j)
  (or (and (<= 0 j) (<= j 255))
      (static-wrong "Cannot pack this number within a byte" j) ) )
(define (INVOKE0 address)
  (case address
    ((read)    (list 89))
    ((newline) (list 88))
    (else (static-wrong "Cannot integrate" address)) ) )
(define EXPLICIT-CONSTANT 'wait)

(define CHECKED-GLOBAL-REF (lambda (i) (list 8 i)))
(define SHALLOW-ARGUMENT-REF (lambda (j)
                               (check-byte j)
                               (case j
                                 ((0 1 2 3) (list (+ 1 j)))
                                 (else (list 5 j)))))
(define SET-GLOBAL! (lambda (i) (list 27 i)))
(define CALL0 (lambda (address) (INVOKE0 address) ))
(define CALL1 (lambda (address m1)
                (append m1 (INVOKE1 address))))
(define INVOKE3 
  (lambda (address)
    (static-wrong "No ternary integrated procedure" address)))
(define ALLOCATE-DOTTED-FRAME (lambda (arity) (list 56 (+ arity 1))))

(define PREDEFINED
  (lambda (i)
    (check-byte i)
    (case i
      ;; 0=\#t, 1=\#f, 2=(), 3=cons, 4=car, 5=cdr, 6=pair?, 7=symbol?, 8=eq?
      ((0 1 2 3 4 5 6 7 8) (list (+ 10 i)))
      (else (list 19 i)))))
(define DEEP-ARGUMENT-REF (lambda (i j) (list 6 i j)))
(define SET-SHALLOW-ARGUMENT! 
  (lambda (j)
    (case j
      ((0 1 2 3) (list (+ 21 j)))
      (else      (list 25 j)))))
(define SET-DEEP-ARGUMENT! (lambda (i j) (list 26 i j)))
(define GLOBAL-REF (lambda (i) (list 7 i)))
(define GOTO 
  (lambda (offset)
    (cond ((< offset 255) (list 30 offset))
	  ((< offset (+ 255 (* 255 256))) 
	   (let ((offset1 (modulo offset 256))
		 (offset2 (quotient offset 256)) )
	     (list 28 offset1 offset2) ) )
	  (else (static-wrong "too long jump" offset)))))
(define CONSTANT 
  (lambda (value)
    (cond ((eq? value #t)    (list 10))
	  ((eq? value #f)    (list 11))
	  ((eq? value '())   (list 12))
	  ((equal? value -1) (list 80))
	  ((equal? value 0)  (list 81))
	  ((equal? value 1)  (list 82))
	  ((equal? value 2)  (list 83))
	  ((equal? value 3)  (list 84))
	  ((and (integer? value)  ; immediate value
		(>= value 0)
		(< value 255) )
	   (list 79 value) )
	  (else (EXPLICIT-CONSTANT value)))))  
  ;;; All gotos have positive offsets (due to the generation)
(define JUMP-FALSE
  (lambda (offset)
    (cond ((< offset 255) (list 31 offset))
	  ((< offset (+ 255 (* 255 256))) 
	   (let ((offset1 (modulo offset 256))
		 (offset2 (quotient offset 256)) )
	     (list 29 offset1 offset2) ) )
	  (else (static-wrong "too long jump" offset)))))
(define CREATE-CLOSURE (lambda (offset) (list 40 offset)))
(define EXTEND-ENV (lambda () (list 32)))
(define UNLINK-ENV (lambda () (list 33)))
(define INVOKE1 
  (lambda (address)
    (case address
      ((car)     (list 90))
      ((cdr)     (list 91))
      ((pair?)   (list 92))
      ((symbol?) (list 93))
      ((display) (list 94))
      ((primitive?) (list 95))
      ((null?)   (list 96))
      ((continuation?) (list 97))
      ((eof-object?)   (list 98))
      (else (static-wrong "Cannot integrate" address)))))
(define POP-CONS-FRAME! (lambda (arity) (list 47 arity)))
(define PACK-FRAME! (lambda (arity) (list 44 arity)))
(define ARITY>=? (lambda (arity+1) (list 78 arity+1)))
(define PUSH-VALUE (lambda () (list 34)))
(define POP-ARG1 (lambda () (list 35)))
(define INVOKE2
  (lambda (address)
    (case address
      ((cons)     (list 100))
      ((eq?)      (list 101))
      ((set-car!) (list 102))
      ((set-cdr!) (list 103))
      ((+)        (list 104))
      ((-)        (list 105))
      ((=)        (list 106))
      ((<)        (list 107))
      ((>)        (list 108))
      ((*)        (list 109))
      ((<=)       (list 110))
      ((>=)       (list 111))
      ((remainder)(list 112))
      (else (static-wrong "Cannot integrate" address)))))
(define POP-ARG2 (lambda () (list 36)))
(define FUNCTION-INVOKE (lambda () (list 45)))  
(define PRESERVE-ENV (lambda () (list 37)))  
(define RESTORE-ENV (lambda () (list 38)))
(define ARITY=? 
  (lambda (arity+1)
    (case arity+1
      ((1 2 3 4) (list (+ 70 arity+1)))
      (else        (list 75 arity+1)))))  
(define RETURN (lambda () (list 43)))
(define POP-FUNCTION (lambda () (list 39)))
(define POP-FRAME! 
  (lambda (rank)
    (case rank
      ((0 1 2 3) (list (+ 60 rank)))
      (else      (list 64 rank)))))
(define FINISH (lambda () (list 20)))
(define ALLOCATE-FRAME
  (lambda (size)
    (case size
      ((0 1 2 3 4) (list (+ 50 size)))
      (else        (list 55 (+ size 1))))))

