program demo_parallel_xoshiro
    use iso_fortran_env, only: i4 => int32, i8 => int64, dp => real64
    !$ use omp_lib
    use rndgen_mod, only: rndgen_xoshiro256_t
    implicit none

    type(rndgen_xoshiro256_t) :: master_rng
    type(rndgen_xoshiro256_t), allocatable :: thread_rng(:)

    integer(i4) :: num_threads, tid
    integer(i8) :: i, total_samples, inside_circle
    real(dp) :: x, y, pi_est
    real(dp) :: wall_start, wall_end, cpu_start, cpu_end

    total_samples = 100000000_i8
    inside_circle = 0_i8

    ! ---------------------------------------------------------
    ! FALLBACK SERIAL (overridden if OpenMP is active)
    ! ---------------------------------------------------------
    num_threads = 1

    !$omp parallel
    !$omp master
    !$ num_threads = omp_get_num_threads()
    !$omp end master
    !$omp end parallel

    print *, "=================================================="
    print *, "Starting Monte Carlo Pi with", num_threads, "threads"
    print *, "=================================================="

    call master_rng%init(12345_i8)
    allocate(thread_rng(0:num_threads-1))

    do i = 0, num_threads - 1
        thread_rng(i) = master_rng
        call master_rng%jump()
    end do

    print *, "[OK] PRNG states successfully jumped and distributed."

    ! Timers initialization (Fallback is CPU time)
    call cpu_time(cpu_start)
    wall_start = cpu_start
    !$ wall_start = omp_get_wtime()

    !$omp parallel do reduction(+:inside_circle) private(x, y, tid)
    do i = 1, total_samples
        ! Fallback for thread ID
        tid = 0
        !$ tid = omp_get_thread_num()

        x = thread_rng(tid)%rnd()
        y = thread_rng(tid)%rnd()

        if (x*x + y*y <= 1.0_dp) then
            inside_circle = inside_circle + 1_i8
        end if
    end do
    !$omp end parallel do

    ! Timers finalization
    call cpu_time(cpu_end)
    wall_end = cpu_end
    !$ wall_end = omp_get_wtime()

    pi_est = 4.0_dp * real(inside_circle, dp) / real(total_samples, dp)

    ! ---------------------------------------------------------
    ! Results Output
    ! ---------------------------------------------------------
    print *, "Total Samples    : ", total_samples
    print *, "Pi Estimate      : ", pi_est
    print *, "Relative Error   : ", abs(pi_est - 3.1415926535897932_dp)
    print *, "Wall Time (s)    : ", wall_end - wall_start
    print *, "CPU Time (s)     : ", cpu_end - cpu_start
    print *, "=================================================="

end program demo_parallel_xoshiro