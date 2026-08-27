program test_jump_sanity
    use iso_fortran_env, only: i4 => int32, dp => real64
    use julienne_lite_mod
    use rndgen_mod, only: rndgen_xoshiro256_t
    implicit none

    type(rndgen_xoshiro256_t) :: rng_jump, rng_long
    real(dp) :: expected_jump(5), expected_long(5)
    real(dp) :: val
    integer(i4) :: i
    type(test_diagnosis_t) :: check

    real(dp), parameter :: TOL = 1e-15_dp

    ! =========================================================================
    ! ATENÇÃO: Substitua os valores abaixo pelos resultados obtidos
    ! rodando a implementação de referência (em C) ou o Fortran compilado
    ! sem otimização (-O0) após chamar jump() e long_jump().
    ! =========================================================================

    expected_jump = [ &
        1.38266450845463296e-01_dp, &
        2.62862640275542181e-01_dp, &
        8.42641962686211610e-01_dp, &
        4.06273175640926243e-01_dp, &
        8.72561497899373761e-01_dp  &
    ]

    expected_long = [ &
        8.47570411353368858e-01_dp, &
        1.46448209375597882e-01_dp, &
        6.56452921781133569e-01_dp, &
        8.01662513031499935e-01_dp, &
        6.46556439782861814e-01_dp  &
    ]
    ! =========================================================================

    print *, "=================================================="
    print *, "--- Sanity Check: Xoshiro256** Jumps"
    print *, "=================================================="

    ! --- TEST JUMP ---
    print *, "Testing JUMP (Seed 12345)..."
    call rng_jump%init(12345_i4)
    call rng_jump%jump()

    do i = 1, 5
        val = rng_jump%rnd()

        check = val .approximates. expected_jump(i) .within. TOL

        if (.not. check%test_passed()) then
            print *, ">>> [FAIL] JUMP mismatch at index", i
            print *, "    Got      : ", val
            print *, "    Expected : ", expected_jump(i)
            error stop "Compiler optimization broke the state during JUMP!"
        end if
    end do
    print *, "[OK] JUMP generated correct sequence."

    ! --- TEST LONG JUMP ---
    print *, "Testing LONG_JUMP (Seed 12345)..."
    call rng_long%init(12345_i4)
    call rng_long%long_jump()

    do i = 1, 5
        val = rng_long%rnd()

        check = val .approximates. expected_long(i) .within. TOL

        if (.not. check%test_passed()) then
            print *, ">>> [FAIL] LONG_JUMP mismatch at index", i
            print *, "    Got      : ", val
            print *, "    Expected : ", expected_long(i)
            error stop "Compiler optimization broke the state during LONG_JUMP!"
        end if
    end do
    print *, "[OK] LONG_JUMP generated correct sequence."

    print *, "=================================================="
    print *, "SUCCESS: Jump and Long Jump states verified!"
    print *, "=================================================="

end program test_jump_sanity