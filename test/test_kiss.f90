program test_compiler_sanity
    use iso_fortran_env, only: i4 => int32, dp => real64
    use julienne_lite_mod
    use rndgen_kiss_mod, only: rndgen_kiss_t
    implicit none

    type(rndgen_kiss_t) :: rng1, rng2
    real(dp) :: expected_rng1(5), expected_rng2(5)
    real(dp) :: val1, val2
    integer(i4) :: i
    type(test_diagnosis_t) :: check

    real(dp), parameter :: TOL = 1e-15_dp

    expected_rng1 = [ &
        5.5430411361157894E-002_dp, &
        0.37300996109843254_dp, &
        0.62941979337483644_dp, &
        0.70337013434618711_dp, &
        0.98156156297773123_dp  &
    ]

    expected_rng2 = [ &
        0.70423541264608502_dp, &
        0.64078524382784963_dp, &
        0.76425739564001560_dp, &
        0.32098745880648494_dp, &
        5.2882191259413958E-002_dp  &
    ]
    ! =========================================================================

    print *, "=================================================="
    print *, "--- Sanity Check: Compiler Optimization vs Xoshiro"
    print *, "=================================================="

    call rng1%init(12345_i4)
    call rng2%init(12346_i4)

    ! --- TEST RNG 1 ---
    print *, "Testing RNG1 (Seed 12345)..."
    do i = 1, 5
        val1 = rng1%rnd()

        check = val1 .approximates. expected_rng1(i) .within. TOL

        if (.not. check%test_passed()) then
            print *, ">>> [FAIL] RNG1 mismatch at index", i
            print *, "    Got      : ", val1
            print *, "    Expected : ", expected_rng1(i)
            error stop "Compiler optimization broke the state of RNG1!"
        end if
    end do
    print *, "[OK] RNG1 generated correct sequence."

    ! --- TEST RNG 2 ---
    print *, "Testing RNG2 (Seed 12346)..."
    do i = 1, 5
        val2 = rng2%rnd()

        check = val2 .approximates. expected_rng2(i) .within. TOL

        if (.not. check%test_passed()) then
            print *, ">>> [FAIL] RNG2 mismatch at index", i
            print *, "    Got      : ", val2
            print *, "    Expected : ", expected_rng2(i)
            error stop "Compiler optimization broke the state of RNG2!"
        end if
    end do
    print *, "[OK] RNG2 generated correct sequence."

    print *, "=================================================="
    print *, "SUCCESS: State isolation and bitwise math passed!"
    print *, "=================================================="

end program test_compiler_sanity