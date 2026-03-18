/*
 * buoyancy_simulation.c
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
#include "rtwtypes.h"
#include "buoyancy_simulation_private.h"

/* Block signals (default storage) */
B_buoyancy_simulation_T buoyancy_simulation_B;

/* Continuous states */
X_buoyancy_simulation_T buoyancy_simulation_X;

/* Disabled State Vector */
XDis_buoyancy_simulation_T buoyancy_simulation_XDis;

/* Real-time model */
static RT_MODEL_buoyancy_simulation_T buoyancy_simulation_M_;
RT_MODEL_buoyancy_simulation_T *const buoyancy_simulation_M =
  &buoyancy_simulation_M_;

/*
 * This function updates continuous states using the ODE3 fixed-step
 * solver algorithm
 */
static void rt_ertODEUpdateContinuousStates(RTWSolverInfo *si )
{
  /* Solver Matrices */
  static const real_T rt_ODE3_A[3] = {
    1.0/2.0, 3.0/4.0, 1.0
  };

  static const real_T rt_ODE3_B[3][3] = {
    { 1.0/2.0, 0.0, 0.0 },

    { 0.0, 3.0/4.0, 0.0 },

    { 2.0/9.0, 1.0/3.0, 4.0/9.0 }
  };

  time_T t = rtsiGetT(si);
  time_T tnew = rtsiGetSolverStopTime(si);
  time_T h = rtsiGetStepSize(si);
  real_T *x = rtsiGetContStates(si);
  ODE3_IntgData *id = (ODE3_IntgData *)rtsiGetSolverData(si);
  real_T *y = id->y;
  real_T *f0 = id->f[0];
  real_T *f1 = id->f[1];
  real_T *f2 = id->f[2];
  real_T hB[3];
  int_T i;
  int_T nXc = 5;
  rtsiSetSimTimeStep(si,MINOR_TIME_STEP);

  /* Save the state values at time t in y, we'll use x as ynew. */
  (void) memcpy(y, x,
                (uint_T)nXc*sizeof(real_T));

  /* Assumes that rtsiSetT and ModelOutputs are up-to-date */
  /* f0 = f(t,y) */
  rtsiSetdX(si, f0);
  buoyancy_simulation_derivatives();

  /* f(:,2) = feval(odefile, t + hA(1), y + f*hB(:,1), args(:)(*)); */
  hB[0] = h * rt_ODE3_B[0][0];
  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + (f0[i]*hB[0]);
  }

  rtsiSetT(si, t + h*rt_ODE3_A[0]);
  rtsiSetdX(si, f1);
  buoyancy_simulation_step();
  buoyancy_simulation_derivatives();

  /* f(:,3) = feval(odefile, t + hA(2), y + f*hB(:,2), args(:)(*)); */
  for (i = 0; i <= 1; i++) {
    hB[i] = h * rt_ODE3_B[1][i];
  }

  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1]);
  }

  rtsiSetT(si, t + h*rt_ODE3_A[1]);
  rtsiSetdX(si, f2);
  buoyancy_simulation_step();
  buoyancy_simulation_derivatives();

  /* tnew = t + hA(3);
     ynew = y + f*hB(:,3); */
  for (i = 0; i <= 2; i++) {
    hB[i] = h * rt_ODE3_B[2][i];
  }

  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1] + f2[i]*hB[2]);
  }

  rtsiSetT(si, tnew);
  rtsiSetSimTimeStep(si,MAJOR_TIME_STEP);
}

/*
 * Output and update for atomic system:
 *    '<S2>/MATLAB Function'
 *    '<Root>/MATLAB Function'
 */
void buoyancy_simulat_MATLABFunction(real_T rtu_u, real_T rtu_buoyancyForce,
  B_MATLABFunction_buoyancy_sim_T *localB)
{
  if ((rtu_u > 0.1) && (rtu_buoyancyForce > 0.0)) {
    localB->y = 0.0;
  } else {
    localB->y = rtu_buoyancyForce;
  }
}

