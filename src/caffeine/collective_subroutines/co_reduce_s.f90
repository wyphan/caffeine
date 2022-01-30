! Copyright (c), The Regents of the University of California
! Terms of use are as specified in LICENSE.txt
submodule(collective_subroutines_m) co_reduce_s
  use iso_c_binding, only : &
    c_int64_t, c_ptr, c_size_t, c_loc, c_double, c_null_ptr, c_funptr, c_funloc, c_associated, c_f_pointer
  use assert_m, only : assert

  implicit none

  procedure(c_int32_t_operation), pointer :: c_int32_t_op_ptr => null()
  procedure(c_float_operation), pointer :: c_float_op_ptr => null()

contains

  subroutine Coll_ReduceSub(arg1, arg2_and_out, count, cdata) bind(C)
    type(c_ptr), value :: arg1         !! "Left" operands
    type(c_ptr), value :: arg2_and_out !! "Right" operands and result
    integer(c_size_t), value :: count  !! Operand count
    type(c_ptr), value ::  cdata       !! Client data
    integer(c_int32_t), pointer :: lhs, rhs_and_result
    
    call assert(all([c_associated(arg1), c_associated(arg2_and_out)]), "Coll_ReduceSub: operands associated")

    call c_f_pointer(arg1, lhs)
    call c_f_pointer(arg2_and_out, rhs_and_result)

    call assert(all([associated(lhs), associated(rhs_and_result)]), "Coll_ReduceSub: operands associated")
  
    rhs_and_result = c_int32_t_op_ptr(lhs, rhs_and_result)
    
  end subroutine

  subroutine Coll_ReduceSub_c_float(arg1, arg2_and_out, count, cdata) bind(C)
    type(c_ptr), value :: arg1         !! "Left" operands
    type(c_ptr), value :: arg2_and_out !! "Right" operands and result
    integer(c_size_t), value :: count  !! Operand count
    type(c_ptr), value ::  cdata       !! Client data
    real(c_float), pointer :: lhs, rhs_and_result
    
    call assert(all([c_associated(arg1), c_associated(arg2_and_out)]), "Coll_ReduceSub: operands associated")

    call c_f_pointer(arg1, lhs)
    call c_f_pointer(arg2_and_out, rhs_and_result)

    call assert(all([associated(lhs), associated(rhs_and_result)]), "Coll_ReduceSub: operands associated")
  
    rhs_and_result = c_float_op_ptr(lhs, rhs_and_result)
    
  end subroutine

  module procedure caf_co_reduce_c_int32_t

    interface

      subroutine c_co_reduce_int32(c_loc_a, Nelem, c_loc_stat, c_loc_result_image, Coll_ReduceSub) bind(C)
        import c_ptr, c_size_t, c_funptr
        type(c_ptr), value :: c_loc_a, c_loc_stat, c_loc_result_image
        integer(c_size_t), value :: Nelem
        type(c_funptr), value :: Coll_ReduceSub
      end subroutine

    end interface

    type(c_ptr) stat_ptr ,result_image_ptr

    call assert(associated(operation), "caf_co_reduce_c_int32_t: operation associated")

    c_int32_t_op_ptr => operation

    if (present(stat)) then
      stat_ptr = c_loc(stat)
    else
      stat_ptr = c_null_ptr
    end if

    if (present(result_image)) then
      result_image_ptr = c_loc(result_image)
    else
      result_image_ptr = c_null_ptr
    end if

    select rank(a)
      rank(0)
         call c_co_reduce_int32(c_loc(a), 1_c_size_t, stat_ptr, result_image_ptr, c_funloc(Coll_ReduceSub))
      rank default
         error stop "unsupported rank"
    end select

  end procedure

  module procedure caf_co_reduce_c_float

    interface

      subroutine c_co_reduce_float(c_loc_a, Nelem, c_loc_stat, c_loc_result_image, Coll_ReduceSub) bind(C)
        import c_ptr, c_size_t, c_funptr
        type(c_ptr), value :: c_loc_a, c_loc_stat, c_loc_result_image
        integer(c_size_t), value :: Nelem
        type(c_funptr), value :: Coll_ReduceSub
      end subroutine

    end interface

    type(c_ptr) stat_ptr ,result_image_ptr

    call assert(associated(operation), "caf_co_reduce_c_float: operation associated")

    c_float_op_ptr => operation

    if (present(stat)) then
      stat_ptr = c_loc(stat)
    else
      stat_ptr = c_null_ptr
    end if

    if (present(result_image)) then
      result_image_ptr = c_loc(result_image)
    else
      result_image_ptr = c_null_ptr
    end if

    select rank(a)
      rank(0)
         call c_co_reduce_float(c_loc(a), 1_c_size_t, stat_ptr, result_image_ptr, c_funloc(Coll_ReduceSub_c_float))
      rank default
         error stop "unsupported rank"
    end select

  end procedure

end submodule co_reduce_s
