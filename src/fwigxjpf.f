      module fwigxjpf
      use, intrinsic :: iso_fortran_env, only: spi=>int32, dpf=>real64
      implicit none

      interface

C     Initialisation

      subroutine fwig_table_init(max_two_j, wigner_type)
      use, intrinsic :: iso_fortran_env, only: spi=>int32, dpf=>real64
      integer(spi) max_two_j, wigner_type
      end subroutine

      subroutine fwig_temp_init(max_two_j)
      use, intrinsic :: iso_fortran_env, only: spi=>int32, dpf=>real64
      integer(spi) max_two_j
      end subroutine

      subroutine fwig_thread_temp_init(max_two_j)
      use, intrinsic :: iso_fortran_env, only: spi=>int32, dpf=>real64
      integer(spi) max_two_j
      end subroutine

C     Release

      subroutine fwig_table_free()
      end subroutine

      subroutine fwig_temp_free()
      end subroutine

C     3j

      function fwig3jj(two_j1, two_j2, two_j3,
     *                 two_m1, two_m2, two_m3)
      use, intrinsic :: iso_fortran_env, only: spi=>int32, dpf=>real64
      real(dpf) fwig3jj
      integer(spi) two_j1, two_j2, two_j3, two_m1, two_m2, two_m3
      end function

C     6j

      function fwig6jj(two_j1, two_j2, two_j3,
     *                 two_j4, two_j5, two_j6)
      use, intrinsic :: iso_fortran_env, only: spi=>int32, dpf=>real64
      real(dpf) fwig6jj
      integer(spi) two_j1, two_j2, two_j3, two_j4, two_j5, two_j6
      end function

C     9j

      function fwig9jj(two_j1, two_j2, two_j3,
     *                 two_j4, two_j5, two_j6,
     *                 two_j7, two_j8, two_j9)
      use, intrinsic :: iso_fortran_env, only: spi=>int32, dpf=>real64
      real(dpf) fwig9jj
      integer(spi) two_j1, two_j2, two_j3, two_j4, two_j5, two_j6,
     *          two_j7, two_j8, two_j9
      end function

C     -

      end interface

      end module fwigxjpf