/* Model step function */
void buoyancy_simulation_step(void)
{
  /* local block i/o variables */
  real_T rtb_Speed;
  real_T rtb_Gain;
  real_T rtb_edeptherror;
  real_T tmp;
  if (rtmIsMajorTimeStep(buoyancy_simulation_M)) {
    /* set solver stop time */
    if (!(buoyancy_simulation_M->Timing.clockTick0+1)) {
      rtsiSetSolverStopTime(&buoyancy_simulation_M->solverInfo,
                            ((buoyancy_simulation_M->Timing.clockTickH0 + 1) *
        buoyancy_simulation_M->Timing.stepSize0 * 4294967296.0));
    } else {
      rtsiSetSolverStopTime(&buoyancy_simulation_M->solverInfo,
                            ((buoyancy_simulation_M->Timing.clockTick0 + 1) *
        buoyancy_simulation_M->Timing.stepSize0 +
        buoyancy_simulation_M->Timing.clockTickH0 *
        buoyancy_simulation_M->Timing.stepSize0 * 4294967296.0));
    }
  }                                    /* end MajorTimeStep */

  /* Update absolute time of base rate at minor time step */
  if (rtmIsMinorTimeStep(buoyancy_simulation_M)) {
    buoyancy_simulation_M->Timing.t[0] = rtsiGetT
      (&buoyancy_simulation_M->solverInfo);
  }

  /* Integrator: '<Root>/Integrator1' */
  buoyancy_simulation_B.Deptj = buoyancy_simulation_X.Integrator1_CSTATE;
  if (rtmIsMajorTimeStep(buoyancy_simulation_M)) {
  }

  /* Step: '<Root>/Step' */
  if (buoyancy_simulation_M->Timing.t[0] < buoyancy_simulation_P.Step_Time) {
    tmp = buoyancy_simulation_P.Step_Y0;
  } else {
    tmp = buoyancy_simulation_P.Step_YFinal;
  }

  /* Sum: '<Root>/Add' incorporates:
   *  Step: '<Root>/Step'
   */
  rtb_edeptherror = tmp - buoyancy_simulation_B.Deptj;

  /* Integrator: '<Root>/Integrator' */
  rtb_Speed = buoyancy_simulation_X.Integrator_CSTATE_o;

  /* MATLAB Function: '<Root>/MATLAB Function' */
  buoyancy_simulat_MATLABFunction(buoyancy_simulation_B.Deptj, rtb_Speed,
    &buoyancy_simulation_B.sf_MATLABFunction_a);

  /* Saturate: '<S1>/Saturation' incorporates:
   *  Integrator: '<S1>/Integrator'
   */
  if (buoyancy_simulation_X.Integrator_CSTATE >
      buoyancy_simulation_P.Saturation_UpperSat) {
    tmp = buoyancy_simulation_P.Saturation_UpperSat;
  } else if (buoyancy_simulation_X.Integrator_CSTATE <
             buoyancy_simulation_P.Saturation_LowerSat) {
    tmp = buoyancy_simulation_P.Saturation_LowerSat;
  } else {
    tmp = buoyancy_simulation_X.Integrator_CSTATE;
  }

  /* Gain: '<S2>/Gain' incorporates:
   *  Constant: '<S1>/Constant'
   *  Gain: '<S1>/de'
   *  Gain: '<S2>/Gain1'
   *  Saturate: '<S1>/Saturation'
   *  Sum: '<S1>/Add'
   *  Sum: '<S2>/Add'
   */
  rtb_Gain = (buoyancy_simulation_P.density * buoyancy_simulation_P.gravity *
              (buoyancy_simulation_P.surface_buoyancy - tmp) +
              buoyancy_simulation_P.Gain1_Gain *
              buoyancy_simulation_B.sf_MATLABFunction_a.y) * (1.0 /
    buoyancy_simulation_P.mass);

  /* MATLAB Function: '<S2>/MATLAB Function' */
  buoyancy_simulat_MATLABFunction(buoyancy_simulation_B.Deptj, rtb_Gain,
    &buoyancy_simulation_B.sf_MATLABFunction);

  /* Gain: '<S44>/Filter Coefficient' incorporates:
   *  Gain: '<S34>/Derivative Gain'
   *  Integrator: '<S36>/Filter'
   *  Sum: '<S36>/SumD'
   */
  buoyancy_simulation_B.FilterCoefficient =
    (buoyancy_simulation_P.PIDController_D * rtb_edeptherror -
     buoyancy_simulation_X.Filter_CSTATE) *
    buoyancy_simulation_P.PIDController_N;

  /* Gain: '<S4>/Gain2' incorporates:
   *  Gain: '<S46>/Proportional Gain'
   *  Gain: '<S4>/Gain'
   *  Gain: '<S4>/Gain1'
   *  Gain: '<S4>/Motor'
   *  Integrator: '<S41>/Integrator'
   *  Sum: '<S50>/Sum'
   */
  buoyancy_simulation_B.deltaV = ((buoyancy_simulation_P.PIDController_P *
    rtb_edeptherror + buoyancy_simulation_X.Integrator_CSTATE_f) +
    buoyancy_simulation_B.FilterCoefficient) * -buoyancy_simulation_P.km *
    buoyancy_simulation_P.p * buoyancy_simulation_P.Gain1_Gain_o *
    buoyancy_simulation_P.area;

  /* Gain: '<S38>/Integral Gain' */
  buoyancy_simulation_B.IntegralGain = buoyancy_simulation_P.PIDController_I *
    rtb_edeptherror;
  if (rtmIsMajorTimeStep(buoyancy_simulation_M)) {
    /* Matfile logging */
    rt_UpdateTXYLogVars(buoyancy_simulation_M->rtwLogInfo,
                        (buoyancy_simulation_M->Timing.t));
  }                                    /* end MajorTimeStep */

  if (rtmIsMajorTimeStep(buoyancy_simulation_M)) {
    /* signal main to stop simulation */
    {                                  /* Sample time: [0.0s, 0.0s] */
      if ((rtmGetTFinal(buoyancy_simulation_M)!=-1) &&
          !((rtmGetTFinal(buoyancy_simulation_M)-
             (((buoyancy_simulation_M->Timing.clockTick1+
                buoyancy_simulation_M->Timing.clockTickH1* 4294967296.0)) * 2.0))
            > (((buoyancy_simulation_M->Timing.clockTick1+
                 buoyancy_simulation_M->Timing.clockTickH1* 4294967296.0)) * 2.0)
            * (DBL_EPSILON))) {
        rtmSetErrorStatus(buoyancy_simulation_M, "Simulation finished");
      }
    }

    rt_ertODEUpdateContinuousStates(&buoyancy_simulation_M->solverInfo);

    /* Update absolute time for base rate */
    /* The "clockTick0" counts the number of times the code of this task has
     * been executed. The absolute time is the multiplication of "clockTick0"
     * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
     * overflow during the application lifespan selected.
     * Timer of this task consists of two 32 bit unsigned integers.
     * The two integers represent the low bits Timing.clockTick0 and the high bits
     * Timing.clockTickH0. When the low bit overflows to 0, the high bits increment.
     */
    if (!(++buoyancy_simulation_M->Timing.clockTick0)) {
      ++buoyancy_simulation_M->Timing.clockTickH0;
    }

    buoyancy_simulation_M->Timing.t[0] = rtsiGetSolverStopTime
      (&buoyancy_simulation_M->solverInfo);

    {
      /* Update absolute timer for sample time: [2.0s, 0.0s] */
      /* The "clockTick1" counts the number of times the code of this task has
       * been executed. The resolution of this integer timer is 2.0, which is the step size
       * of the task. Size of "clockTick1" ensures timer will not overflow during the
       * application lifespan selected.
       * Timer of this task consists of two 32 bit unsigned integers.
       * The two integers represent the low bits Timing.clockTick1 and the high bits
       * Timing.clockTickH1. When the low bit overflows to 0, the high bits increment.
       */
      buoyancy_simulation_M->Timing.clockTick1++;
      if (!buoyancy_simulation_M->Timing.clockTick1) {
        buoyancy_simulation_M->Timing.clockTickH1++;
      }
    }
  }                                    /* end MajorTimeStep */
}

