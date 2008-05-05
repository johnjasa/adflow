!
!      ******************************************************************
!      *                                                                *
!      * File:          computeRAdj.f90                                 *
!      * Author:        C.A.(Sandy) Mader                               *
!      * Starting date: 02-01-2008                                      *
!      * Last modified: 04-23-2008                                      *
!      *                                                                *
!      ******************************************************************
!

subroutine computeRAdjoint(wAdj,xAdj,dwAdj,   &
                          iCell, jCell,  kCell, &
                          nn,sps, correctForK,secondHalo)
  
!      Set Use Modules
  use blockPointers
  use flowVarRefState



!      Set Passed in Variables

  integer(kind=intType), intent(in) :: iCell, jCell, kCell,nn,sps
  real(kind=realType), dimension(-2:2,-2:2,-2:2,nw), &
       intent(in) :: wAdj
  real(kind=realType), dimension(-3:2,-3:2,-3:2,3), &
       intent(in) :: xAdj

  real(kind=realType), dimension(nw)                :: dwAdj

  logical :: secondHalo, correctForK

!      Set Local Variables

  !variables for test loops
  integer(kind=intType)::i,j,k,ii,jj,kk
  integer(kind=intType) :: iStart,iEnd,jStart,jEnd,kStart,kEnd

  real(kind=realType), dimension(-2:2,-2:2,-2:2) :: pAdj
  real(kind=realType), dimension(nBocos,-2:2,-2:2,3) :: normAdj
  real(kind=realType):: volAdj
  real(kind=realType), dimension(-2:2,-2:2,-2:2,3) :: siAdj, sjAdj, skAdj

  


! *************************************************************************
!      Begin Execution
! *************************************************************************
  

!      Call the metric routines to generate the areas, volumes and surface normals for the stencil.
       
       call metricAdj(xAdj,siAdj,sjAdj,skAdj,volAdj,normAdj, &
            iCell,jCell,kCell)
      
!      Mimic the Residual calculation in the main code

       !Compute the Pressure in the stencil based on the current 
       !States

       ! replace with Compute Pressure Adjoint!
       call computePressureAdj(wAdj, pAdj)
       
      
       ! Apply all boundary conditions to stencil.
       ! In case of a full mg mode, and a segegated turbulent solver,
       ! first call the turbulent boundary conditions, such that the
       ! turbulent kinetic energy is properly initialized in the halo's.

!###! Ignore Viscous for now
!###!       if(turbSegregated .and. (.not. corrections)) &
!###!         call applyAllTurbBCAdj(secondHalo)

       ! Apply all boundary conditions of the mean flow.

!!$       call applyAllBCAdj(wAdj, pAdj, &
!!$            siAdj, sjAdj, skAdj, volAdj, normAdj, &
!!$            iCell, jCell, kCell,secondHalo)

!!#Shouldn't need this section for derivatives...
!!$       ! In case this routine is called in full mg mode call the mean
!!$       ! flow boundary conditions again such that the normal momentum
!!$       ! boundary condition is treated correctly.
!!$
!!$       if(.not. corrections) call applyAllBCAdj(wAdj, pAdj, &
!!$                              siAdj, sjAdj, skAdj, volAdj, normAdj, &
!!$                              iCell, jCell, kCell,secondHalo)

       !Leave out State exchanges for now. If there are discrepancies 
       !Later, this may be a source...
!!$       ! Exchange the solution. Either whalo1 or whalo2
!!$       ! must be called.
!!$
!!$       if( secondHalo ) then
!!$         call whalo2(currentLevel, 1_intType, nVarInt, .true., &
!!$                     .true., .true.)
!!$       else
!!$         call whalo1(currentLevel, 1_intType, nVarInt, .true., &
!!$                     .true., .true.)
!!$       endif

!Again this shou;d not be required, so leave out for now...
       ! For full multigrid mode the bleeds must be determined, the
       ! boundary conditions must be applied one more time and the
       ! solution must be exchanged again.

!!$       if(.not. corrections) then
!!$         call BCDataMassBleedOutflowAdj(.true., .true.)
!!$         call applyAllBCAdj(secondHalo)
!!$
!!$       !Leave out State exchanges for now. If there are discrepancies 
!!$       !Later, this may be a source...

!!$!         if( secondHalo ) then
!!$!           call whalo2(currentLevel, 1_intType, nVarInt, .true., &
!!$!                       .true., .true.)
!!$!         else
!!!$           call whalo1(currentLevel, 1_intType, nVarInt, .true., &
!!!$                       .true., .true.)
!!!$         endif
!!$       endif
!!$
!!$
!!$
!!$       ! Reset the values of rkStage and currentLevel, such that
!!$       ! they correspond to a new iteration.
!!$
!!$       rkStage = 0
!!$       currentLevel = groundLevel
!!$
!!$       ! Compute the latest values of the skin friction velocity.
!!$       ! The currently stored values are of the previous iteration.
!!$
!!$       call computeUtauAdj
!!$
!!$       ! Apply an iteration to the turbulent transport equations in
!!$       ! case these must be solved segregatedly.
!!$
!!$       if( turbSegregated ) call turbSolveSegregatedAdj
!!$
!!$       ! Compute the time step.
!!$
!!$       call timeStepAdj(.false.)
!!$
!!$       ! Compute the residual of the new solution on the ground level.
!!$
!!$       if( turbCoupled ) then
!!$         call initresAdj(nt1MG, nMGVar)
!!$         call turbResidualAdj
!!$       endif
!!$

       !call initresAdj(1_intType, nwf,sps,dwAdj)
       call initresAdj(1, nwf,sps,dwAdj)
       
       call residualAdj(wAdj,pAdj,siAdj,sjAdj,skAdj,volAdj,normAdj,&
                              dwAdj, iCell, jCell, kCell,  &  
                              correctForK)



     end subroutine computeRAdjoint
