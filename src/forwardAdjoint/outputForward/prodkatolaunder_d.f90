   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.10 (r5363) -  9 Sep 2014 09:53
   !
   !  Differentiation of prodkatolaunder in forward (tangent) mode (with options i4 dr8 r8):
   !   variations   of useful results: *dw
   !   with respect to varying inputs: timeref *w *vol *si *sj *sk
   !   Plus diff mem management of: dw:in w:in vol:in si:in sj:in
   !                sk:in
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          prodKatoLaunder.f90                             *
   !      * Author:        Georgi Kalitzin, Edwin van der Weide            *
   !      * Starting date: 08-01-2003                                      *
   !      * Last modified: 06-12-2005                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE PRODKATOLAUNDER_D()
   !
   !      ******************************************************************
   !      *                                                                *
   !      * prodKatoLaunder computes the turbulent production term using   *
   !      * the Kato-Launder formulation.                                  *
   !      *                                                                *
   !      ******************************************************************
   !
   USE BLOCKPOINTERS
   USE FLOWVARREFSTATE
   USE SECTION
   USE TURBMOD
   IMPLICIT NONE
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: i, j, k
   REAL(kind=realtype) :: uux, uuy, uuz, vvx, vvy, vvz, wwx, wwy, wwz
   REAL(kind=realtype) :: uuxd, uuyd, uuzd, vvxd, vvyd, vvzd, wwxd, wwyd&
   & , wwzd
   REAL(kind=realtype) :: qxx, qyy, qzz, qxy, qxz, qyz, sijsij
   REAL(kind=realtype) :: qxxd, qyyd, qzzd, qxyd, qxzd, qyzd, sijsijd
   REAL(kind=realtype) :: oxy, oxz, oyz, oijoij
   REAL(kind=realtype) :: oxyd, oxzd, oyzd, oijoijd
   REAL(kind=realtype) :: fact, omegax, omegay, omegaz
   REAL(kind=realtype) :: factd, omegaxd, omegayd, omegazd
   INTRINSIC SQRT
   REAL(kind=realtype) :: arg1
   REAL(kind=realtype) :: arg1d
   REAL(kind=realtype) :: result1
   REAL(kind=realtype) :: result1d
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Determine the non-dimensional wheel speed of this block.
   ! The vorticity term, which appears in Kato-Launder is of course
   ! not frame invariant. To approximate frame invariance the wheel
   ! speed should be substracted from oxy, oxz and oyz, which results
   ! in the vorticity in the rotating frame. However some people
   ! claim that the absolute vorticity should be used to obtain the
   ! best results. In that omega should be set to zero.
   omegaxd = sections(sectionid)%rotrate(1)*timerefd
   omegax = timeref*sections(sectionid)%rotrate(1)
   omegayd = sections(sectionid)%rotrate(2)*timerefd
   omegay = timeref*sections(sectionid)%rotrate(2)
   omegazd = sections(sectionid)%rotrate(3)*timerefd
   omegaz = timeref*sections(sectionid)%rotrate(3)
   dwd = 0.0_8
   ! Loop over the cell centers of the given block. It may be more
   ! efficient to loop over the faces and to scatter the gradient,
   ! but in that case the gradients for u, v and w must be stored.
   ! In the current approach no extra memory is needed.
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   ! Compute the gradient of u in the cell center. Use is made
   ! of the fact that the surrounding normals sum up to zero,
   ! such that the cell i,j,k does not give a contribution.
   ! The gradient is scaled by a factor 2*vol.
   uuxd = wd(i+1, j, k, ivx)*si(i, j, k, 1) + w(i+1, j, k, ivx)*sid&
   &         (i, j, k, 1) - wd(i-1, j, k, ivx)*si(i-1, j, k, 1) - w(i-1, j&
   &         , k, ivx)*sid(i-1, j, k, 1) + wd(i, j+1, k, ivx)*sj(i, j, k, 1&
   &         ) + w(i, j+1, k, ivx)*sjd(i, j, k, 1) - wd(i, j-1, k, ivx)*sj(&
   &         i, j-1, k, 1) - w(i, j-1, k, ivx)*sjd(i, j-1, k, 1) + wd(i, j&
   &         , k+1, ivx)*sk(i, j, k, 1) + w(i, j, k+1, ivx)*skd(i, j, k, 1)&
   &         - wd(i, j, k-1, ivx)*sk(i, j, k-1, 1) - w(i, j, k-1, ivx)*skd(&
   &         i, j, k-1, 1)
   uux = w(i+1, j, k, ivx)*si(i, j, k, 1) - w(i-1, j, k, ivx)*si(i-&
   &         1, j, k, 1) + w(i, j+1, k, ivx)*sj(i, j, k, 1) - w(i, j-1, k, &
   &         ivx)*sj(i, j-1, k, 1) + w(i, j, k+1, ivx)*sk(i, j, k, 1) - w(i&
   &         , j, k-1, ivx)*sk(i, j, k-1, 1)
   uuyd = wd(i+1, j, k, ivx)*si(i, j, k, 2) + w(i+1, j, k, ivx)*sid&
   &         (i, j, k, 2) - wd(i-1, j, k, ivx)*si(i-1, j, k, 2) - w(i-1, j&
   &         , k, ivx)*sid(i-1, j, k, 2) + wd(i, j+1, k, ivx)*sj(i, j, k, 2&
   &         ) + w(i, j+1, k, ivx)*sjd(i, j, k, 2) - wd(i, j-1, k, ivx)*sj(&
   &         i, j-1, k, 2) - w(i, j-1, k, ivx)*sjd(i, j-1, k, 2) + wd(i, j&
   &         , k+1, ivx)*sk(i, j, k, 2) + w(i, j, k+1, ivx)*skd(i, j, k, 2)&
   &         - wd(i, j, k-1, ivx)*sk(i, j, k-1, 2) - w(i, j, k-1, ivx)*skd(&
   &         i, j, k-1, 2)
   uuy = w(i+1, j, k, ivx)*si(i, j, k, 2) - w(i-1, j, k, ivx)*si(i-&
   &         1, j, k, 2) + w(i, j+1, k, ivx)*sj(i, j, k, 2) - w(i, j-1, k, &
   &         ivx)*sj(i, j-1, k, 2) + w(i, j, k+1, ivx)*sk(i, j, k, 2) - w(i&
   &         , j, k-1, ivx)*sk(i, j, k-1, 2)
   uuzd = wd(i+1, j, k, ivx)*si(i, j, k, 3) + w(i+1, j, k, ivx)*sid&
   &         (i, j, k, 3) - wd(i-1, j, k, ivx)*si(i-1, j, k, 3) - w(i-1, j&
   &         , k, ivx)*sid(i-1, j, k, 3) + wd(i, j+1, k, ivx)*sj(i, j, k, 3&
   &         ) + w(i, j+1, k, ivx)*sjd(i, j, k, 3) - wd(i, j-1, k, ivx)*sj(&
   &         i, j-1, k, 3) - w(i, j-1, k, ivx)*sjd(i, j-1, k, 3) + wd(i, j&
   &         , k+1, ivx)*sk(i, j, k, 3) + w(i, j, k+1, ivx)*skd(i, j, k, 3)&
   &         - wd(i, j, k-1, ivx)*sk(i, j, k-1, 3) - w(i, j, k-1, ivx)*skd(&
   &         i, j, k-1, 3)
   uuz = w(i+1, j, k, ivx)*si(i, j, k, 3) - w(i-1, j, k, ivx)*si(i-&
   &         1, j, k, 3) + w(i, j+1, k, ivx)*sj(i, j, k, 3) - w(i, j-1, k, &
   &         ivx)*sj(i, j-1, k, 3) + w(i, j, k+1, ivx)*sk(i, j, k, 3) - w(i&
   &         , j, k-1, ivx)*sk(i, j, k-1, 3)
   ! Idem for the gradient of v.
   vvxd = wd(i+1, j, k, ivy)*si(i, j, k, 1) + w(i+1, j, k, ivy)*sid&
   &         (i, j, k, 1) - wd(i-1, j, k, ivy)*si(i-1, j, k, 1) - w(i-1, j&
   &         , k, ivy)*sid(i-1, j, k, 1) + wd(i, j+1, k, ivy)*sj(i, j, k, 1&
   &         ) + w(i, j+1, k, ivy)*sjd(i, j, k, 1) - wd(i, j-1, k, ivy)*sj(&
   &         i, j-1, k, 1) - w(i, j-1, k, ivy)*sjd(i, j-1, k, 1) + wd(i, j&
   &         , k+1, ivy)*sk(i, j, k, 1) + w(i, j, k+1, ivy)*skd(i, j, k, 1)&
   &         - wd(i, j, k-1, ivy)*sk(i, j, k-1, 1) - w(i, j, k-1, ivy)*skd(&
   &         i, j, k-1, 1)
   vvx = w(i+1, j, k, ivy)*si(i, j, k, 1) - w(i-1, j, k, ivy)*si(i-&
   &         1, j, k, 1) + w(i, j+1, k, ivy)*sj(i, j, k, 1) - w(i, j-1, k, &
   &         ivy)*sj(i, j-1, k, 1) + w(i, j, k+1, ivy)*sk(i, j, k, 1) - w(i&
   &         , j, k-1, ivy)*sk(i, j, k-1, 1)
   vvyd = wd(i+1, j, k, ivy)*si(i, j, k, 2) + w(i+1, j, k, ivy)*sid&
   &         (i, j, k, 2) - wd(i-1, j, k, ivy)*si(i-1, j, k, 2) - w(i-1, j&
   &         , k, ivy)*sid(i-1, j, k, 2) + wd(i, j+1, k, ivy)*sj(i, j, k, 2&
   &         ) + w(i, j+1, k, ivy)*sjd(i, j, k, 2) - wd(i, j-1, k, ivy)*sj(&
   &         i, j-1, k, 2) - w(i, j-1, k, ivy)*sjd(i, j-1, k, 2) + wd(i, j&
   &         , k+1, ivy)*sk(i, j, k, 2) + w(i, j, k+1, ivy)*skd(i, j, k, 2)&
   &         - wd(i, j, k-1, ivy)*sk(i, j, k-1, 2) - w(i, j, k-1, ivy)*skd(&
   &         i, j, k-1, 2)
   vvy = w(i+1, j, k, ivy)*si(i, j, k, 2) - w(i-1, j, k, ivy)*si(i-&
   &         1, j, k, 2) + w(i, j+1, k, ivy)*sj(i, j, k, 2) - w(i, j-1, k, &
   &         ivy)*sj(i, j-1, k, 2) + w(i, j, k+1, ivy)*sk(i, j, k, 2) - w(i&
   &         , j, k-1, ivy)*sk(i, j, k-1, 2)
   vvzd = wd(i+1, j, k, ivy)*si(i, j, k, 3) + w(i+1, j, k, ivy)*sid&
   &         (i, j, k, 3) - wd(i-1, j, k, ivy)*si(i-1, j, k, 3) - w(i-1, j&
   &         , k, ivy)*sid(i-1, j, k, 3) + wd(i, j+1, k, ivy)*sj(i, j, k, 3&
   &         ) + w(i, j+1, k, ivy)*sjd(i, j, k, 3) - wd(i, j-1, k, ivy)*sj(&
   &         i, j-1, k, 3) - w(i, j-1, k, ivy)*sjd(i, j-1, k, 3) + wd(i, j&
   &         , k+1, ivy)*sk(i, j, k, 3) + w(i, j, k+1, ivy)*skd(i, j, k, 3)&
   &         - wd(i, j, k-1, ivy)*sk(i, j, k-1, 3) - w(i, j, k-1, ivy)*skd(&
   &         i, j, k-1, 3)
   vvz = w(i+1, j, k, ivy)*si(i, j, k, 3) - w(i-1, j, k, ivy)*si(i-&
   &         1, j, k, 3) + w(i, j+1, k, ivy)*sj(i, j, k, 3) - w(i, j-1, k, &
   &         ivy)*sj(i, j-1, k, 3) + w(i, j, k+1, ivy)*sk(i, j, k, 3) - w(i&
   &         , j, k-1, ivy)*sk(i, j, k-1, 3)
   ! And for the gradient of w.
   wwxd = wd(i+1, j, k, ivz)*si(i, j, k, 1) + w(i+1, j, k, ivz)*sid&
   &         (i, j, k, 1) - wd(i-1, j, k, ivz)*si(i-1, j, k, 1) - w(i-1, j&
   &         , k, ivz)*sid(i-1, j, k, 1) + wd(i, j+1, k, ivz)*sj(i, j, k, 1&
   &         ) + w(i, j+1, k, ivz)*sjd(i, j, k, 1) - wd(i, j-1, k, ivz)*sj(&
   &         i, j-1, k, 1) - w(i, j-1, k, ivz)*sjd(i, j-1, k, 1) + wd(i, j&
   &         , k+1, ivz)*sk(i, j, k, 1) + w(i, j, k+1, ivz)*skd(i, j, k, 1)&
   &         - wd(i, j, k-1, ivz)*sk(i, j, k-1, 1) - w(i, j, k-1, ivz)*skd(&
   &         i, j, k-1, 1)
   wwx = w(i+1, j, k, ivz)*si(i, j, k, 1) - w(i-1, j, k, ivz)*si(i-&
   &         1, j, k, 1) + w(i, j+1, k, ivz)*sj(i, j, k, 1) - w(i, j-1, k, &
   &         ivz)*sj(i, j-1, k, 1) + w(i, j, k+1, ivz)*sk(i, j, k, 1) - w(i&
   &         , j, k-1, ivz)*sk(i, j, k-1, 1)
   wwyd = wd(i+1, j, k, ivz)*si(i, j, k, 2) + w(i+1, j, k, ivz)*sid&
   &         (i, j, k, 2) - wd(i-1, j, k, ivz)*si(i-1, j, k, 2) - w(i-1, j&
   &         , k, ivz)*sid(i-1, j, k, 2) + wd(i, j+1, k, ivz)*sj(i, j, k, 2&
   &         ) + w(i, j+1, k, ivz)*sjd(i, j, k, 2) - wd(i, j-1, k, ivz)*sj(&
   &         i, j-1, k, 2) - w(i, j-1, k, ivz)*sjd(i, j-1, k, 2) + wd(i, j&
   &         , k+1, ivz)*sk(i, j, k, 2) + w(i, j, k+1, ivz)*skd(i, j, k, 2)&
   &         - wd(i, j, k-1, ivz)*sk(i, j, k-1, 2) - w(i, j, k-1, ivz)*skd(&
   &         i, j, k-1, 2)
   wwy = w(i+1, j, k, ivz)*si(i, j, k, 2) - w(i-1, j, k, ivz)*si(i-&
   &         1, j, k, 2) + w(i, j+1, k, ivz)*sj(i, j, k, 2) - w(i, j-1, k, &
   &         ivz)*sj(i, j-1, k, 2) + w(i, j, k+1, ivz)*sk(i, j, k, 2) - w(i&
   &         , j, k-1, ivz)*sk(i, j, k-1, 2)
   wwzd = wd(i+1, j, k, ivz)*si(i, j, k, 3) + w(i+1, j, k, ivz)*sid&
   &         (i, j, k, 3) - wd(i-1, j, k, ivz)*si(i-1, j, k, 3) - w(i-1, j&
   &         , k, ivz)*sid(i-1, j, k, 3) + wd(i, j+1, k, ivz)*sj(i, j, k, 3&
   &         ) + w(i, j+1, k, ivz)*sjd(i, j, k, 3) - wd(i, j-1, k, ivz)*sj(&
   &         i, j-1, k, 3) - w(i, j-1, k, ivz)*sjd(i, j-1, k, 3) + wd(i, j&
   &         , k+1, ivz)*sk(i, j, k, 3) + w(i, j, k+1, ivz)*skd(i, j, k, 3)&
   &         - wd(i, j, k-1, ivz)*sk(i, j, k-1, 3) - w(i, j, k-1, ivz)*skd(&
   &         i, j, k-1, 3)
   wwz = w(i+1, j, k, ivz)*si(i, j, k, 3) - w(i-1, j, k, ivz)*si(i-&
   &         1, j, k, 3) + w(i, j+1, k, ivz)*sj(i, j, k, 3) - w(i, j-1, k, &
   &         ivz)*sj(i, j-1, k, 3) + w(i, j, k+1, ivz)*sk(i, j, k, 3) - w(i&
   &         , j, k-1, ivz)*sk(i, j, k-1, 3)
   ! Compute the strain and vorticity terms. The multiplication
   ! is present to obtain the correct gradients. Note that
   ! the wheel speed is substracted from the vorticity terms.
   factd = -(half*vold(i, j, k)/vol(i, j, k)**2)
   fact = half/vol(i, j, k)
   qxxd = factd*uux + fact*uuxd
   qxx = fact*uux
   qyyd = factd*vvy + fact*vvyd
   qyy = fact*vvy
   qzzd = factd*wwz + fact*wwzd
   qzz = fact*wwz
   qxyd = half*(factd*(uuy+vvx)+fact*(uuyd+vvxd))
   qxy = fact*half*(uuy+vvx)
   qxzd = half*(factd*(uuz+wwx)+fact*(uuzd+wwxd))
   qxz = fact*half*(uuz+wwx)
   qyzd = half*(factd*(vvz+wwy)+fact*(vvzd+wwyd))
   qyz = fact*half*(vvz+wwy)
   oxyd = half*(factd*(vvx-uuy)+fact*(vvxd-uuyd)) - omegazd
   oxy = fact*half*(vvx-uuy) - omegaz
   oxzd = half*(factd*(uuz-wwx)+fact*(uuzd-wwxd)) - omegayd
   oxz = fact*half*(uuz-wwx) - omegay
   oyzd = half*(factd*(wwy-vvz)+fact*(wwyd-vvzd)) - omegaxd
   oyz = fact*half*(wwy-vvz) - omegax
   ! Compute the summation of the strain and vorticity tensors.
   sijsijd = two*(2*qxy*qxyd+2*qxz*qxzd+2*qyz*qyzd) + 2*qxx*qxxd + &
   &         2*qyy*qyyd + 2*qzz*qzzd
   sijsij = two*(qxy**2+qxz**2+qyz**2) + qxx**2 + qyy**2 + qzz**2
   oijoijd = two*(2*oxy*oxyd+2*oxz*oxzd+2*oyz*oyzd)
   oijoij = two*(oxy**2+oxz**2+oyz**2)
   ! Compute the production term.
   arg1d = sijsijd*oijoij + sijsij*oijoijd
   arg1 = sijsij*oijoij
   IF (arg1 .EQ. 0.0_8) THEN
   result1d = 0.0_8
   ELSE
   result1d = arg1d/(2.0*SQRT(arg1))
   END IF
   result1 = SQRT(arg1)
   dwd(i, j, k, iprod) = two*result1d
   dw(i, j, k, iprod) = two*result1
   END DO
   END DO
   END DO
   END SUBROUTINE PRODKATOLAUNDER_D
