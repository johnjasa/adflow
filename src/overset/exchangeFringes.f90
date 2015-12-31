subroutine exchangeFringes(level, sps, commPattern, internal)
  !
  !      ******************************************************************
  !      *                                                                *
  !      * ExchangeFringes exchanges the fringe information for the 1 to 1*
  !      * halos for a givel level and spectral instance.                 *
  !      *                                                                *
  !      ******************************************************************
  !
  use block
  use communication
  use overset
  implicit none
  !
  !      Subroutine arguments.
  !
  integer(kind=intType), intent(in) :: level, sps

  type(commType),          dimension(*), intent(in) :: commPattern
  type(internalCommType), dimension(*), intent(in) :: internal
  !
  !      Local variables.
  !
  integer :: size, procId, ierr, index
  integer, dimension(mpi_status_size) :: status

  integer(kind=intType) :: i, j, ii, jj
  integer(kind=intType) :: d1, i1, j1, k1, d2, i2, j2, k2

  type(fringeType), dimension(:), allocatable :: sendBuf
  type(fringeType), dimension(:), allocatable :: recvBuf

  ! Allocate the memory for the sending and receiving buffers.

  ii = commPattern(level)%nProcSend
  ii = commPattern(level)%nsendCum(ii)
  jj = commPattern(level)%nProcRecv
  jj = commPattern(level)%nrecvCum(jj)

  allocate(sendBuf(ii), recvBuf(jj), stat=ierr)
  if(ierr /= 0)                       &
       call terminate("exchangeFringes", &
       "Memory allocation failure for buffers")

  ! Send the variables. The data is first copied into
  ! the send buffer after which the buffer is sent asap.

  ii = 1
  sends: do i=1,commPattern(level)%nProcSend

     ! Store the processor id and the size of the message
     ! a bit easier.

     procID = commPattern(level)%sendProc(i)
     size    = commPattern(level)%nsend(i)

     ! Copy the data in the correct part of the send buffer.

     jj = ii
     do j=1,commPattern(level)%nsend(i)

        ! Store the block id and the indices of the donor
        ! a bit easier.

        d1 = commPattern(level)%sendList(i)%block(j)
        i1 = commPattern(level)%sendList(i)%indices(j,1)
        j1 = commPattern(level)%sendList(i)%indices(j,2)
        k1 = commPattern(level)%sendList(i)%indices(j,3)

        ! Copy iblank values to buffer.

        sendBuf(jj) = flowDoms(d1,level,sps)%fringes(i1,j1,k1)
        jj = jj + 1

     enddo

     ! Send the data.

     call mpi_isend(sendBuf(ii), size, oversetMPIFringe, procId, &
          procId, SUmb_comm_world, sendRequests(i),   &
          ierr)

     ! Set ii to jj for the next processor.

     ii = jj

  enddo sends

  ! Post the nonblocking receives.

  ii = 1
  receives: do i=1,commPattern(level)%nProcRecv

     ! Store the processor id and the size of the message
     ! a bit easier.

     procID = commPattern(level)%recvProc(i)
     size    = commPattern(level)%nrecv(i)

     ! Post the receive.

     call mpi_irecv(recvBuf(ii), size, oversetMPIFringe, procId, &
          myId, SUmb_comm_world, recvRequests(i), ierr)

     ! And update ii.

     ii = ii + size

  enddo receives

  ! Copy the local data.

  localCopy: do i=1,internal(level)%ncopy

     ! Store the block and the indices of the donor a bit easier.

     d1 = internal(level)%donorBlock(i)
     i1 = internal(level)%donorIndices(i,1)
     j1 = internal(level)%donorIndices(i,2)
     k1 = internal(level)%donorIndices(i,3)

     ! Idem for the halo's.

     d2 = internal(level)%haloBlock(i)
     i2 = internal(level)%haloIndices(i,1)
     j2 = internal(level)%haloIndices(i,2)
     k2 = internal(level)%haloIndices(i,3)

     flowDoms(d2,level,sps)%fringes(i2,j2,k2) = flowDoms(d1,level,sps)%fringes(i1,j1,k1)

  enddo localCopy

  ! Complete the nonblocking receives in an arbitrary sequence and
  ! copy the variables from the buffer into the halo's.

  size = commPattern(level)%nProcRecv
  completeRecvs: do i=1,commPattern(level)%nProcRecv

     ! Complete any of the requests.

     call mpi_waitany(size, recvRequests, index, status, ierr)

     ! Copy the data just arrived in the halo's.

     ii = index
     jj = commPattern(level)%nrecvCum(ii-1)
     do j=1,commPattern(level)%nrecv(ii)

        ! Store the block and the indices of the halo a bit easier.

        d2 = commPattern(level)%recvList(ii)%block(j)
        i2 = commPattern(level)%recvList(ii)%indices(j,1)
        j2 = commPattern(level)%recvList(ii)%indices(j,2)
        k2 = commPattern(level)%recvList(ii)%indices(j,3)

        jj = jj + 1
        flowDoms(d2,level,sps)%fringes(i2,j2,k2) = recvBuf(jj)

     enddo

  enddo completeRecvs

  ! Complete the nonblocking sends.

  size = commPattern(level)%nProcSend
  do i=1,commPattern(level)%nProcSend
     call mpi_waitany(size, sendRequests, index, status, ierr)
  enddo

  ! Deallocate the memory for the sending and receiving buffers.

  deallocate(sendBuf, recvBuf, stat=ierr)
  if(ierr /= 0)                       &
       call terminate("exchangeFringes", &
       "Deallocation failure for buffers")

end subroutine exchangeFringes
