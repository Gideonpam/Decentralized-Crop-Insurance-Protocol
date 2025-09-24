(define-constant contract-owner tx-sender)
(define-constant min-contribution u1000000)
(define-constant claim-threshold u500000)
(define-constant pool-minimum u10000000)

(define-data-var insurance-pool uint u0)
(define-data-var total-farmers uint u0)
(define-data-var active-claims uint u0)
(define-data-var premium-adjustment-period uint u100)
(define-data-var auto-approval-threshold uint u3)
(define-data-var total-auto-approvals uint u0)
(define-data-var total-verifications uint u0)

(define-map farmers 
  principal 
  {contribution: uint, 
   active: bool,
   last-claim: uint,
   location: (string-ascii 34),
   claims-count: uint,
   premium-rate: uint})

(define-map claims
   uint
   {farmer: principal,
    amount: uint,
    status: (string-ascii 8),
    weather-data: (string-ascii 34),
    timestamp: uint,
    auto-verified: bool,
    weather-severity: uint})

(define-constant referral-bonus u50000)

(define-map referrals principal principal)

(define-public (join-pool (location (string-ascii 34)) (referrer (optional principal)))
   (let ((current-contribution (default-to u0 (get contribution (map-get? farmers tx-sender)))))
     (if (is-some (map-get? farmers tx-sender))
       (err u1)
       (begin
         (map-set farmers
           tx-sender
           {contribution: min-contribution,
            active: true,
            last-claim: u0,
            location: location,
            claims-count: u0,
            premium-rate: u100})
         (var-set total-farmers (+ (var-get total-farmers) u1))
         (var-set insurance-pool (+ (var-get insurance-pool) min-contribution))
         (match referrer
           ref
           (if (and (is-some (map-get? farmers ref)) (get active (unwrap-panic (map-get? farmers ref))))
             (begin
               (map-set referrals tx-sender ref)
               (let ((referrer-data (unwrap-panic (map-get? farmers ref))))
                 (if (>= (var-get insurance-pool) (+ pool-minimum referral-bonus))
                   (begin
                     (map-set farmers ref (merge referrer-data {contribution: (+ (get contribution referrer-data) referral-bonus)}))
                     (var-set insurance-pool (- (var-get insurance-pool) referral-bonus)))
                   true)))
             true)
           true)
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
  (let ((farmer-data (map-get? farmers tx-sender))
        (weather-severity (extract-weather-severity weather-data)))
    (if (and 
          (is-some farmer-data)
          (<= amount claim-threshold)
          (get active (unwrap-panic farmer-data)))
      (begin
        (var-set active-claims (+ (var-get active-claims) u1))
        (let ((claim-id (var-get active-claims))
              (should-auto-approve (>= weather-severity (var-get auto-approval-threshold))))
          (map-set claims 
            claim-id
            {farmer: tx-sender,
             amount: amount,
             status: (if should-auto-approve "approved" "pending"),
             weather-data: weather-data,
             timestamp: stacks-block-height,
             auto-verified: should-auto-approve,
             weather-severity: weather-severity})
          (if should-auto-approve
            (begin
              (var-set insurance-pool (- (var-get insurance-pool) amount))
              (var-set total-auto-approvals (+ (var-get total-auto-approvals) u1)))
            true)
          (var-set total-verifications (+ (var-get total-verifications) u1))
          (map-set farmers 
            tx-sender 
            (merge (unwrap-panic farmer-data)
                   {claims-count: (+ (get claims-count (unwrap-panic farmer-data)) u1)}))
          (ok claim-id)))
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

(define-read-only (calculate-premium (farmer principal))
  (match (map-get? farmers farmer)
    farmer-data
    (let ((claims-count (get claims-count farmer-data))
          (base-rate u100))
      (if (> claims-count u3)
        (+ base-rate (* (- claims-count u3) u20))
        (if (and (> claims-count u0) (<= claims-count u1))
          (- base-rate u10)
          base-rate)))
    u100))

(define-public (adjust-premium (farmer principal))
  (match (map-get? farmers farmer)
    farmer-data
    (let ((current-block stacks-block-height)
          (new-premium-rate (calculate-premium farmer)))
      (if (> (- current-block (get last-claim farmer-data)) (var-get premium-adjustment-period))
        (begin
          (map-set farmers 
            farmer 
            (merge farmer-data {premium-rate: new-premium-rate}))
          (ok new-premium-rate))
        (err u6)))
    (err u7)))

(define-public (get-required-contribution (farmer principal))
  (match (map-get? farmers farmer)
    farmer-data
    (let ((premium-rate (get premium-rate farmer-data)))
      (ok (/ (* min-contribution premium-rate) u100)))
    (ok min-contribution)))

(define-read-only (get-farmer-risk-score (farmer principal))
  (match (map-get? farmers farmer)
    farmer-data
    (let ((claims-count (get claims-count farmer-data))
          (contribution (get contribution farmer-data)))
      (if (> claims-count u0)
        (ok (/ contribution claims-count))
        (ok u0)))
    (err u8)))

(define-read-only (extract-weather-severity (weather-data (string-ascii 34)))
  (let ((first-char (element-at weather-data u0)))
    (match first-char
      char-val
      (if (is-eq char-val "5") u5
        (if (is-eq char-val "4") u4
          (if (is-eq char-val "3") u3
            (if (is-eq char-val "2") u2
              (if (is-eq char-val "1") u1
                u0)))))
      u0)))

(define-public (auto-verify-claim (claim-id uint))
  (match (map-get? claims claim-id)
    claim-data
    (let ((weather-severity (get weather-severity claim-data))
          (current-status (get status claim-data)))
      (if (and 
            (is-eq current-status "pending")
            (>= weather-severity (var-get auto-approval-threshold)))
        (begin
          (map-set claims 
            claim-id 
            (merge claim-data 
                   {status: "approved", auto-verified: true}))
          (var-set insurance-pool (- (var-get insurance-pool) (get amount claim-data)))
          (var-set total-auto-approvals (+ (var-get total-auto-approvals) u1))
          (ok true))
        (err u9)))
    (err u10)))

(define-public (update-verification-threshold (new-threshold uint))
  (if (is-eq tx-sender contract-owner)
    (begin
      (var-set auto-approval-threshold new-threshold)
      (ok true))
    (err u11)))

(define-read-only (get-verification-stats)
  (ok {total-verifications: (var-get total-verifications),
       auto-approvals: (var-get total-auto-approvals),
       threshold: (var-get auto-approval-threshold),
       approval-rate: (if (> (var-get total-verifications) u0)
                       (/ (* (var-get total-auto-approvals) u100) (var-get total-verifications))
                       u0)}))

(define-read-only (check-auto-approval-eligibility (weather-data (string-ascii 34)) (amount uint))
  (let ((severity (extract-weather-severity weather-data)))
    (ok {severity: severity,
         threshold: (var-get auto-approval-threshold),
         eligible: (and
                     (>= severity (var-get auto-approval-threshold))
                     (<= amount claim-threshold))})))

(define-data-var proposal-counter uint u0)

(define-map proposals
  uint
  {proposer: principal,
   proposed-threshold: uint,
   votes-for: uint,
   votes-against: uint,
   end-block: uint})

(define-map votes
  {proposal-id: uint, voter: principal}
  bool)

(define-constant voting-period u100)

(define-public (propose-threshold-change (new-threshold uint))
  (let ((farmer-data (map-get? farmers tx-sender)))
    (if (and (is-some farmer-data) (get active (unwrap-panic farmer-data)))
      (let ((proposal-id (+ (var-get proposal-counter) u1)))
        (var-set proposal-counter proposal-id)
        (map-set proposals
          proposal-id
          {proposer: tx-sender,
           proposed-threshold: new-threshold,
           votes-for: u0,
           votes-against: u0,
           end-block: (+ stacks-block-height voting-period)})
        (ok proposal-id))
      (err u12))))

(define-public (vote-on-proposal (proposal-id uint) (vote bool))
  (let ((proposal-data (map-get? proposals proposal-id))
        (farmer-data (map-get? farmers tx-sender))
        (vote-key {proposal-id: proposal-id, voter: tx-sender}))
    (if (and (is-some proposal-data)
             (is-some farmer-data)
             (get active (unwrap-panic farmer-data))
             (is-none (map-get? votes vote-key))
             (< stacks-block-height (get end-block (unwrap-panic proposal-data))))
      (let ((current-data (unwrap-panic proposal-data))
            (current-for (get votes-for current-data))
            (current-against (get votes-against current-data)))
        (begin
          (map-set votes vote-key true)
          (map-set proposals
            proposal-id
            (merge current-data
                   {votes-for: (if vote (+ current-for u1) current-for),
                    votes-against: (if vote current-against (+ current-against u1))}))
          (ok true)))
      (err u13))))

(define-public (execute-proposal (proposal-id uint))
  (let ((proposal-data (map-get? proposals proposal-id)))
    (if (and (is-some proposal-data)
             (>= stacks-block-height (get end-block (unwrap-panic proposal-data))))
      (let ((votes-for (get votes-for (unwrap-panic proposal-data)))
            (votes-against (get votes-against (unwrap-panic proposal-data))))
        (if (> votes-for votes-against)
          (begin
            (var-set auto-approval-threshold (get proposed-threshold (unwrap-panic proposal-data)))
            (ok true))
          (ok false)))
      (err u14))))

(define-read-only (get-proposal-info (proposal-id uint))
  (ok (map-get? proposals proposal-id)))