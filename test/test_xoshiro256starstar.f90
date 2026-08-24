program test_compiler_sanity
    use iso_fortran_env, only: i4 => int32, dp => real64
    use julienne_lite_mod
    use rndgen_mod, only: rndgen_xoshiro256_t
    implicit none

    type(rndgen_xoshiro256_t) :: rng1, rng2
    real(dp) :: expected_rng1(5), expected_rng2(5)
    real(dp) :: val1, val2
    integer(i4) :: i
    type(test_diagnosis_t) :: check

    real(dp), parameter :: TOL = 1e-15_dp

    expected_rng1 = [ &
        3.0793636460267559E-002_dp, &
        0.72857496089312612_dp, &
        0.65518091518415367_dp, &
        0.85440657257298869_dp, &
        5.6020733862305327E-003_dp  &
    ]

    expected_rng2 = [ &
        0.68441441568221284_dp, &
        0.26112886430173543_dp, &
        5.4107914148842751E-002_dp, &
        0.72439635406077707_dp, &
        0.62556826697810008_dp  &
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