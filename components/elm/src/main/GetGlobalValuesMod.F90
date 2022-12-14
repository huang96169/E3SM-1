module GetGlobalValuesMod

  !-----------------------------------------------------------------------
  ! Obtain and Write Global Index information
  !-----------------------------------------------------------------------
  implicit none
  private

  ! PUBLIC MEMBER FUNCTIONS:

  public :: GetGlobalIndex
  public :: GetGlobalIndexArray
  public :: GetGlobalWrite
  !-----------------------------------------------------------------------

contains

  !-----------------------------------------------------------------------
  integer function GetGlobalIndex(decomp_index, elmlevel)

    !----------------------------------------------------------------
    ! Description
    ! Determine global index space value for target point at given elmlevel
    !
    ! Uses:
    use shr_log_mod, only: errMsg => shr_log_errMsg
    use decompMod  , only: bounds_type, get_elmlevel_gsmap, get_proc_bounds
    use spmdMod    , only: iam
    use elm_varcon , only: nameg, namet, namel, namec, namep
    use elm_varctl , only: iulog
    use mct_mod
    !
    ! Arguments 
    integer          , intent(in) :: decomp_index
    character(len=*) , intent(in) :: elmlevel
    !
    ! Local Variables:
    type(bounds_type)             :: bounds_proc   ! processor bounds
    type(mct_gsMap),pointer       :: gsmap         ! global seg map
    integer, pointer,dimension(:) :: gsmap_ordered ! gsmap ordered points
    integer                       :: beg_index     ! beginning proc index for elmlevel
    !----------------------------------------------------------------

    call get_proc_bounds(bounds_proc)

    if (trim(elmlevel) == nameg) then
       beg_index = bounds_proc%begg
    else if (trim(elmlevel) == namet) then
       beg_index = bounds_proc%begt
    else if (trim(elmlevel) == namel) then
       beg_index = bounds_proc%begl
    else if (trim(elmlevel) == namec) then
       beg_index = bounds_proc%begc
    else if (trim(elmlevel) == namep) then
       beg_index = bounds_proc%begp
    else
       call shr_sys_abort('elmlevel of '//trim(elmlevel)//' not supported' // &
            errmsg(__FILE__, __LINE__))
    end if

    call get_elmlevel_gsmap(elmlevel=trim(elmlevel), gsmap=gsmap)
    call mct_gsMap_orderedPoints(gsmap, iam, gsmap_ordered)
    GetGlobalIndex = gsmap_ordered(decomp_index - beg_index + 1)
    deallocate(gsmap_ordered)

  end function GetGlobalIndex

  !-----------------------------------------------------------------------
  function GetGlobalIndexArray(decomp_index, bounds1, bounds2, elmlevel)

    !----------------------------------------------------------------
    ! Description
    ! Determine global index space value for target array at given elmlevel
    !
    ! Uses:
    use shr_log_mod, only: errMsg => shr_log_errMsg
    use decompMod  , only: bounds_type, get_elmlevel_gsmap, get_proc_bounds
    use spmdMod    , only: iam
    use elm_varcon , only: nameg,namet, namel, namec, namep
    use elm_varctl , only: iulog
    use mct_mod
    !
    ! Arguments 
    integer                 , intent(in) :: bounds1
    integer                 , intent(in) :: bounds2
    integer, dimension(bounds1:bounds2), intent(in) :: decomp_index
    character(len=*)        , intent(in) :: elmlevel
    integer, dimension(bounds1:bounds2)  :: GetGlobalIndexArray
    !
    ! Local Variables:
    type(bounds_type)             :: bounds_proc   ! processor bounds
    type(mct_gsMap),pointer       :: gsmap         ! global seg map
    integer, pointer,dimension(:) :: gsmap_ordered ! gsmap ordered points
    integer                       :: beg_index     ! beginning proc index for elmlevel
    integer                       :: i
    !----------------------------------------------------------------

    call get_proc_bounds(bounds_proc)

    if (trim(elmlevel) == nameg) then
       beg_index = bounds_proc%begg
    else if (trim(elmlevel) == namet) then
       beg_index = bounds_proc%begt
    else if (trim(elmlevel) == namel) then
       beg_index = bounds_proc%begl
    else if (trim(elmlevel) == namec) then
       beg_index = bounds_proc%begc
    else if (trim(elmlevel) == namep) then
       beg_index = bounds_proc%begp
    else
       call shr_sys_abort('elmlevel of '//trim(elmlevel)//' not supported' // &
            errmsg(__FILE__, __LINE__))
    end if

    call get_elmlevel_gsmap(elmlevel=trim(elmlevel), gsmap=gsmap)
    call mct_gsMap_orderedPoints(gsmap, iam, gsmap_ordered)
    do i=bounds1,bounds2
       GetGlobalIndexArray(i) = gsmap_ordered(decomp_index(i) - beg_index + 1)
    enddo
    deallocate(gsmap_ordered)

  end function GetGlobalIndexArray

  !-----------------------------------------------------------------------
  subroutine GetGlobalWrite(decomp_index, elmlevel)

    !-----------------------------------------------------------------------
    ! Description:
    ! Write global index information for input local indices
    !
    use shr_sys_mod  , only : shr_sys_flush
    use shr_sys_mod  , only : shr_sys_abort
    use shr_log_mod  , only : errMsg => shr_log_errMsg
    use elm_varctl   , only : iulog
    use elm_varcon   , only : nameg, namet, namel, namec, namep
    use GridcellType , only : grc_pp 
    use TopounitType , only : top_pp               
    use LandunitType , only : lun_pp                
    use ColumnType   , only : col_pp                
    use VegetationType    , only : veg_pp                
    !
    ! Arguments:
    integer          , intent(in) :: decomp_index
    character(len=*) , intent(in) :: elmlevel
    !
    ! Local Variables:
    integer :: igrc, itun, ilun, icol, ipft 
    !-----------------------------------------------------------------------

    if (trim(elmlevel) == nameg) then

       igrc = decomp_index
       write(iulog,*)'local  gridcell index = ',igrc
       write(iulog,*)'global gridcell index = ',GetGlobalIndex(decomp_index=igrc, elmlevel=nameg)
       write(iulog,*)'gridcell longitude    = ',grc_pp%londeg(igrc)
       write(iulog,*)'gridcell latitude     = ',grc_pp%latdeg(igrc)
    
    else if (trim(elmlevel) == namet) then
       itun = decomp_index
       igrc = top_pp%gridcell(itun)
       write(iulog,*)'local  topounit index = ',itun
       write(iulog,*)'global topounit index = ',GetGlobalIndex(decomp_index=itun, elmlevel=namet)
       write(iulog,*)'global gridcell index = ',GetGlobalIndex(decomp_index=igrc, elmlevel=nameg)
       write(iulog,*)'gridcell longitude    = ',grc_pp%londeg(igrc)
       write(iulog,*)'gridcell latitude     = ',grc_pp%latdeg(igrc)
      ! write(iulog,*)'topounit type         = ',top_pp%itype(decomp_index)
	  
    else if (trim(elmlevel) == namel) then

       ilun = decomp_index
       igrc = lun_pp%gridcell(ilun)
       write(iulog,*)'local  landunit index = ',ilun
       write(iulog,*)'global landunit index = ',GetGlobalIndex(decomp_index=ilun, elmlevel=namel)
       write(iulog,*)'global gridcell index = ',GetGlobalIndex(decomp_index=igrc, elmlevel=nameg)
       write(iulog,*)'gridcell longitude    = ',grc_pp%londeg(igrc)
       write(iulog,*)'gridcell latitude     = ',grc_pp%latdeg(igrc)
       write(iulog,*)'landunit type         = ',lun_pp%itype(decomp_index)

    else if (trim(elmlevel) == namec) then

       icol = decomp_index
       ilun = col_pp%landunit(icol)
       igrc = col_pp%gridcell(icol)
       write(iulog,*)'local  column   index = ',icol
       write(iulog,*)'global column   index = ',GetGlobalIndex(decomp_index=icol, elmlevel=namec)
       write(iulog,*)'global landunit index = ',GetGlobalIndex(decomp_index=ilun, elmlevel=namel)
       write(iulog,*)'global gridcell index = ',GetGlobalIndex(decomp_index=igrc, elmlevel=nameg)
       write(iulog,*)'gridcell longitude    = ',grc_pp%londeg(igrc)
       write(iulog,*)'gridcell latitude     = ',grc_pp%latdeg(igrc)
       write(iulog,*)'column   type         = ',col_pp%itype(icol)
       write(iulog,*)'landunit type         = ',lun_pp%itype(ilun)
   
    else if (trim(elmlevel) == namep) then

       ipft = decomp_index
       icol = veg_pp%column(ipft)
       ilun = veg_pp%landunit(ipft)
       igrc = veg_pp%gridcell(ipft)
       write(iulog,*)'local  pft      index = ',ipft
       write(iulog,*)'global pft      index = ',GetGlobalIndex(decomp_index=ipft, elmlevel=namep)
       write(iulog,*)'global column   index = ',GetGlobalIndex(decomp_index=icol, elmlevel=namec)
       write(iulog,*)'global landunit index = ',GetGlobalIndex(decomp_index=ilun, elmlevel=namel)
       write(iulog,*)'global gridcell index = ',GetGlobalIndex(decomp_index=igrc, elmlevel=nameg)
       write(iulog,*)'gridcell longitude    = ',grc_pp%londeg(igrc)
       write(iulog,*)'gridcell latitude     = ',grc_pp%latdeg(igrc)
       write(iulog,*)'pft      type         = ',veg_pp%itype(ipft)
       write(iulog,*)'column   type         = ',col_pp%itype(icol)
       write(iulog,*)'landunit type         = ',lun_pp%itype(ilun)

    else		       
       call shr_sys_abort('elmlevel '//trim(elmlevel)//'not supported '//errmsg(__FILE__, __LINE__))

    end if

    call shr_sys_flush(iulog)

  end subroutine GetGlobalWrite

end module GetGlobalValuesMod
