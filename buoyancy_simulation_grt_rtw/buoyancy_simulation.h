/*
 * buoyancy_simulation.h
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

#ifndef buoyancy_simulation_h_
#define buoyancy_simulation_h_
#ifndef buoyancy_simulation_COMMON_INCLUDES_
#define buoyancy_simulation_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#include "rt_logging.h"
#include "rt_nonfinite.h"
#include "math.h"
#endif                                /* buoyancy_simulation_COMMON_INCLUDES_ */

#include "buoyancy_simulation_types.h"
#include <float.h>
#include <string.h>
#include <stddef.h>

/* Macros for accessing real-time model data structure */
#ifndef rtmGetContStateDisabled
#define rtmGetContStateDisabled(rtm)   ((rtm)->contStateDisabled)
#endif

#ifndef rtmSetContStateDisabled
#define rtmSetContStateDisabled(rtm, val) ((rtm)->contStateDisabled = (val))
#endif

#ifndef rtmGetContStates
#define rtmGetContStates(rtm)          ((rtm)->contStates)
#endif

#ifndef rtmSetContStates
#define rtmSetContStates(rtm, val)     ((rtm)->contStates = (val))
#endif

#ifndef rtmGetContTimeOutputInconsistentWithStateAtMajorStepFlag
#define rtmGetContTimeOutputInconsistentWithStateAtMajorStepFlag(rtm) ((rtm)->CTOutputIncnstWithState)
#endif

#ifndef rtmSetContTimeOutputInconsistentWithStateAtMajorStepFlag
#define rtmSetContTimeOutputInconsistentWithStateAtMajorStepFlag(rtm, val) ((rtm)->CTOutputIncnstWithState = (val))
#endif

#ifndef rtmGetDerivCacheNeedsReset
#define rtmGetDerivCacheNeedsReset(rtm) ((rtm)->derivCacheNeedsReset)
#endif

#ifndef rtmSetDerivCacheNeedsReset
#define rtmSetDerivCacheNeedsReset(rtm, val) ((rtm)->derivCacheNeedsReset = (val))
#endif

#ifndef rtmGetFinalTime
#define rtmGetFinalTime(rtm)           ((rtm)->Timing.tFinal)
#endif

#ifndef rtmGetIntgData
#define rtmGetIntgData(rtm)            ((rtm)->intgData)
#endif

#ifndef rtmSetIntgData
#define rtmSetIntgData(rtm, val)       ((rtm)->intgData = (val))
#endif

#ifndef rtmGetOdeF
#define rtmGetOdeF(rtm)                ((rtm)->odeF)
#endif

#ifndef rtmSetOdeF
#define rtmSetOdeF(rtm, val)           ((rtm)->odeF = (val))
#endif

#ifndef rtmGetOdeY
#define rtmGetOdeY(rtm)                ((rtm)->odeY)
#endif

#ifndef rtmSetOdeY
#define rtmSetOdeY(rtm, val)           ((rtm)->odeY = (val))
#endif

#ifndef rtmGetPeriodicContStateIndices
#define rtmGetPeriodicContStateIndices(rtm) ((rtm)->periodicContStateIndices)
#endif

#ifndef rtmSetPeriodicContStateIndices
#define rtmSetPeriodicContStateIndices(rtm, val) ((rtm)->periodicContStateIndices = (val))
#endif

#ifndef rtmGetPeriodicContStateRanges
#define rtmGetPeriodicContStateRanges(rtm) ((rtm)->periodicContStateRanges)
#endif

#ifndef rtmSetPeriodicContStateRanges
#define rtmSetPeriodicContStateRanges(rtm, val) ((rtm)->periodicContStateRanges = (val))
#endif

#ifndef rtmGetRTWLogInfo
#define rtmGetRTWLogInfo(rtm)          ((rtm)->rtwLogInfo)
#endif

#ifndef rtmGetZCCacheNeedsReset
#define rtmGetZCCacheNeedsReset(rtm)   ((rtm)->zCCacheNeedsReset)
#endif

#ifndef rtmSetZCCacheNeedsReset
#define rtmSetZCCacheNeedsReset(rtm, val) ((rtm)->zCCacheNeedsReset = (val))
#endif

#ifndef rtmGetdX
#define rtmGetdX(rtm)                  ((rtm)->derivs)
#endif

#ifndef rtmSetdX
#define rtmSetdX(rtm, val)             ((rtm)->derivs = (val))
#endif

#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

#ifndef rtmGetStopRequested
#define rtmGetStopRequested(rtm)       ((rtm)->Timing.stopRequestedFlag)
#endif

#ifndef rtmSetStopRequested
#define rtmSetStopRequested(rtm, val)  ((rtm)->Timing.stopRequestedFlag = (val))
#endif