/* Derivatives for root system: '<Root>' */
void buoyancy_simulation_derivatives(void)
{
  XDot_buoyancy_simulation_T *_rtXdot;
  _rtXdot = ((XDot_buoyancy_simulation_T *) buoyancy_simulation_M->derivs);

  /* Derivatives for Integrator: '<Root>/Integrator1' */
  _rtXdot->Integrator1_CSTATE = buoyancy_simulation_B.sf_MATLABFunction_a.y;

  /* Derivatives for Integrator: '<S1>/Integrator' */
  _rtXdot->Integrator_CSTATE = buoyancy_simulation_B.deltaV;

  /* Derivatives for Integrator: '<Root>/Integrator' */
  _rtXdot->Integrator_CSTATE_o = buoyancy_simulation_B.sf_MATLABFunction.y;

  /* Derivatives for Integrator: '<S41>/Integrator' */
  _rtXdot->Integrator_CSTATE_f = buoyancy_simulation_B.IntegralGain;

  /* Derivatives for Integrator: '<S36>/Filter' */
  _rtXdot->Filter_CSTATE = buoyancy_simulation_B.FilterCoefficient;
}

/* Model initialize function */
void buoyancy_simulation_initialize(void)
{
  /* Registration code */

  /* initialize real-time model */
  (void) memset((void *)buoyancy_simulation_M, 0,
                sizeof(RT_MODEL_buoyancy_simulation_T));

  {
    /* Setup solver object */
    rtsiSetSimTimeStepPtr(&buoyancy_simulation_M->solverInfo,
                          &buoyancy_simulation_M->Timing.simTimeStep);
    rtsiSetTPtr(&buoyancy_simulation_M->solverInfo, &rtmGetTPtr
                (buoyancy_simulation_M));
    rtsiSetStepSizePtr(&buoyancy_simulation_M->solverInfo,
                       &buoyancy_simulation_M->Timing.stepSize0);
    rtsiSetdXPtr(&buoyancy_simulation_M->solverInfo,
                 &buoyancy_simulation_M->derivs);
    rtsiSetContStatesPtr(&buoyancy_simulation_M->solverInfo, (real_T **)
                         &buoyancy_simulation_M->contStates);
    rtsiSetNumContStatesPtr(&buoyancy_simulation_M->solverInfo,
      &buoyancy_simulation_M->Sizes.numContStates);
    rtsiSetNumPeriodicContStatesPtr(&buoyancy_simulation_M->solverInfo,
      &buoyancy_simulation_M->Sizes.numPeriodicContStates);
    rtsiSetPeriodicContStateIndicesPtr(&buoyancy_simulation_M->solverInfo,
      &buoyancy_simulation_M->periodicContStateIndices);
    rtsiSetPeriodicContStateRangesPtr(&buoyancy_simulation_M->solverInfo,
      &buoyancy_simulation_M->periodicContStateRanges);
    rtsiSetContStateDisabledPtr(&buoyancy_simulation_M->solverInfo, (boolean_T**)
      &buoyancy_simulation_M->contStateDisabled);
    rtsiSetErrorStatusPtr(&buoyancy_simulation_M->solverInfo,
                          (&rtmGetErrorStatus(buoyancy_simulation_M)));
    rtsiSetRTModelPtr(&buoyancy_simulation_M->solverInfo, buoyancy_simulation_M);
  }

  rtsiSetSimTimeStep(&buoyancy_simulation_M->solverInfo, MAJOR_TIME_STEP);
  rtsiSetIsMinorTimeStepWithModeChange(&buoyancy_simulation_M->solverInfo, false);
  rtsiSetIsContModeFrozen(&buoyancy_simulation_M->solverInfo, false);
  buoyancy_simulation_M->intgData.y = buoyancy_simulation_M->odeY;
  buoyancy_simulation_M->intgData.f[0] = buoyancy_simulation_M->odeF[0];
  buoyancy_simulation_M->intgData.f[1] = buoyancy_simulation_M->odeF[1];
  buoyancy_simulation_M->intgData.f[2] = buoyancy_simulation_M->odeF[2];
  buoyancy_simulation_M->contStates = ((X_buoyancy_simulation_T *)
    &buoyancy_simulation_X);
  buoyancy_simulation_M->contStateDisabled = ((XDis_buoyancy_simulation_T *)
    &buoyancy_simulation_XDis);
  buoyancy_simulation_M->Timing.tStart = (0.0);
  rtsiSetSolverData(&buoyancy_simulation_M->solverInfo, (void *)
                    &buoyancy_simulation_M->intgData);
  rtsiSetSolverName(&buoyancy_simulation_M->solverInfo,"ode3");
  rtmSetTPtr(buoyancy_simulation_M, &buoyancy_simulation_M->Timing.tArray[0]);
  rtmSetTFinal(buoyancy_simulation_M, 100.0);
  buoyancy_simulation_M->Timing.stepSize0 = 2.0;

  /* Setup for data logging */
  {
    static RTWLogInfo rt_DataLoggingInfo;
    rt_DataLoggingInfo.loggingInterval = (NULL);
    buoyancy_simulation_M->rtwLogInfo = &rt_DataLoggingInfo;
  }

  /* Setup for data logging */
  {
    rtliSetLogXSignalInfo(buoyancy_simulation_M->rtwLogInfo, (NULL));
    rtliSetLogXSignalPtrs(buoyancy_simulation_M->rtwLogInfo, (NULL));
    rtliSetLogT(buoyancy_simulation_M->rtwLogInfo, "tout");
    rtliSetLogX(buoyancy_simulation_M->rtwLogInfo, "");
    rtliSetLogXFinal(buoyancy_simulation_M->rtwLogInfo, "");
    rtliSetLogVarNameModifier(buoyancy_simulation_M->rtwLogInfo, "rt_");
    rtliSetLogFormat(buoyancy_simulation_M->rtwLogInfo, 4);
    rtliSetLogMaxRows(buoyancy_simulation_M->rtwLogInfo, 0);
    rtliSetLogDecimation(buoyancy_simulation_M->rtwLogInfo, 1);
    rtliSetLogY(buoyancy_simulation_M->rtwLogInfo, "");
    rtliSetLogYSignalInfo(buoyancy_simulation_M->rtwLogInfo, (NULL));
    rtliSetLogYSignalPtrs(buoyancy_simulation_M->rtwLogInfo, (NULL));
  }

  /* block I/O */
  (void) memset(((void *) &buoyancy_simulation_B), 0,
                sizeof(B_buoyancy_simulation_T));

  /* states (continuous) */
  {
    (void) memset((void *)&buoyancy_simulation_X, 0,
                  sizeof(X_buoyancy_simulation_T));
  }

  /* disabled states */
  {
    (void) memset((void *)&buoyancy_simulation_XDis, 0,
                  sizeof(XDis_buoyancy_simulation_T));
  }

  /* Matfile logging */
  rt_StartDataLoggingWithStartTime(buoyancy_simulation_M->rtwLogInfo, 0.0,
    rtmGetTFinal(buoyancy_simulation_M), buoyancy_simulation_M->Timing.stepSize0,
    (&rtmGetErrorStatus(buoyancy_simulation_M)));

  /* InitializeConditions for Integrator: '<Root>/Integrator1' */
  buoyancy_simulation_X.Integrator1_CSTATE =
    buoyancy_simulation_P.Integrator1_IC;

  /* InitializeConditions for Integrator: '<S1>/Integrator' */
  buoyancy_simulation_X.Integrator_CSTATE = buoyancy_simulation_P.Integrator_IC;

  /* InitializeConditions for Integrator: '<Root>/Integrator' */
  buoyancy_simulation_X.Integrator_CSTATE_o =
    buoyancy_simulation_P.Integrator_IC_a;

  /* InitializeConditions for Integrator: '<S41>/Integrator' */
  buoyancy_simulation_X.Integrator_CSTATE_f =
    buoyancy_simulation_P.PIDController_InitialConditio_g;

  /* InitializeConditions for Integrator: '<S36>/Filter' */
  buoyancy_simulation_X.Filter_CSTATE =
    buoyancy_simulation_P.PIDController_InitialConditionF;
}

/* Model terminate function */
void buoyancy_simulation_terminate(void)
{
  /* (no terminate code required) */
}
