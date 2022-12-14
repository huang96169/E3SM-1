module startup_initialconds
!----------------------------------------------------------------------- 
! 
! Wrapper for calls to initialize buffers and read initial/topo files
! 
!-----------------------------------------------------------------------

implicit none
private
save

public :: initial_conds ! Read in initial conditions (dycore dependent)

!======================================================================= 
contains
!======================================================================= 

subroutine initial_conds(dyn_in)

   ! This routine does some initializing of buffers that should move to a
   ! non-dycore dependent location.  It also calls the dycore dependent
   ! routine read_inidat.

   use comsrf,        only: initialize_comsrf
#if (defined E3SM_SCM_REPLAY )
   use history_defaults, only: initialize_iop_history
#endif
   
   use pio,           only: file_desc_t
   use cam_initfiles, only: initial_file_get_id, topo_file_get_id
   use inidat,        only: read_inidat
   use dyn_comp,      only: dyn_import_t
   use cam_pio_utils, only: clean_iodesc_list
   use perf_mod,      only: t_startf, t_stopf
   
   type(dyn_import_t),  intent(inout) :: dyn_in

   ! Local variables
   type(file_desc_t), pointer :: fh_ini, fh_topo
   !-----------------------------------------------------------------------

   ! Initialize buffer, comsrf, and radbuffer variables 
   ! (which must occur after the call to phys_grid_init)
   call initialize_comsrf

#if (defined E3SM_SCM_REPLAY )
   call initialize_iop_history
#endif

   ! Read in initial data
   call t_startf('read_inidat')
   fh_ini  => initial_file_get_id()
   fh_topo => topo_file_get_id()
   call read_inidat(fh_ini, fh_topo, dyn_in)
   call t_stopf('read_inidat')

   call t_startf('clean_iodesc_list')
   call clean_iodesc_list()
   call t_stopf('clean_iodesc_list')

end subroutine initial_conds

!======================================================================= 

end module startup_initialconds