#ifndef rtmGetStopRequestedPtr
#define rtmGetStopRequestedPtr(rtm)    (&((rtm)->Timing.stopRequestedFlag))
#endif

#ifndef rtmGetT
#define rtmGetT(rtm)                   (rtmGetTPtr((rtm))[0])
#endif

#ifndef rtmGetTFinal
#define rtmGetTFinal(rtm)              ((rtm)->Timing.tFinal)
#endif

#ifndef rtmGetTPtr
#define rtmGetTPtr(rtm)                ((rtm)->Timing.t)
#endif

#ifndef rtmGetTStart
#define rtmGetTStart(rtm)              ((rtm)->Timing.tStart)
#endif

/* Block signals for system '<S2>/MATLAB Function' */
typedef struct {
  real_T y;                            /* '<S2>/MATLAB Function' */
} B_MATLABFunction_buoyancy_sim_T;

/* Block signals (default storage) */
typedef struct {
  real_T Deptj;                        /* '<Root>/Integrator1' */
  real_T FilterCoefficient;            /* '<S44>/Filter Coefficient' */
  real_T deltaV;                       /* '<S4>/Gain2' */
  real_T IntegralGain;                 /* '<S38>/Integral Gain' */
  B_MATLABFunction_buoyancy_sim_T sf_MATLABFunction_a;/* '<Root>/MATLAB Function' */
  B_MATLABFunction_buoyancy_sim_T sf_MATLABFunction;/* '<S2>/MATLAB Function' */
} B_buoyancy_simulation_T;

/* Continuous states (default storage) */
typedef struct {
  real_T Integrator1_CSTATE;           /* '<Root>/Integrator1' */
  real_T Integrator_CSTATE;            /* '<S1>/Integrator' */
  real_T Integrator_CSTATE_o;          /* '<Root>/Integrator' */
  real_T Integrator_CSTATE_f;          /* '<S41>/Integrator' */
  real_T Filter_CSTATE;                /* '<S36>/Filter' */
} X_buoyancy_simulation_T;

/* State derivatives (default storage) */
typedef struct {
  real_T Integrator1_CSTATE;           /* '<Root>/Integrator1' */
  real_T Integrator_CSTATE;            /* '<S1>/Integrator' */
  real_T Integrator_CSTATE_o;          /* '<Root>/Integrator' */
  real_T Integrator_CSTATE_f;          /* '<S41>/Integrator' */
  real_T Filter_CSTATE;                /* '<S36>/Filter' */
} XDot_buoyancy_simulation_T;

/* State disabled  */
typedef struct {
  boolean_T Integrator1_CSTATE;        /* '<Root>/Integrator1' */
  boolean_T Integrator_CSTATE;         /* '<S1>/Integrator' */
  boolean_T Integrator_CSTATE_o;       /* '<Root>/Integrator' */
  boolean_T Integrator_CSTATE_f;       /* '<S41>/Integrator' */
  boolean_T Filter_CSTATE;             /* '<S36>/Filter' */
} XDis_buoyancy_simulation_T;

#ifndef ODE3_INTG
#define ODE3_INTG

/* ODE3 Integration Data */
typedef struct {
  real_T *y;                           /* output */
  real_T *f[3];                        /* derivatives */
} ODE3_IntgData;

#endif

