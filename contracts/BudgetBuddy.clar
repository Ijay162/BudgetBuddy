;; Budget Buddy Smart Contract
;; Enables users to create budgets, track expenses, income, and manage their financial goals
;; Data Maps
(define-map budget-profiles
    {owner: principal}  ;; Unique identifier for each user
    {
        budget-limit: uint,
        remaining-balance: uint,
        cumulative-income: uint
    }
)
(define-map expense-records
    {
        owner: principal,
        expense-id: uint
    }  
    {
        value: uint,
        type: (string-ascii 9),
        recorded-at: uint
    }
)
(define-map income-records
    {
        owner: principal,
        income-id: uint
    }
    {
        value: uint,
        source: (string-ascii 9),
        recorded-at: uint
    }
)
;; Data Variables
(define-data-var expense-counter uint u0) ;; Counter for expense ID
(define-data-var income-counter uint u0)  ;; Counter for income ID
;; Error Constants
(define-constant ERR-INVALID-BUDGET (err u100))
(define-constant ERR-PROFILE-NOT-SET (err u101))
(define-constant ERR-INVALID-VALUE (err u102))
(define-constant ERR-INSUFFICIENT-BALANCE (err u103))
(define-constant ERR-NO-PROFILE-FOUND (err u104))
(define-constant ERR-EXPENSE-NOT-FOUND (err u105))
(define-constant ERR-INCOME-NOT-FOUND (err u106))
(define-constant ERR-INVALID-TYPE (err u107))
(define-constant ERR-INVALID-SOURCE (err u108))
;; Valid types and sources lists
(define-constant VALID-EXPENSE-TYPES (list 
    "basics"
    "housing"
    "transport"
    "utilities"
    "health"
    "leisure"
    "misc"
))
(define-constant VALID-INCOME-SOURCES (list
    "salary"
    "business"
    "investment"
    "freelance"
    "misc"
))
;; Helper Functions
(define-private (is-valid-text (input (string-ascii 10)))
    (and
        (not (is-eq input ""))
        (<= (len input) u10)
    )
)
(define-private (is-valid-type (type (string-ascii 9)))
    (and
        (is-valid-text type)
        (is-some (index-of VALID-EXPENSE-TYPES type))
    )
)
(define-private (is-valid-source (source (string-ascii 9)))
    (and
        (is-valid-text source)
        (is-some (index-of VALID-INCOME-SOURCES source))
    )
)
;; Public Functions
;; Function to set or update a budget profile for a user
(define-public (set-budget (budget-limit uint))
    (begin
        (asserts! (> budget-limit u0) ERR-INVALID-BUDGET)
        (let ((current-profile (map-get? budget-profiles {owner: tx-sender})))
            (map-set budget-profiles
                {owner: tx-sender}
                {
                    budget-limit: budget-limit,
                    remaining-balance: budget-limit,
                    cumulative-income: (match current-profile
                        profile (get cumulative-income profile)
                        u0)
                }
            )
            (ok budget-limit)
        )
    )
)
;; Function to add an expense
(define-public (record-expense (value uint) (type (string-ascii 9)))
    (let ((expense-id (var-get expense-counter)))
        (begin
            (asserts! (is-some (map-get? budget-profiles {owner: tx-sender})) ERR-PROFILE-NOT-SET)
            (asserts! (> value u0) ERR-INVALID-VALUE)
            (asserts! (is-valid-type type) ERR-INVALID-TYPE)
            (let ((current-profile (unwrap-panic (map-get? budget-profiles {owner: tx-sender}))))
                (asserts! (>= (get remaining-balance current-profile) value) ERR-INSUFFICIENT-BALANCE)
                ;; Update remaining balance
                (map-set budget-profiles
                    {owner: tx-sender}
                    {
                        budget-limit: (get budget-limit current-profile),
                        remaining-balance: (- (get remaining-balance current-profile) value),
                        cumulative-income: (get cumulative-income current-profile)
                    }
                )
                ;; Store the expense
                (map-set expense-records
                    {
                        owner: tx-sender,
                        expense-id: expense-id
                    }
                    {
                        value: value,
                        type: type,
                        recorded-at: burn-block-height
                    }
                )
                ;; Increment counter
                (var-set expense-counter (+ expense-id u1))
                (ok expense-id)
            )
        )
    )
)
;; Function to add income
(define-public (record-income (value uint) (source (string-ascii 9)))
    (let ((income-id (var-get income-counter)))
        (begin
            (asserts! (> value u0) ERR-INVALID-VALUE)
            (asserts! (is-valid-source source) ERR-INVALID-SOURCE)
            ;; Initialize budget profile if not exists
            (match (map-get? budget-profiles {owner: tx-sender})
                current-profile 
                (map-set budget-profiles
                    {owner: tx-sender}
                    {
                        budget-limit: (get budget-limit current-profile),
                        remaining-balance: (get remaining-balance current-profile),
                        cumulative-income: (+ (get cumulative-income current-profile) value)
                    }
                )
                (map-set budget-profiles
                    {owner: tx-sender}
                    {
                        budget-limit: u0,
                        remaining-balance: u0,
                        cumulative-income: value
                    }
                )
            )
            ;; Store the income entry
            (map-set income-records
                {
                    owner: tx-sender,
                    income-id: income-id
                }
                {
                    value: value,
                    source: source,
                    recorded-at: burn-block-height
                }
            )
            ;; Increment counter
            (var-set income-counter (+ income-id u1))
            (ok income-id)
        )
    )
)
;; Read-only Functions
;; Function to get the remaining balance for the user
(define-read-only (get-remaining-balance (owner principal))
    (match (map-get? budget-profiles {owner: owner})
        profile (ok (get remaining-balance profile))
        ERR-NO-PROFILE-FOUND
    )
)
;; Function to get cumulative income for the user
(define-read-only (get-cumulative-income (owner principal))
    (match (map-get? budget-profiles {owner: owner})
        profile (ok (get cumulative-income profile))
        ERR-NO-PROFILE-FOUND
    )
)
;; Function to retrieve details of an expense by ID
(define-read-only (get-expense (expense-id uint))
    (match (map-get? expense-records {owner: tx-sender, expense-id: expense-id})
        expense (ok expense)
        ERR-EXPENSE-NOT-FOUND
    )
)
;; Function to retrieve details of an income entry by ID
(define-read-only (get-income-entry (income-id uint))
    (match (map-get? income-records {owner: tx-sender, income-id: income-id})
        income (ok income)
        ERR-INCOME-NOT-FOUND
    )
)
;; Function to get valid expense types
(define-read-only (get-valid-expense-types)
    (ok VALID-EXPENSE-TYPES)
)
;; Function to get valid income sources
(define-read-only (get-valid-income-sources)
    (ok VALID-INCOME-SOURCES)
)
;; Function to reset the budget profile and all records for a user
(define-public (reset-budget-profile)
    (begin
        (map-delete budget-profiles {owner: tx-sender})
        (ok "Budget profile reset successful")
    )
)