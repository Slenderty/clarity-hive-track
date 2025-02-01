;; Define data maps and vars
(define-map members 
  { member-id: principal } 
  {
    joined-at: uint,
    contribution-score: uint,
    active: bool
  }
)

(define-map proposals
  { proposal-id: uint }
  {
    creator: principal,
    title: (string-utf8 256),
    description: (string-utf8 1024),
    status: (string-ascii 20),
    created-at: uint,
    votes-for: uint,
    votes-against: uint
  }
)

(define-data-var proposal-counter uint u0)
(define-data-var admin principal tx-sender)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-MEMBER-EXISTS (err u101))
(define-constant ERR-NOT-MEMBER (err u102))
(define-constant ERR-INVALID-PROPOSAL (err u103))

;; Member management functions
(define-public (register-member)
  (let ((sender tx-sender))
    (asserts! (is-none (get-member sender)) ERR-MEMBER-EXISTS)
    (ok (map-set members
      { member-id: sender }
      {
        joined-at: block-height,
        contribution-score: u0,
        active: true
      }
    ))
  )
)

(define-public (update-member-status (member principal) (status bool))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
    (ok (map-set members
      { member-id: member }
      (merge (unwrap! (get-member member) ERR-NOT-MEMBER)
        { active: status }
      )
    ))
  )
)

;; Proposal management
(define-public (create-proposal (title (string-utf8 256)) (description (string-utf8 1024)))
  (let (
    (sender tx-sender)
    (proposal-id (+ (var-get proposal-counter) u1))
  )
    (asserts! (is-some (get-member sender)) ERR-NOT-MEMBER)
    (var-set proposal-counter proposal-id)
    (ok (map-set proposals
      { proposal-id: proposal-id }
      {
        creator: sender,
        title: title,
        description: description,
        status: "active",
        created-at: block-height,
        votes-for: u0,
        votes-against: u0
      }
    ))
  )
)

;; Read-only functions
(define-read-only (get-member (member principal))
  (map-get? members { member-id: member })
)

(define-read-only (get-proposal (id uint))
  (map-get? proposals { proposal-id: id })
)
