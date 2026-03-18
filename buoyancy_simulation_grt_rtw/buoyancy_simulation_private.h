/*
 * buoyancy_simulation_private.h
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "buoyancy_simulation".
 *
 * Model version              : 1.6
 * Simulink Coder version : 25.1 (R2025a) 21-Nov-2024
 * C source code generated on : Wed Mar 18 08:08:46 2026
 *
 * Target selection: grt.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef buoyancy_simulation_private_h_
#define buoyancy_simulation_private_h_
#include "rtwtypes.h"
#include "builtin_typeid_types.h"
#include "multiword_types.h"
#include "buoyancy_simulation.h"
#include "buoyancy_simulation_types.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"

/* Private macros used by the generated code to access rtModel */
#ifndef rtmIsMajorTimeStep
#define rtmIsMajorTimeStep(rtm)        (((rtm)->Timing.simTimeStep) == MAJOR_TIME_STEP)
#endif

#ifndef rtmIsMinorTimeStep
#define rtmIsMinorTimeStep(rtm)        (((rtm)->Timing.simTimeStep) == MINOR_TIME_STEP)
#endif

#ifndef rtmSetTFinal
#define rtmSetTFinal(rtm, val)         ((rtm)->Timing.tFinal = (val))
#endif

#ifndef rtmSetTPtr
#define rtmSetTPtr(rtm, val)           ((rtm)->Timing.t = (val))
#endif

extern void buoyancy_simulat_MATLABFunction(real_T rtu_u, real_T
  rtu_buoyancyForce, B_MATLABFunction_buoyancy_sim_T *localB);

/* private model entry point functions */
extern void buoyancy_simulation_derivatives(void);

#endif                                 /* buoyancy_simulation_private_h_ */
