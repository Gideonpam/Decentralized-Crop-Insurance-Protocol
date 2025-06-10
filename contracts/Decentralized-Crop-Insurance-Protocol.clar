(define-constant contract-owner tx-sender)
(define-constant min-contribution u1000000)
(define-constant claim-threshold u500000)
(define-constant pool-minimum u10000000)

(define-data-var insurance-pool uint u0)
(define-data-var total-farmers uint u0)
(define-data-var active-claims uint u0)

(define-map farmers 
  principal 
  {contribution: uint, 
   active: bool,
   last-claim: uint,
   location: (string-ascii 34)})

(define-map claims 
  uint 
  {farmer: principal,
   amount: uint,
   status: (string-ascii 8),
   weather-data: (string-ascii 34),
   timestamp: uint})

(define-public (join-pool (location (string-ascii 34)))
  (let ((current-contribution (default-to u0 (get contribution (map-get? farmers tx-sender)))))
    (if (is-some (map-get? farmers tx-sender))
      (err u1)
      (begin
        (map-set farmers 
          tx-sender 
          {contribution: min-contribution,
           active: true,
           last-claim: u0,
           location: location})
        (var-set total-farmers (+ (var-get total-farmers) u1))
        (var-set insurance-pool (+ (var-get insurance-pool) min-contribution))
        (ok true)))))

(define-public (contribute (amount uint))
  (let ((farmer-data (map-get? farmers tx-sender)))
    (if (and (>= amount min-contribution)
             (is-some farmer-data))
      (begin
        (map-set farmers 
          tx-sender 
          (merge (unwrap-panic farmer-data)
                 {contribution: (+ amount (get contribution (unwrap-panic farmer-data)))}))
        (var-set insurance-pool (+ (var-get insurance-pool) amount))
        (ok true))
      (err u2))))

(define-public (submit-claim (amount uint) (weather-data (string-ascii 34)))
  (let ((farmer-data (map-get? farmers tx-sender)))
    (if (and 
          (is-some farmer-data)
          (<= amount claim-threshold)
          (get active (unwrap-panic farmer-data)))
      (begin
        (var-set active-claims (+ (var-get active-claims) u1))
        (map-set claims 
          (var-get active-claims)
          {farmer: tx-sender,
           amount: amount,
           status: "pending",
           weather-data: weather-data,
           timestamp: stacks-block-height})
        (ok (var-get active-claims)))
      (err u3))))

(define-public (process-claim (claim-id uint) (approve bool))
  (let ((claim-data (map-get? claims claim-id)))
    (if (and 
          (is-eq tx-sender contract-owner)
          (is-some claim-data))
      (begin
        (if approve
          (begin
            (var-set insurance-pool (- (var-get insurance-pool) (get amount (unwrap-panic claim-data))))
            (map-set claims claim-id (merge (unwrap-panic claim-data) {status: "approved"})))
          (map-set claims claim-id (merge (unwrap-panic claim-data) {status: "rejected"})))
        (ok true))
      (err u4))))

(define-public (withdraw (amount uint))
  (let ((farmer-data (map-get? farmers tx-sender)))
    (if (and
          (is-some farmer-data)
          (<= amount (get contribution (unwrap-panic farmer-data)))
          (>= (- (var-get insurance-pool) amount) pool-minimum))
      (begin
        (map-set farmers 
          tx-sender 
          (merge (unwrap-panic farmer-data)
                 {contribution: (- (get contribution (unwrap-panic farmer-data)) amount)}))
        (var-set insurance-pool (- (var-get insurance-pool) amount))
        (ok true))
      (err u5))))

(define-read-only (get-pool-status)
  (ok {total-pool: (var-get insurance-pool),
       farmers: (var-get total-farmers),
       active-claims: (var-get active-claims)}))

(define-read-only (get-farmer-info (farmer principal))
  (ok (map-get? farmers farmer)))

(define-read-only (get-claim-info (claim-id uint))
  (ok (map-get? claims claim-id)))