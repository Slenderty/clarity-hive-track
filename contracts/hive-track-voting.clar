;; Voting contract for HiveTrack
(define-map votes
  { proposal-id: uint, voter: principal }
  { vote: bool }
)

;; Error codes
(define-constant ERR-ALREADY-VOTED (err u200))
(define-constant ERR-PROPOSAL-INACTIVE (err u201))

;; Voting functions
(define-public (cast-vote (proposal-id uint) (vote bool))
  (let ((sender tx-sender))
    (asserts! (is-none (has-voted proposal-id sender)) ERR-ALREADY-VOTED)
    (asserts! (is-proposal-active proposal-id) ERR-PROPOSAL-INACTIVE)
    (map-set votes 
      { proposal-id: proposal-id, voter: sender }
      { vote: vote }
    )
    (ok true)
  )
)

;; Read-only functions
(define-read-only (has-voted (proposal-id uint) (voter principal))
  (map-get? votes { proposal-id: proposal-id, voter: voter })
)

(define-read-only (is-proposal-active (proposal-id uint))
  (match (contract-call? .hive-track get-proposal proposal-id)
    proposal (is-eq (get status proposal) "active")
    false
  )
)
