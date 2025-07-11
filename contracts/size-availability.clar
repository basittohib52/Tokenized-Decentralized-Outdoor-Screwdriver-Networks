;; Size Availability Contract
;; Manages screwdriver inventory for different screw types

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_INPUT (err u400))
(define-constant ERR_INSUFFICIENT_INVENTORY (err u409))

;; Data Variables
(define-data-var next-inventory-id uint u1)

;; Data Maps
(define-map inventory
  { screwdriver-type: (string-ascii 20), size: uint }
  {
    total-count: uint,
    available-count: uint,
    reserved-count: uint,
    manager: principal,
    last-updated: uint
  }
)

(define-map reservations
  { reservation-id: uint }
  {
    user: principal,
    screwdriver-type: (string-ascii 20),
    size: uint,
    quantity: uint,
    reservation-time: uint,
    expiry-time: uint,
    is-active: bool
  }
)

(define-map user-reservations
  { user: principal, screwdriver-type: (string-ascii 20), size: uint }
  { reservation-id: uint }
)

;; Public Functions

;; Add inventory for a specific screwdriver type and size
(define-public (add-inventory (screwdriver-type (string-ascii 20)) (size uint) (quantity uint))
  (let (
    (current-inventory (default-to
      { total-count: u0, available-count: u0, reserved-count: u0, manager: tx-sender, last-updated: block-height }
      (map-get? inventory { screwdriver-type: screwdriver-type, size: size })
    ))
  )
    (if (and (> (len screwdriver-type) u0) (> size u0) (> quantity u0))
      (begin
        (map-set inventory
          { screwdriver-type: screwdriver-type, size: size }
          {
            total-count: (+ (get total-count current-inventory) quantity),
            available-count: (+ (get available-count current-inventory) quantity),
            reserved-count: (get reserved-count current-inventory),
            manager: (get manager current-inventory),
            last-updated: block-height
          }
        )
        (ok true)
      )
      ERR_INVALID_INPUT
    )
  )
)

;; Reserve screwdrivers for a user
(define-public (reserve-screwdrivers (screwdriver-type (string-ascii 20)) (size uint) (quantity uint) (duration-blocks uint))
  (match (map-get? inventory { screwdriver-type: screwdriver-type, size: size })
    inventory-data
    (if (>= (get available-count inventory-data) quantity)
      (let (
        (reservation-id (var-get next-inventory-id))
        (expiry-time (+ block-height duration-blocks))
      )
        (map-set inventory
          { screwdriver-type: screwdriver-type, size: size }
          (merge inventory-data {
            available-count: (- (get available-count inventory-data) quantity),
            reserved-count: (+ (get reserved-count inventory-data) quantity),
            last-updated: block-height
          })
        )
        (map-set reservations
          { reservation-id: reservation-id }
          {
            user: tx-sender,
            screwdriver-type: screwdriver-type,
            size: size,
            quantity: quantity,
            reservation-time: block-height,
            expiry-time: expiry-time,
            is-active: true
          }
        )
        (map-set user-reservations
          { user: tx-sender, screwdriver-type: screwdriver-type, size: size }
          { reservation-id: reservation-id }
        )
        (var-set next-inventory-id (+ reservation-id u1))
        (ok reservation-id)
      )
      ERR_INSUFFICIENT_INVENTORY
    )
    ERR_NOT_FOUND
  )
)

;; Cancel reservation
(define-public (cancel-reservation (reservation-id uint))
  (match (map-get? reservations { reservation-id: reservation-id })
    reservation-data
    (if (and (is-eq (get user reservation-data) tx-sender) (get is-active reservation-data))
      (match (map-get? inventory { screwdriver-type: (get screwdriver-type reservation-data), size: (get size reservation-data) })
        inventory-data
        (begin
          (map-set inventory
            { screwdriver-type: (get screwdriver-type reservation-data), size: (get size reservation-data) }
            (merge inventory-data {
              available-count: (+ (get available-count inventory-data) (get quantity reservation-data)),
              reserved-count: (- (get reserved-count inventory-data) (get quantity reservation-data)),
              last-updated: block-height
            })
          )
          (map-set reservations
            { reservation-id: reservation-id }
            (merge reservation-data { is-active: false })
          )
          (ok true)
        )
        ERR_NOT_FOUND
      )
      ERR_UNAUTHORIZED
    )
    ERR_NOT_FOUND
  )
)

;; Fulfill reservation (mark as used)
(define-public (fulfill-reservation (reservation-id uint))
  (match (map-get? reservations { reservation-id: reservation-id })
    reservation-data
    (if (and (is-eq (get user reservation-data) tx-sender) (get is-active reservation-data))
      (begin
        (map-set reservations
          { reservation-id: reservation-id }
          (merge reservation-data { is-active: false })
        )
        (ok true)
      )
      ERR_UNAUTHORIZED
    )
    ERR_NOT_FOUND
  )
)

;; Return screwdrivers to inventory
(define-public (return-screwdrivers (screwdriver-type (string-ascii 20)) (size uint) (quantity uint))
  (match (map-get? inventory { screwdriver-type: screwdriver-type, size: size })
    inventory-data
    (if (>= (get reserved-count inventory-data) quantity)
      (begin
        (map-set inventory
          { screwdriver-type: screwdriver-type, size: size }
          (merge inventory-data {
            available-count: (+ (get available-count inventory-data) quantity),
            reserved-count: (- (get reserved-count inventory-data) quantity),
            last-updated: block-height
          })
        )
        (ok true)
      )
      ERR_INVALID_INPUT
    )
    ERR_NOT_FOUND
  )
)

;; Update inventory manager
(define-public (update-manager (screwdriver-type (string-ascii 20)) (size uint) (new-manager principal))
  (match (map-get? inventory { screwdriver-type: screwdriver-type, size: size })
    inventory-data
    (if (is-eq (get manager inventory-data) tx-sender)
      (begin
        (map-set inventory
          { screwdriver-type: screwdriver-type, size: size }
          (merge inventory-data { manager: new-manager })
        )
        (ok true)
      )
      ERR_UNAUTHORIZED
    )
    ERR_NOT_FOUND
  )
)

;; Read-only Functions

;; Check availability of specific screwdriver type and size
(define-read-only (check-availability (screwdriver-type (string-ascii 20)) (size uint))
  (match (map-get? inventory { screwdriver-type: screwdriver-type, size: size })
    inventory-data
    (get available-count inventory-data)
    u0
  )
)

;; Get full inventory details
(define-read-only (get-inventory (screwdriver-type (string-ascii 20)) (size uint))
  (map-get? inventory { screwdriver-type: screwdriver-type, size: size })
)

;; Get reservation details
(define-read-only (get-reservation (reservation-id uint))
  (map-get? reservations { reservation-id: reservation-id })
)

;; Get user's reservation for specific type and size
(define-read-only (get-user-reservation (user principal) (screwdriver-type (string-ascii 20)) (size uint))
  (match (map-get? user-reservations { user: user, screwdriver-type: screwdriver-type, size: size })
    reservation-ref
    (map-get? reservations { reservation-id: (get reservation-id reservation-ref) })
    none
  )
)

;; Check if reservation is expired
(define-read-only (is-reservation-expired (reservation-id uint))
  (match (map-get? reservations { reservation-id: reservation-id })
    reservation-data
    (> block-height (get expiry-time reservation-data))
    true
  )
)

;; Get total inventory count
(define-read-only (get-total-count (screwdriver-type (string-ascii 20)) (size uint))
  (match (map-get? inventory { screwdriver-type: screwdriver-type, size: size })
    inventory-data
    (get total-count inventory-data)
    u0
  )
)
