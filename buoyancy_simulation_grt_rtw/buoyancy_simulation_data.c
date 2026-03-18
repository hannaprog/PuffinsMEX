/*
 * buoyancy_simulation_data.c
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

#include "buoyancy_simulation.h"

/* Block parameters (default storage) */
P_buoyancy_simulation_T buoyancy_simulation_P = {
  /* Variable: area
   * Referenced by: '<S4>/Gain2'
   */
  78.539816339744831,

  /* Variable: density
   * Referenced by: '<S1>/de'
   */
  0.001,

  /* Variable: gravity
   * Referenced by: '<S1>/de'
   */
  9.81,

  /* Variable: km
   * Referenced by: '<S4>/Motor'
   */
  0.02,

  /* Variable: mass
   * Referenced by: '<S2>/Gain'
   */
  3.0,

  /* Variable: p
   * Referenced by: '<S4>/Gain'
   */
  0.002,

  /* Variable: surface_buoyancy
   * Referenced by: '<S1>/Constant'
   */
  300.0,

  /* Mask Parameter: PIDController_D
   * Referenced by: '<S34>/Derivative Gain'
   */
  1.0,

  /* Mask Parameter: PIDController_I
   * Referenced by: '<S38>/Integral Gain'
   */
  0.0,

  /* Mask Parameter: PIDController_InitialConditionF
   * Referenced by: '<S36>/Filter'
   */
  0.0,

  /* Mask Parameter: PIDController_InitialConditio_g
   * Referenced by: '<S41>/Integrator'
   */
  0.0,

  /* Mask Parameter: PIDController_N
   * Referenced by: '<S44>/Filter Coefficient'
   */
  100.0,

  /* Mask Parameter: PIDController_P
   * Referenced by: '<S46>/Proportional Gain'
   */
  5.0,

  /* Expression: 0
   * Referenced by: '<Root>/Integrator1'
   */
  0.0,

  /* Expression: 1
   * Referenced by: '<Root>/Step'
   */
  1.0,

  /* Expression: 0
   * Referenced by: '<Root>/Step'
   */
  0.0,

  /* Expression: -3
   * Referenced by: '<Root>/Step'
   */
  -3.0,

  /* Expression: 0
   * Referenced by: '<S1>/Integrator'
   */
  0.0,

  /* Expression: 500
   * Referenced by: '<S1>/Saturation'
   */
  500.0,

  /* Expression: -500
   * Referenced by: '<S1>/Saturation'
   */
  -500.0,

  /* Expression: 0
   * Referenced by: '<Root>/Integrator'
   */
  0.0,

  /* Expression: 0.1
   * Referenced by: '<S2>/Gain1'
   */
  0.1,

  /* Expression: 1000
   * Referenced by: '<S4>/Gain1'
   */
  1000.0
};