/* Parameters (default storage) */
struct P_buoyancy_simulation_T_ {
  real_T area;                         /* Variable: area
                                        * Referenced by: '<S4>/Gain2'
                                        */
  real_T density;                      /* Variable: density
                                        * Referenced by: '<S1>/de'
                                        */
  real_T gravity;                      /* Variable: gravity
                                        * Referenced by: '<S1>/de'
                                        */
  real_T km;                           /* Variable: km
                                        * Referenced by: '<S4>/Motor'
                                        */
  real_T mass;                         /* Variable: mass
                                        * Referenced by: '<S2>/Gain'
                                        */
  real_T p;                            /* Variable: p
                                        * Referenced by: '<S4>/Gain'
                                        */
  real_T surface_buoyancy;             /* Variable: surface_buoyancy
                                        * Referenced by: '<S1>/Constant'
                                        */
  real_T PIDController_D;              /* Mask Parameter: PIDController_D
                                        * Referenced by: '<S34>/Derivative Gain'
                                        */
  real_T PIDController_I;              /* Mask Parameter: PIDController_I
                                        * Referenced by: '<S38>/Integral Gain'
                                        */
  real_T PIDController_InitialConditionF;
                              /* Mask Parameter: PIDController_InitialConditionF
                               * Referenced by: '<S36>/Filter'
                               */
  real_T PIDController_InitialConditio_g;
                              /* Mask Parameter: PIDController_InitialConditio_g
                               * Referenced by: '<S41>/Integrator'
                               */
  real_T PIDController_N;              /* Mask Parameter: PIDController_N
                                        * Referenced by: '<S44>/Filter Coefficient'
                                        */
  real_T PIDController_P;              /* Mask Parameter: PIDController_P
                                        * Referenced by: '<S46>/Proportional Gain'
                                        */
  real_T Integrator1_IC;               /* Expression: 0
                                        * Referenced by: '<Root>/Integrator1'
                                        */
  real_T Step_Time;                    /* Expression: 1
                                        * Referenced by: '<Root>/Step'
                                        */
  real_T Step_Y0;                      /* Expression: 0
                                        * Referenced by: '<Root>/Step'
                                        */
  real_T Step_YFinal;                  /* Expression: -3
                                        * Referenced by: '<Root>/Step'
                                        */
  real_T Integrator_IC;                /* Expression: 0
                                        * Referenced by: '<S1>/Integrator'
                                        */
  real_T Saturation_UpperSat;          /* Expression: 500
                                        * Referenced by: '<S1>/Saturation'
                                        */
  real_T Saturation_LowerSat;          /* Expression: -500
                                        * Referenced by: '<S1>/Saturation'
                                        */
  real_T Integrator_IC_a;              /* Expression: 0
                                        * Referenced by: '<Root>/Integrator'
                                        */
  real_T Gain1_Gain;                   /* Expression: 0.1
                                        * Referenced by: '<S2>/Gain1'
                                        */
  real_T Gain1_Gain_o;                 /* Expression: 1000
                                        * Referenced by: '<S4>/Gain1'
                                        */
};

/* Real-time Model Data Structure */
struct tag_RTM_buoyancy_simulation_T {
  const char_T *errorStatus;
  RTWLogInfo *rtwLogInfo;
  RTWSolverInfo solverInfo;
  X_buoyancy_simulation_T *contStates;
  int_T *periodicContStateIndices;
  real_T *periodicContStateRanges;
  real_T *derivs;
  XDis_buoyancy_simulation_T *contStateDisabled;
  boolean_T zCCacheNeedsReset;
  boolean_T derivCacheNeedsReset;
  boolean_T CTOutputIncnstWithState;
  real_T odeY[5];
  real_T odeF[3][5];
  ODE3_IntgData intgData;

  /*
   * Sizes:
   * The following substructure contains sizes information
   * for many of the model attributes such as inputs, outputs,
   * dwork, sample times, etc.
   */
  struct {
    int_T numContStates;
    int_T numPeriodicContStates;
    int_T numSampTimes;
  } Sizes;

  /*
   * Timing:
   * The following substructure contains information regarding
   * the timing information for the model.
   */
  struct {
    uint32_T clockTick0;
    uint32_T clockTickH0;
    time_T stepSize0;
    uint32_T clockTick1;
    uint32_T clockTickH1;
    time_T tStart;
    time_T tFinal;
    SimTimeStep simTimeStep;
    boolean_T stopRequestedFlag;
    time_T *t;
    time_T tArray[2];
  } Timing;
};

/* Block parameters (default storage) */
extern P_buoyancy_simulation_T buoyancy_simulation_P;

/* Block signals (default storage) */
extern B_buoyancy_simulation_T buoyancy_simulation_B;

/* Continuous states (default storage) */
extern X_buoyancy_simulation_T buoyancy_simulation_X;

/* Disabled states (default storage) */
extern XDis_buoyancy_simulation_T buoyancy_simulation_XDis;

/* Model entry point functions */
extern void buoyancy_simulation_initialize(void);
extern void buoyancy_simulation_step(void);
extern void buoyancy_simulation_terminate(void);

/* Real-time Model object */
extern RT_MODEL_buoyancy_simulation_T *const buoyancy_simulation_M;

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'buoyancy_simulation'
 * '<S1>'   : 'buoyancy_simulation/Buoyant force'
 * '<S2>'   : 'buoyancy_simulation/Heave Plant'
 * '<S3>'   : 'buoyancy_simulation/MATLAB Function'
 * '<S4>'   : 'buoyancy_simulation/Motor and lead screw'
 * '<S5>'   : 'buoyancy_simulation/PID Controller'
 * '<S6>'   : 'buoyancy_simulation/Heave Plant/MATLAB Function'
 * '<S7>'   : 'buoyancy_simulation/PID Controller/Anti-windup'
 * '<S8>'   : 'buoyancy_simulation/PID Controller/D Gain'
 * '<S9>'   : 'buoyancy_simulation/PID Controller/External Derivative'
 * '<S10>'  : 'buoyancy_simulation/PID Controller/Filter'
 * '<S11>'  : 'buoyancy_simulation/PID Controller/Filter ICs'
 * '<S12>'  : 'buoyancy_simulation/PID Controller/I Gain'
 * '<S13>'  : 'buoyancy_simulation/PID Controller/Ideal P Gain'
 * '<S14>'  : 'buoyancy_simulation/PID Controller/Ideal P Gain Fdbk'
 * '<S15>'  : 'buoyancy_simulation/PID Controller/Integrator'
 * '<S16>'  : 'buoyancy_simulation/PID Controller/Integrator ICs'
 * '<S17>'  : 'buoyancy_simulation/PID Controller/N Copy'
 * '<S18>'  : 'buoyancy_simulation/PID Controller/N Gain'
 * '<S19>'  : 'buoyancy_simulation/PID Controller/P Copy'
 * '<S20>'  : 'buoyancy_simulation/PID Controller/Parallel P Gain'
 * '<S21>'  : 'buoyancy_simulation/PID Controller/Reset Signal'
 * '<S22>'  : 'buoyancy_simulation/PID Controller/Saturation'
 * '<S23>'  : 'buoyancy_simulation/PID Controller/Saturation Fdbk'
 * '<S24>'  : 'buoyancy_simulation/PID Controller/Sum'
 * '<S25>'  : 'buoyancy_simulation/PID Controller/Sum Fdbk'
 * '<S26>'  : 'buoyancy_simulation/PID Controller/Tracking Mode'
 * '<S27>'  : 'buoyancy_simulation/PID Controller/Tracking Mode Sum'
 * '<S28>'  : 'buoyancy_simulation/PID Controller/Tsamp - Integral'
 * '<S29>'  : 'buoyancy_simulation/PID Controller/Tsamp - Ngain'
 * '<S30>'  : 'buoyancy_simulation/PID Controller/postSat Signal'
 * '<S31>'  : 'buoyancy_simulation/PID Controller/preInt Signal'
 * '<S32>'  : 'buoyancy_simulation/PID Controller/preSat Signal'
 * '<S33>'  : 'buoyancy_simulation/PID Controller/Anti-windup/Passthrough'
 * '<S34>'  : 'buoyancy_simulation/PID Controller/D Gain/Internal Parameters'
 * '<S35>'  : 'buoyancy_simulation/PID Controller/External Derivative/Error'
 * '<S36>'  : 'buoyancy_simulation/PID Controller/Filter/Cont. Filter'
 * '<S37>'  : 'buoyancy_simulation/PID Controller/Filter ICs/Internal IC - Filter'
 * '<S38>'  : 'buoyancy_simulation/PID Controller/I Gain/Internal Parameters'
 * '<S39>'  : 'buoyancy_simulation/PID Controller/Ideal P Gain/Passthrough'
 * '<S40>'  : 'buoyancy_simulation/PID Controller/Ideal P Gain Fdbk/Disabled'
 * '<S41>'  : 'buoyancy_simulation/PID Controller/Integrator/Continuous'
 * '<S42>'  : 'buoyancy_simulation/PID Controller/Integrator ICs/Internal IC'
 * '<S43>'  : 'buoyancy_simulation/PID Controller/N Copy/Disabled'
 * '<S44>'  : 'buoyancy_simulation/PID Controller/N Gain/Internal Parameters'
 * '<S45>'  : 'buoyancy_simulation/PID Controller/P Copy/Disabled'
 * '<S46>'  : 'buoyancy_simulation/PID Controller/Parallel P Gain/Internal Parameters'
 * '<S47>'  : 'buoyancy_simulation/PID Controller/Reset Signal/Disabled'
 * '<S48>'  : 'buoyancy_simulation/PID Controller/Saturation/Passthrough'
 * '<S49>'  : 'buoyancy_simulation/PID Controller/Saturation Fdbk/Disabled'
 * '<S50>'  : 'buoyancy_simulation/PID Controller/Sum/Sum_PID'
 * '<S51>'  : 'buoyancy_simulation/PID Controller/Sum Fdbk/Disabled'
 * '<S52>'  : 'buoyancy_simulation/PID Controller/Tracking Mode/Disabled'
 * '<S53>'  : 'buoyancy_simulation/PID Controller/Tracking Mode Sum/Passthrough'
 * '<S54>'  : 'buoyancy_simulation/PID Controller/Tsamp - Integral/TsSignalSpecification'
 * '<S55>'  : 'buoyancy_simulation/PID Controller/Tsamp - Ngain/Passthrough'
 * '<S56>'  : 'buoyancy_simulation/PID Controller/postSat Signal/Forward_Path'
 * '<S57>'  : 'buoyancy_simulation/PID Controller/preInt Signal/Internal PreInt'
 * '<S58>'  : 'buoyancy_simulation/PID Controller/preSat Signal/Forward_Path'
 */
#endif                                 /* buoyancy_simulation_h_ */
