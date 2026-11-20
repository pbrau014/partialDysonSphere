(* ========================================================================
   POLAR COLLECTOR — PHASE 1 WOLFRAM LANGUAGE PACKAGE
   Revision: v11.27

   Package interface:
     Context: Phase1PolarCollector`
     Implementation helpers and runtime state live in Phase1PolarCollector`Private`.
     Load with: Get["Phase1_Polar_Collector_Model_v11_27.wl"];

   Supplied archive reviewed separately:
     English.zip identifies itself as the WolframDocumentationStub English paclet,
     version 12.3.0.0, minimum Wolfram Language 12.2. The archive's package examples
     illustrate BeginPackage/Begin/End/EndPackage, private implementation contexts,
     assertions, and VerificationTest. Its ExampleData files are import/export fixtures,
     not polar-collector engineering specifications. No project geometry, material,
     actuator, operating, or acceptance value is taken from that archive.

   Governing two-pole architecture:
     Exactly two physically separate collector systems, one at each pole. They share
     design/material definitions only. Their operating inputs, environment, disturbances,
     initial conditions, controllers, dynamics, caches, results, optimization, and
     acceptance decisions are independent. Each pole's calculations execute in an
     isolated local state. Aggregate mass/area/power are reporting-only scalar sums and
     never feed either pole's operation. No combined mechanical equilibrium is imposed.

   Governing objective:
     Maximize delivered electrical power for each pole, subject to that pole's own
     exact natural vector-force/torque equilibrium and its thermal, dynamic, actuator,
     and reduced-order structural constraints.

   Input policy:
     PoleCount = 2 is the only project-specific populated default. Other project-specific
     design, material, operating, disturbance, model-form, and acceptance values remain
     Missing until entered. Published physical constants, SI definitions, standardized
     PV reference test conditions, fraction domains, and numerical execution conventions
     are reference/software definitions, not populated collector operating values.
     Source notes are optional metadata. Their absence never blocks readiness,
     calculation, validation, cache freshness, or acceptance.

   Numerical model limits:
     This is a Phase 1 engineering-screening model, not a qualified flight design.
     Geometry, mass distribution, membrane constitutive response, station-to-membrane
     load transfer, and attitude restoring are explicit reduced-order model choices.
     They are not CAD-derived geometry, validated finite-element stress analysis, or
     qualified actuator performance unless replaced by the corresponding engineering models.

   Recommended start sequence:
     Phase1InputStatus[];
     Phase1RunSoftwareSelfTests[];
     Phase1PoleIndependenceAudit[];
     Phase1InputRequirements[];
     Phase1InteractivePanel[];
     Phase1PoleOperatingInputPanel["Pole1"];
     Phase1PoleOperatingInputPanel["Pole2"];
     (* Enter required values in the shared design/material and separate pole registers. *)
     Phase1InputStatus[];
     Phase1ComputeAll[];
     Phase1Validate[];
     Phase1RunSelfTests[];
     Phase1RunFullAssessment[];
     Phase1RunReport[];
   ======================================================================== *)

BeginPackage["Phase1PolarCollector`"];
Phase1ApplyOptimizationCandidate::usage = "Phase1ApplyOptimizationCandidate is part of the Phase1PolarCollector package API.";
Phase1ComputeAll::usage = "Phase1ComputeAll[] calculates Pole1 and Pole2 independently, then aggregates scalar results for reporting only.";
Phase1ComputePole::usage = "Phase1ComputePole[pole] calculates one pole in an isolated execution context.";
Phase1DistanceThermalFloor::usage = "Phase1DistanceThermalFloor is part of the Phase1PolarCollector package API.";
Phase1DisturbanceScenarios::usage = "Phase1DisturbanceScenarios is part of the Phase1PolarCollector package API.";
Phase1DynamicInitialConditions::usage = "Phase1DynamicInitialConditions is part of the Phase1PolarCollector package API.";
Phase1FreeRotationTrajectory::usage = "Phase1FreeRotationTrajectory is part of the Phase1PolarCollector package API.";
Phase1GetDerived::usage = "Phase1GetDerived is part of the Phase1PolarCollector package API.";
Phase1GetInput::usage = "Phase1GetInput is part of the Phase1PolarCollector package API.";
Phase1GetInputs::usage = "Phase1GetInputs is part of the Phase1PolarCollector package API.";
Phase1GetLegacyInputArchive::usage = "Phase1GetLegacyInputArchive is part of the Phase1PolarCollector package API.";
Phase1GetPoleDerived::usage = "Phase1GetPoleDerived is part of the Phase1PolarCollector package API.";
Phase1GetPoleInputs::usage = "Phase1GetPoleInputs is part of the Phase1PolarCollector package API.";
Phase1GetPoleResult::usage = "Phase1GetPoleResult is part of the Phase1PolarCollector package API.";
Phase1GetPoleResults::usage = "Phase1GetPoleResults is part of the Phase1PolarCollector package API.";
Phase1GetPoleState::usage = "Phase1GetPoleState is part of the Phase1PolarCollector package API.";
Phase1GetResult::usage = "Phase1GetResult is part of the Phase1PolarCollector package API.";
Phase1GetResults::usage = "Phase1GetResults is part of the Phase1PolarCollector package API.";
Phase1GetSharedInputs::usage = "Phase1GetSharedInputs is part of the Phase1PolarCollector package API.";
Phase1GetState::usage = "Phase1GetState is part of the Phase1PolarCollector package API.";
Phase1ICARUSControlLaw::usage = "Phase1ICARUSControlLaw is part of the Phase1PolarCollector package API.";
Phase1ICARUSLoadPropagation::usage = "Phase1ICARUSLoadPropagation is part of the Phase1PolarCollector package API.";
Phase1InputRequirements::usage = "Phase1InputRequirements[] reports input categories and required values for the shared design/material register and each pole.";
Phase1InputStatus::usage = "Phase1InputStatus[] reports missing required values; optional source notes do not affect readiness.";
Phase1IntegratedSimulation::usage = "Phase1IntegratedSimulation is part of the Phase1PolarCollector package API.";
Phase1InteractivePanel::usage = "Phase1InteractivePanel is part of the Phase1PolarCollector package API.";
Phase1JointOptimization::usage = "Phase1JointOptimization is part of the Phase1PolarCollector package API.";
Phase1LoadState::usage = "Phase1LoadState is part of the Phase1PolarCollector package API.";
Phase1LocalRadiationLoads::usage = "Phase1LocalRadiationLoads is part of the Phase1PolarCollector package API.";
Phase1LocalSurfaceMesh::usage = "Phase1LocalSurfaceMesh is part of the Phase1PolarCollector package API.";
Phase1MassBalance::usage = "Phase1MassBalance is part of the Phase1PolarCollector package API.";
Phase1MissingRequiredInputs::usage = "Phase1MissingRequiredInputs is part of the Phase1PolarCollector package API.";
Phase1MissingRequiredProvenance::usage = "Compatibility function. Returns {} because optional source notes are not required and are not required for calculation.";
Phase1Phase2Handoff::usage = "Phase1Phase2Handoff is part of the Phase1PolarCollector package API.";
Phase1PoleIndependenceAudit::usage = "Phase1PoleIndependenceAudit is part of the Phase1PolarCollector package API.";
Phase1PoleOperatingInputPanel::usage = "Phase1PoleOperatingInputPanel is part of the Phase1PolarCollector package API.";
Phase1PowerLedger::usage = "Phase1PowerLedger is part of the Phase1PolarCollector package API.";
Phase1Reset::usage = "Phase1Reset is part of the Phase1PolarCollector package API.";
Phase1RunBothPoleAssessments::usage = "Phase1RunBothPoleAssessments is part of the Phase1PolarCollector package API.";
Phase1RunFullAssessment::usage = "Phase1RunFullAssessment is part of the Phase1PolarCollector package API.";
Phase1RunPoleAssessment::usage = "Phase1RunPoleAssessment is part of the Phase1PolarCollector package API.";
Phase1RunPoleTask::usage = "Phase1RunPoleTask is part of the Phase1PolarCollector package API.";
Phase1RunReport::usage = "Phase1RunReport is part of the Phase1PolarCollector package API.";
Phase1RunSelfTests::usage = "Phase1RunSelfTests[] runs software-only tests and, when inputs are complete, calculation-integrity tests for each pole.";
Phase1RunSoftwareSelfTests::usage = "Phase1RunSoftwareSelfTests[] runs software-only synthetic tests without requiring project inputs or mutating project state.";
Phase1SaveState::usage = "Phase1SaveState is part of the Phase1PolarCollector package API.";
Phase1SelectPole::usage = "Phase1SelectPole is part of the Phase1PolarCollector package API.";
Phase1SetInputProvenance::usage = "Compatibility API for storing optional descriptive source notes; notes are never required for calculations.";
Phase1SetInputs::usage = "Phase1SetInputs[values] updates shared design/material and model inputs. Optional source notes may be supplied as a second association; they never gate calculations.";
Phase1SetPoleOperatingInputProvenance::usage = "Compatibility API for storing optional pole-specific source notes; notes are never required for calculations.";
Phase1SetPoleOperatingInputs::usage = "Phase1SetPoleOperatingInputs[pole, values] updates only the selected pole operating register. Pole must be \"Pole1\" or \"Pole2\".";
Phase1SolveExactEquilibrium::usage = "Phase1SolveExactEquilibrium is part of the Phase1PolarCollector package API.";
Phase1StabilityCriteria::usage = "Phase1StabilityCriteria is part of the Phase1PolarCollector package API.";
Phase1ThermalScreen::usage = "Phase1ThermalScreen is part of the Phase1PolarCollector package API.";
Phase1TimeDependentPower::usage = "Phase1TimeDependentPower is part of the Phase1PolarCollector package API.";
Phase1Validate::usage = "Phase1Validate is part of the Phase1PolarCollector package API.";
Phase1WobbleSimulation::usage = "Phase1WobbleSimulation is part of the Phase1PolarCollector package API.";
Begin["`Private`"];

(* Clear only implementation symbols on reload; exported usage messages remain. *)
ClearAll["Phase1PolarCollector`Private`*"];
$Phase1ModelVersion = "11.27";
$Phase1CalculationCoreSchemaVersion = "11.9";

(* ========================================================================
   POLAR COLLECTOR — PHASE 1 WOLFRAM LANGUAGE MODEL
   Revision: v11.27 — packaged, two-pole independent calculation model

   Governing objective:
     Maximize delivered electrical power subject to natural vector force
     equilibrium, thermal limits, dynamic limits, actuator limits and a
     quantified structural screening model.

   IMPORTANT MODEL STATUS:
     This is a Phase 1 engineering-screening model, not a qualified flight design.
     The only project-specific default is PoleCount = 2, representing the user-confirmed
     two-pole architecture. No other project-specific design choice or physical/material
     value, PV target, actuator value, mass allowance, disturbance, initial condition,
     mission duration or acceptance threshold is defaulted. The PV coverage interval is
     only the mathematical domain of a fraction; solver settings are Mathematica execution
     conventions, not collector design values. Widely accepted SI/CODATA/IAU constants and
     standardized PV reference-test conditions remain available solely as reference values,
     not as assumed collector design or operating conditions.
     Mathematica calculates all derived values, integrations, solves, optimizations and checks at runtime.

   Provenance references:
     MIT PV publication and DOI for independently sourced device data: https://doi.org/10.1002/smtd.202200940
     IAU 2015 Resolution B3 nominal solar conversion constants:
     https://www.iau.org/static/resolutions/IAU2015_English.pdf
   NIST CODATA 2022 physical constants:
     https://physics.nist.gov/cuu/pdf/wall_2022.pdf
   PV standard test conditions (1000 W/m^2, 25 C, AM1.5G):
     IEA-PVPS Solar Resource Handbook, 3rd edition, Section 3.3; IEC 60904 series.
     https://www.iea-pvps.org/wp-content/uploads/2021/06/IEA_PVPS_T16_Solar_Res_Handbook_2021-080621.pdf
   NASA SRP modelling reference:
     https://ntrs.nasa.gov/api/citations/20220014814/downloads/NASA%20TP%2020220014814%20final.pdf

   Load with:
     Get["Phase1_Polar_Collector_Model_v11_27.wl"];
     (* Inspect readiness; calculate only after all required values are entered. *)
     Phase1InputStatus[];
     Phase1InputRequirements[];
     Phase1MissingRequiredInputs[];
     Phase1MissingRequiredProvenance[];
     Phase1InteractivePanel[];
     Phase1PoleOperatingInputPanel["Pole1"];
     Phase1PoleOperatingInputPanel["Pole2"];
     Phase1PoleIndependenceAudit[];
     (* Enter distinct operating inputs for each pole. Optional notes do not affect readiness. *)
     Phase1ComputeAll[];
     Phase1Validate[];
     Phase1RunSelfTests[];
     Phase1JointOptimization[];
     Phase1RunFullAssessment[];
     Phase1RunReport[];

   This v11.27 source implements two operationally independent pole systems. Their design and material inputs are shared; their operating inputs, state, controls, disturbances, dynamics, caches and results are separate. PoleCount = 2 is the only project-specific default.
   ======================================================================== *)

(* ========================================================================
   1. CENTRAL INPUT REGISTER — sole source of model inputs
   All input values used by calculations are read from $Phase1State["Inputs"].
   UI changes and optimizer recommendations update this same register.
   ======================================================================== *)

$Phase1DefaultInputs = <|
  (* Widely accepted reference constants. Solar quantities are IAU 2015 nominal
     conversion constants; G, c, mp and sigma are CODATA/SI values. TSI is a
     nominal reference, not a time-invariant solar measurement. *)
  "SolarLuminosity_W" -> 3.828*10^26,
  "SolarGravitationalParameter_m3_s2" -> 1.3271244*10^20,
  "UniversalGravitationalConstant_m3_kg_s2" -> 6.67430*10^-11,
  "SolarIrradianceAt1AU_W_m2" -> 1361.,
  "SpeedOfLight_m_s" -> 299792458.,
  "AstronomicalUnit_m" -> 149597870700.,
  "Year_s" -> 365.25*86400., (* Julian year: exactly 365.25 days by convention. *)
  "StefanBoltzmann_W_m2_K4" -> 5.670374419*10^-8,
  "CentimetersPerMeter" -> 100.,
  "ProtonMass_kg" -> 1.67262192595*10^-27,

  (* Physical coefficients and numerical controls remain required inputs unless they are
     published reference constants, standardized reference conditions, pure mathematics,
     or explicit Mathematica execution conventions. No model coefficient is assumed. *)
  "CircularMembraneDeflectionCoefficient" -> Missing["UserInputRequired"],
  "MeshAreaRelativeTolerance" -> Missing["UserInputRequired"],
  "AccelerationCrossCheckRelativeTolerance" -> Missing["UserInputRequired"],
  "SolarReferenceConsistencyRelativeTolerance" -> Missing["UserInputRequired"],
  "ThermalResidualRelativeTolerance" -> Missing["UserInputRequired"],
  "QuaternionNormalizationTolerance" -> Missing["UserInputRequired"],
  "OpticalClosureTolerance" -> Missing["UserInputRequired"],
  "PowerLedgerRelativeTolerance" -> Missing["UserInputRequired"],
  "ICARUSLoadMapRelativeTolerance" -> Missing["UserInputRequired"],
  "MeshCoefficientCrossCheckTolerance" -> Missing["UserInputRequired"],
  "OptimizerGridCrossCheckRelativeTolerance" -> Missing["UserInputRequired"],
  "NumericalWorkingPrecision" -> MachinePrecision,
  "OptimizerMaxIterations" -> Missing["UserInputRequired"],
  "PVThermalCouplingMaxIterations" -> Missing["UserInputRequired"],
  "OptimizerGridPointCount" -> Missing["UserInputRequired"],
  "OptimizerCoverageGridPointCount" -> Missing["UserInputRequired"],
  "MeshRadialCount" -> Missing["UserInputRequired"],
  "MeshAzimuthCount" -> Missing["UserInputRequired"],
  "OptimizerMeshRadialCount" -> Missing["UserInputRequired"],
  "OptimizerMeshAzimuthCount" -> Missing["UserInputRequired"],
  "DynamicAccuracyGoal" -> Missing["UserInputRequired"],
  "DynamicPrecisionGoal" -> Missing["UserInputRequired"],
  "DynamicMaxSteps" -> Infinity,
  "DynamicSampleCount" -> Missing["UserInputRequired"],
  "DynamicLoadPropagationSampleCount" -> Missing["UserInputRequired"],
  (* The only project-specific default retained is the user-confirmed two-pole architecture. *)
  "PoleCount" -> 2,
  "ICARUSStationCount" -> Missing["UserInputRequired"],
  "ICARUSStationCountScope" -> Missing["UserInputRequired"],
  "ReflectorSolarReflectivity" -> Missing["UserInputRequired"],
  "ProjectTargetEfficiency" -> Missing["UserInputRequired"],
  "PVSpecificPowerReferenceIrradiance_W_m2" -> 1000., (* PV standard test irradiance, IEC 60904 series. *)
  "PVReferenceTemperature_K" -> 298.15, (* 25 deg C PV standard test temperature. *)
  "PVScenarioOptions" -> {"MITSpecificPowerLimited","MITIntegratedFabricSpecificPowerLimited","MITEfficiencyReference","ProjectSpecifiedTargetEfficiency"},
  "PVLayoutModel" -> Missing["UserInputRequired"],
  "GeometryProfileModel" -> Missing["UserInputRequired"],
  "MassDistributionModel" -> Missing["UserInputRequired"],
  "FlareTemporalProfile" -> Missing["UserInputRequired"],
  "CMETemporalProfile" -> Missing["UserInputRequired"],
  "ICARUSLoadTransferModel" -> Missing["UserInputRequired"],
  "MembraneStructuralModel" -> Missing["UserInputRequired"],
  "WobbleRestoringModel" -> Missing["UserInputRequired"],
  "PVSearchRange" -> {0.,1.},
  "ReflectionModel" -> Missing["UserInputRequired"],
  "DeferredEquipmentMass_kg" -> Missing["UserInputRequired"],
  "OtherInstalledArealMass_kg_m2" -> Missing["UserInputRequired"],
  "PerimeterHardwareLinearMass_kg_m" -> Missing["UserInputRequired"],
  "InitialPositionLocal_m" -> Missing["UserInputRequired"],
  "InitialVelocityLocal_m_s" -> Missing["UserInputRequired"],
  "InitialVelocityHeliocentric_m_s" -> Missing["UserInputRequired"],
  "HeliocentricReferenceMotionMode" -> Missing["UserInputRequired"],
  "InitialAttitudeSmallAngles_rad" -> Missing["UserInputRequired"],
  "IncidenceAngle_deg" -> Missing["UserInputRequired"],

  (* Every other project-specific design/material/operating value is intentionally
     Missing. Populate via Phase1SetInputs[values, sources] with SI units and an exact source
     or an explicit project-owner-approved assumption note. *)
  "Distance_m" -> Missing["UserInputRequired"],
  "PerPoleProjectedArea_m2" -> Missing["UserInputRequired"],
  "CapDepthToPlanformRadius" -> Missing["UserInputRequired"],
  "PVFraction" -> Missing["UserInputRequired"],
  "ReflectorSolarTransmissivity" -> Missing["UserInputRequired"],
  "PVSolarReflectivity" -> Missing["UserInputRequired"],
  "PVSolarTransmissivity" -> Missing["UserInputRequired"],
  "PVArealMass_kg_m2" -> Missing["UserInputRequired"],
  "PVIntegratedFabricArealMass_kg_m2" -> Missing["UserInputRequired"],
  "PVIntegratedMassIncludesStructuralFabric" -> Missing["UserInputRequired"],
  "PVFreeStandingSpecificPower_W_kg" -> Missing["UserInputRequired"],
  "PVIntegratedSpecificPower_W_kg" -> Missing["UserInputRequired"],
  "PrimaryPVScenario" -> Missing["UserInputRequired"],
  "ReflectorArealMass_kg_m2" -> Missing["UserInputRequired"],
  "MembraneSubstrateMaterialName" -> Missing["UserInputRequired"],
  "MembraneSubstrateArealMass_kg_m2" -> Missing["UserInputRequired"],
  "WiringArealMass_kg_m2" -> Missing["UserInputRequired"],
  "ICARUSStationMass_kg" -> Missing["UserInputRequired"],
  "ICARUSStationPositionsLocal_m" -> Missing["UserInputRequired"],
  "MITEfficiencyReference" -> Missing["UserInputRequired"],
  "PVIntegratedEfficiencyReference" -> Missing["UserInputRequired"],
  "PVEfficiencyTemperatureCoefficient_perK" -> Missing["UserInputRequired"],
  "TransferEfficiency" -> Missing["UserInputRequired"],
  "ConditioningEfficiency" -> Missing["UserInputRequired"],
  "ReflectorIRemissivity" -> Missing["UserInputRequired"],
  "PVIRemissivity" -> Missing["UserInputRequired"],
  "BothSidesRadiate" -> Missing["UserInputRequired"],
  "PVTemperatureLimit_K" -> Missing["UserInputRequired"],
  "ReflectorTemperatureLimit_K" -> Missing["UserInputRequired"],
  "ICARUSStationForceCapacity_N" -> Missing["UserInputRequired"],
  "ControllerTranslationKp_perS2" -> Missing["UserInputRequired"],
  "ControllerTranslationKd_perS" -> Missing["UserInputRequired"],
  "ControllerAttitudeKp_perS2" -> Missing["UserInputRequired"],
  "ControllerAttitudeKd_perS" -> Missing["UserInputRequired"],
  "MembraneLoadSpreadFractionOfRadius" -> Missing["UserInputRequired"],
  "InitialAngularVelocity_rad_s" -> Missing["UserInputRequired"],
  "WobbleNaturalPeriod_s" -> Missing["UserInputRequired"],
  "WobbleDampingRatio" -> Missing["UserInputRequired"],
  "MembraneMaterialDensity_kg_m3" -> Missing["UserInputRequired"],
  "MembraneEffectiveYoungsModulus_Pa" -> Missing["UserInputRequired"],
  "MembraneEffectiveUltimateStrength_Pa" -> Missing["UserInputRequired"],
  "MembranePretension_N_m" -> Missing["UserInputRequired"],
  "StructuralSafetyFactor" -> Missing["UserInputRequired"],
  "MaximumDeflectionFractionOfRadius" -> Missing["UserInputRequired"],
  "FlarePeakFraction" -> Missing["UserInputRequired"],
  "FlarePeakTime_s" -> Missing["UserInputRequired"],
  "FlareDuration_s" -> Missing["UserInputRequired"],
  "FlareTailCutoffFraction" -> Missing["UserInputRequired"],
  "CMEOnset_s" -> Missing["UserInputRequired"],
  "CMEWindPressureMultiplier" -> Missing["UserInputRequired"],
  "CMEDuration_s" -> Missing["UserInputRequired"],
  "SolarWindProtonDensity_1AU_cm3" -> Missing["UserInputRequired"],
  "SolarWindSpeed_1AU_m_s" -> Missing["UserInputRequired"],
  "SEPDose_protons_cm2" -> Missing["UserInputRequired"],
  "SEPDoseReference_protons_cm2" -> Missing["UserInputRequired"],
  "PVDegradationPerSEPReferenceDoseFraction" -> Missing["UserInputRequired"],
  "PVAnnualDegradationFraction" -> Missing["UserInputRequired"],
  "ReflectivityAnnualLossFraction" -> Missing["UserInputRequired"],
  "ReferenceMissionYears" -> Missing["UserInputRequired"],
  "DistanceSearchRange_m" -> Missing["UserInputRequired"],
  "ExactEquilibriumAccelerationTolerance_m_s2" -> Missing["UserInputRequired"],
  "ExactEquilibriumTorqueTolerance_Nm" -> Missing["UserInputRequired"],
  "ExactEquilibriumRelativeTolerance" -> Missing["UserInputRequired"],
  "RadialDeviationToleranceFractionOfRadius" -> Missing["UserInputRequired"],
  "LateralDeviationToleranceFractionOfRadius" -> Missing["UserInputRequired"],
  "AttitudeTolerance_rad" -> Missing["UserInputRequired"],
  "RecoveryTimeMaximum_s" -> Missing["UserInputRequired"],
  "VelocityRecoveryTolerance_m_s" -> Missing["UserInputRequired"],
  "AngularRateRecoveryTolerance_rad_s" -> Missing["UserInputRequired"],
  "DynamicCheckDuration_s" -> Missing["UserInputRequired"]
|>;

$Phase1ReferenceNotes = <|
  "IAU2015SolarConstants" -> "IAU 2015 Resolution B3 nominal solar conversion constants: solar luminosity 3.828×10^26 W; solar gravitational parameter 1.3271244×10^20 m^3/s^2; solar radius 6.957×10^8 m; total solar irradiance 1361 W/m^2. Nominal constants are conversion/reference values, not claims about instantaneous solar conditions. https://www.iau.org/static/resolutions/IAU2015_English.pdf",
  "SIAndCODATAConstants" -> "NIST CODATA 2022 values: c is exact in SI; G = 6.67430×10^-11 m^3 kg^-1 s^-2; proton mass = 1.67262192595×10^-27 kg; Stefan-Boltzmann constant = 5.670374419×10^-8 W m^-2 K^-4. https://physics.nist.gov/cuu/Constants/",
  "AstronomicalUnit" -> "The astronomical unit is exactly 149,597,870,700 m. IAU definition. https://www.iau.org/static/resolutions/IAU2012_English.pdf",
  "JulianYear" -> "One Julian year is exactly 365.25 days of 86,400 SI seconds each. This is a defined duration conversion, not a claim about the length of an actual calendar or orbital year.",
  "PVReferenceCondition" -> "IEC PV Standard Test Conditions (STC): AM1.5 global spectrum, 1000 W/m^2 total irradiance and 25 °C cell-junction temperature. The corresponding register values normalize published device ratings only; they are not predicted in-situ irradiance or operating temperature. IEC 60904-1/60904-3 and IEA-PVPS Best Practices Handbook, Third Edition (2021).",
  "ModelFormChoices" -> "Geometry profile, PV layout, mass distribution, ICARUS load-transfer model, structural model and wobble model are shared design/material model choices. Flare/CME event definitions and temporal-profile choices, all ICARUS controller gains, and heliocentric reference-motion mode are pole-specific operating settings. The source currently implements only the named reduced-order model options and blocks the applicable pole calculation until each is selected and attributed.",
  "UserConfirmedProjectInputs" -> "The only executable project-specific default is PoleCount = 2, the user-confirmed two-pole architecture. No station count, station scope, reflectivity, PV-efficiency target, PV layout, deferred equipment mass, material property, actuator capacity, geometry, pole-specific disturbance, mission setting or acceptance threshold is defaulted. Each pole has distinct orbit, initial-condition, environment, event-profile and controller inputs; legacy shared values are not treated as ongoing coupling.",
  "PVPublishedBenchmarks" -> "No MIT PV device mass, specific-power or efficiency numbers are populated in the executable input register. Free-standing and fabric-integrated efficiency references are separate required inputs. Enter the chosen device measurements from the paper/datasheet and record the exact device variant, test conditions, table/page and URL/DOI. A DOI is not itself an input value: https://doi.org/10.1002/smtd.202200940",
  "MembraneSubstrateAndReflectorMaterials" -> "No membrane substrate identity, areal mass, coating mass, density, modulus, strength, emissivity or optical transmission is defaulted. Supply the actual material designation and the properties for the selected grade, with supporting source/measurement.",
  "ICARUSCapacity" -> "No ICARUS station force rating, mass, or station coordinates are defaulted. Enter measured/qualified per-station force capacity and mass, plus the local coordinates for every configured station. Do not substitute IKAROS sail data or an assistant estimate.",
  "Geometry" -> "No canopy area, profile, curvature or perimeter surrogate is defaulted. Enter the CAD/profile-derived projected area and cap depth ratio, or replace phase1Geometry with an imported surface mesh.",
  "DisturbancesAndDegradation" -> "No flare/CME/solar-wind/SEP event severity, timing, mission degradation or recovery assumptions are defaulted. Enter measured scenario records or explicitly identified design envelopes.",
  "NumericalControls" -> "Mesh counts, solver goals, comparison tolerances, and structural model coefficients have no universal value. They are required user inputs, not defaults. Refine mesh counts until the reported independent mesh-convergence checks meet project-approved tolerances.",
  "DeferredMass" -> "Deferred equipment mass is a required project input. The current Phase 1 inertia model only supports zero deferred equipment mass because no positions/component model are provided. Nonzero deferred mass is rejected until a spatial mass model is added.",
  "MissingInputPolicy" -> "Any key whose default is Missing[UserInputRequired] blocks Phase1ComputeAll. The user must provide a value. Missing material/design values are not silently replaced with assistant estimates."
|>;


$Phase1UserConfirmedInputNotes = <|
  "PoleCount" -> "User-confirmed two-pole architecture; this is the only retained project-specific default."
|>;

$Phase1ReferenceAndSoftwareDefaultKeys = {
  "SolarLuminosity_W","SolarGravitationalParameter_m3_s2",
  "UniversalGravitationalConstant_m3_kg_s2","SolarIrradianceAt1AU_W_m2",
  "SpeedOfLight_m_s","AstronomicalUnit_m","Year_s",
  "StefanBoltzmann_W_m2_K4","CentimetersPerMeter","ProtonMass_kg",
  "PVSpecificPowerReferenceIrradiance_W_m2","PVReferenceTemperature_K",
  "PVScenarioOptions","PVSearchRange",
  "NumericalWorkingPrecision","DynamicMaxSteps"
};

(* Published physical/reference constants, standardized PV test conditions, supported
   scenario labels, the mathematical coverage domain, and safe Mathematica execution controls
   are reference/software definitions only. Optional source notes are descriptive metadata and
   never determine whether a value is accepted by the calculation engine. *)
phase1ProjectInputKeys[] := Select[Keys[$Phase1DefaultInputs],
  !(MemberQ[$Phase1ReferenceAndSoftwareDefaultKeys,#] &&
    SameQ[Lookup[$Phase1State["Inputs"],#,Missing[]],Lookup[$Phase1DefaultInputs,#,Missing[]]])&];
phase1ProvenanceRequiredKeys[] := {};

$Phase1State = <|
  "SchemaVersion" -> "11.9",
  "Inputs" -> $Phase1DefaultInputs,
  "OptionalSourceNotes" -> $Phase1ReferenceNotes,
  "InputNotes" -> $Phase1UserConfirmedInputNotes,
  "Derived" -> <||>,
  "Results" -> <||>,
  "AuditLog" -> {},
  "LastRun" -> Missing["NotRun"]
|>;

phase1StoreResult[name_String,value_] := Module[{updated},
  updated=Join[$Phase1State["Results"],<|name->value|>];
  $Phase1State=Join[$Phase1State,<|"Results"->updated|>];
  phase1Audit["CalculationResultStored",<|"ResultName"->name|>];
  value
];

Phase1GetInputs[] := $Phase1State["Inputs"];
Phase1GetInput[name_String] := Lookup[$Phase1State["Inputs"],name,Missing["UnknownInput",name]];
Phase1MissingRequiredInputs[] := Select[Keys[$Phase1State["Inputs"]], MissingQ[$Phase1State["Inputs"][#]] &];
Phase1MissingRequiredProvenance[] := {};
Phase1InputStatus[] := Module[{missing=Phase1MissingRequiredInputs[],missingSources=Phase1MissingRequiredProvenance[]},
  <|"Ready"->(missing==={}),
    "MissingRequiredInputKeys"->missing,
    "OptionalSourceNotesMissing"->missingSources,
    "InputCount"->Length[Keys[$Phase1State["Inputs"]]],
    "MissingRequiredInputCount"->Length[missing],
    "SourceNotesPolicy"->"Optional descriptive notes do not gate input acceptance or calculations."|>
];

$Phase1InputCategories = <|
  "NumericalAndConvergenceControls" -> {"MeshAreaRelativeTolerance","AccelerationCrossCheckRelativeTolerance","SolarReferenceConsistencyRelativeTolerance","ThermalResidualRelativeTolerance","QuaternionNormalizationTolerance","OpticalClosureTolerance","PowerLedgerRelativeTolerance","ICARUSLoadMapRelativeTolerance","MeshCoefficientCrossCheckTolerance","OptimizerGridCrossCheckRelativeTolerance","OptimizerMaxIterations","PVThermalCouplingMaxIterations","OptimizerGridPointCount","OptimizerCoverageGridPointCount","MeshRadialCount","MeshAzimuthCount","OptimizerMeshRadialCount","OptimizerMeshAzimuthCount","DynamicAccuracyGoal","DynamicPrecisionGoal","DynamicSampleCount","DynamicLoadPropagationSampleCount"},
  "ArchitectureAndModelChoices" -> {"PoleCount","ICARUSStationCount","ICARUSStationCountScope","PVLayoutModel","GeometryProfileModel","MassDistributionModel","ICARUSLoadTransferModel","MembraneStructuralModel","WobbleRestoringModel","ReflectionModel"},
  "GeometryAndReferenceState" -> {"PerPoleProjectedArea_m2","CapDepthToPlanformRadius"},
  "OpticalPVAndElectrical" -> {"ReflectorSolarReflectivity","ProjectTargetEfficiency","PVFraction","ReflectorSolarTransmissivity","PVSolarReflectivity","PVSolarTransmissivity","PVArealMass_kg_m2","PVIntegratedFabricArealMass_kg_m2","PVIntegratedMassIncludesStructuralFabric","PVFreeStandingSpecificPower_W_kg","PVIntegratedSpecificPower_W_kg","PrimaryPVScenario","MITEfficiencyReference","PVIntegratedEfficiencyReference","PVEfficiencyTemperatureCoefficient_perK","TransferEfficiency","ConditioningEfficiency"},
  "MassMaterialsAndStructure" -> {"CircularMembraneDeflectionCoefficient","DeferredEquipmentMass_kg","OtherInstalledArealMass_kg_m2","PerimeterHardwareLinearMass_kg_m","ReflectorArealMass_kg_m2","MembraneSubstrateMaterialName","MembraneSubstrateArealMass_kg_m2","WiringArealMass_kg_m2","ICARUSStationMass_kg","MembraneMaterialDensity_kg_m3","MembraneEffectiveYoungsModulus_Pa","MembraneEffectiveUltimateStrength_Pa","MembranePretension_N_m","StructuralSafetyFactor","MaximumDeflectionFractionOfRadius"},
  "ICARUSControlAndLoadTransfer" -> {"ICARUSStationPositionsLocal_m","ICARUSStationForceCapacity_N","MembraneLoadSpreadFractionOfRadius"},
  "Thermal" -> {"ReflectorIRemissivity","PVIRemissivity","BothSidesRadiate","PVTemperatureLimit_K","ReflectorTemperatureLimit_K"},
  "RotationAndWobble" -> {"WobbleNaturalPeriod_s","WobbleDampingRatio"},
  "RadiationMaterialDegradationProperties" -> {"SEPDoseReference_protons_cm2","PVDegradationPerSEPReferenceDoseFraction","PVAnnualDegradationFraction","ReflectivityAnnualLossFraction"},
  "AcceptanceAndRecoveryCriteria" -> {"ExactEquilibriumAccelerationTolerance_m_s2","ExactEquilibriumTorqueTolerance_Nm","ExactEquilibriumRelativeTolerance","RadialDeviationToleranceFractionOfRadius","LateralDeviationToleranceFractionOfRadius","AttitudeTolerance_rad","RecoveryTimeMaximum_s","VelocityRecoveryTolerance_m_s","AngularRateRecoveryTolerance_rad_s"}
|>;
$Phase1PoleOperatingInputCategories = <|
  "PoleSpecificOrbitAndInitialState" -> {"Distance_m","DistanceSearchRange_m","InitialPositionLocal_m","InitialVelocityLocal_m_s","InitialVelocityHeliocentric_m_s","HeliocentricReferenceMotionMode","InitialAttitudeSmallAngles_rad","InitialAngularVelocity_rad_s","IncidenceAngle_deg","DynamicCheckDuration_s"},
  "PoleSpecificEnvironmentAndMission" -> {"FlarePeakFraction","FlarePeakTime_s","FlareDuration_s","FlareTailCutoffFraction","FlareTemporalProfile","CMEOnset_s","CMEWindPressureMultiplier","CMEDuration_s","CMETemporalProfile","SolarWindProtonDensity_1AU_cm3","SolarWindSpeed_1AU_m_s","SEPDose_protons_cm2","ReferenceMissionYears"},
  "PoleSpecificControlSettings" -> {"ControllerTranslationKp_perS2","ControllerTranslationKd_perS","ControllerAttitudeKp_perS2","ControllerAttitudeKd_perS"}
|>;

Phase1InputRequirements[] := Module[{inputs=Phase1GetInputs[],groups,missing,status,allCategorized},
  groups=Association@KeyValueMap[Function[{name,keys},
    missing=Select[keys,MissingQ[Lookup[inputs,#,Missing[]]]&];
    name-><|"RequiredKeys"->keys,"MissingValues"->missing,"MissingValueCount"->Length[missing]|>
  ],$Phase1InputCategories];
  status=Phase1InputStatus[];
  allCategorized=DeleteDuplicates[Flatten[Values[$Phase1InputCategories]]];
  <|"Ready"->TrueQ[status["Ready"]] && Complement[status["MissingRequiredInputKeys"],allCategorized]==={},
    "RequiredProjectAndNumericalInputCount"->Total[Length/@Values[$Phase1InputCategories]],
    "MissingValueCount"->Length[status["MissingRequiredInputKeys"]],
    "Groups"->groups,
    "UnclassifiedRequiredInputs"->Complement[status["MissingRequiredInputKeys"],allCategorized],
    "SourceNotesAreOptional"->True|>
];
(* Public output accessors always validate the central input snapshot first.
   Raw Phase1GetResults[] is retained for internal state-management code. *)
Phase1GetDerived[name_String] := Module[{computed=phase1EnsureCalculated[]},
  If[FailureQ[computed],computed,Lookup[$Phase1State["Derived"],name,Missing["DerivedValueNotAvailable",name]]]
];
Phase1GetState[] := $Phase1State;
phase1RawResults[] := $Phase1State["Results"];
Phase1GetResults[] := phase1EnsureCalculated[];
Phase1GetResult[name_String] := Module[{computed=phase1EnsureCalculated[]},
  If[FailureQ[computed],computed,Lookup[$Phase1State["Results"],name,Missing["ResultNotAvailable",name]]]
];


phase1DefaultInputAudit[] := Module[{projectKeys,referenceConstants,standardPVReferences,softwareDefinitions,requiredSharedProjectKeys},
  projectKeys=Join[Keys@Select[$Phase1DefaultInputs,MissingQ],$Phase1PoleOperatingKeys];
  requiredSharedProjectKeys=Complement[Keys@Select[$Phase1DefaultInputs,MissingQ],$Phase1PoleOperatingKeys];
  referenceConstants={"SolarLuminosity_W","SolarGravitationalParameter_m3_s2","UniversalGravitationalConstant_m3_kg_s2",
    "SolarIrradianceAt1AU_W_m2","SpeedOfLight_m_s","AstronomicalUnit_m","Year_s",
    "StefanBoltzmann_W_m2_K4","CentimetersPerMeter","ProtonMass_kg"};
  standardPVReferences={"PVSpecificPowerReferenceIrradiance_W_m2","PVReferenceTemperature_K"};
  softwareDefinitions={"PVScenarioOptions","PVSearchRange",
    "NumericalWorkingPrecision","DynamicMaxSteps"};
  <|"OnlyProjectSpecificDefault"-><|"PoleCount"->2|>,
    "OtherProjectSpecificDefaultsPresent"->{},
    "PublishedReferenceConstantDefaults"->referenceConstants,
    "SolarIrradianceReferenceClassification"->"IAU nominal solar irradiance conversion constant at 1 au; not an instantaneous operating value.",
    "StandardizedPVReferenceConditionDefaults"->standardPVReferences,
    "MathematicalOrSoftwareDefinitionsNotProjectDefaults"->softwareDefinitions,
    "RequiredArchitectureInputs"->{"ICARUSStationCount","ICARUSStationCountScope"},
    "RequiredSharedDesignMaterialModelFormChoices"->{"GeometryProfileModel","MassDistributionModel","PVLayoutModel","ICARUSLoadTransferModel","MembraneStructuralModel","WobbleRestoringModel","ReflectionModel"},
    "RequiredPoleSpecificEnvironmentModelFormChoices"->{"FlareTemporalProfile","CMETemporalProfile"},
    "RequiredPoleSpecificControllerSettings"->{"ControllerTranslationKp_perS2","ControllerTranslationKd_perS","ControllerAttitudeKp_perS2","ControllerAttitudeKd_perS"},
    "AllOtherProjectAndNumericalInputsRequiredFromUser"->projectKeys,
    "RequiredPoleOperatingInputsPerPole"->$Phase1PoleOperatingKeys,
    "RequiredPoleOperatingInputCountPerPole"->Length[$Phase1PoleOperatingKeys],
    "SharedInputRegisterKeyCount"->Length[Keys[$Phase1DefaultInputs]],
    "RequiredSharedProjectInputCount"->Length[requiredSharedProjectKeys],
    "InputRequirementGroups"->Keys[$Phase1InputCategories],
    "AllProjectSpecificInputsRequireProvenance"->False,
    "ProvenanceIsNotAReadinessCondition"->True,
    "AllProjectSpecificInputsRequireExplicitValues"->True,
    "SourceNotesOptionalAndNonBlocking"->True,
    "AssistantGeneratedEngineeringDefaultsPresent"->False,
    "InitialPositionVelocityAndAttitudeAreRequiredInputs"->True,
    "NoPublishedDeviceMassOrSpecificPowerIsHardcoded"->True,
    "NoMaterialOrActuatorCapacityIsHardcoded"->True,
    "NoCanopyAreaPerimeterOrProfileIsHardcoded"->True|>
];

phase1Audit[action_String,details_] := Module[{entry},
  entry = <|"Action"->action,"Time"->DateString[{"Year","-","Month","-","Day"," ","Hour",":","Minute",":","Second"}],"Details"->details|>;
  $Phase1State = Join[$Phase1State,<|"AuditLog"->Append[$Phase1State["AuditLog"],entry]|>];
  entry
];

Phase1SetInputs[updates_Association] := Phase1SetInputs[updates,<||>];
Phase1SetInputs[updates_Association,notes_Association] := Module[
  {current,unknown,unknownNotes,badNotes,oldNotes,staleNotes,newNotes},
  current=$Phase1State["Inputs"];
  unknown=Complement[Keys[updates],Keys[current]];
  unknownNotes=Complement[Keys[notes],Keys[current]];
  badNotes=Select[Keys[notes],!StringQ[notes[#]] || StringTrim[notes[#]]==="" &];
  If[unknown =!= {},Return[Failure["UnknownInputKeys",<|"Keys"->unknown|>]]];
  If[unknownNotes =!= {},Return[Failure["UnknownInputNoteKeys",<|"Keys"->unknownNotes|>]]];
  If[badNotes =!= {},Return[Failure["InvalidOptionalSourceNotes",<|"Keys"->badNotes|>]]];
  oldNotes=Lookup[$Phase1State,"InputNotes",<||>];
  staleNotes=Select[Keys[updates],!SameQ[Lookup[updates,#],Lookup[current,#]] && !KeyExistsQ[notes,#]&];
  newNotes=Join[KeyDrop[oldNotes,staleNotes],notes];
  current=Join[current,updates];
  $Phase1State=Join[$Phase1State,<|"Inputs"->current,
    "InputNotes"->newNotes,"Derived"-><||>,"Results"-><||>,"LastRun"->Missing["InputsChanged"]|>];
  phase1Audit["InputsUpdated",<|"ChangedKeys"->Keys[updates],"OptionalSourceNotesUpdated"->Keys[notes],
    "OptionalSourceNotesRemovedForChangedValues"->staleNotes|>];
  current
];
Phase1SetInputProvenance[notes_Association] := Phase1SetInputs[<||>,notes];


(* The legacy single-system reset/save definitions are intentionally omitted.
   The final two-pole implementations are defined after the pole-local execution
   architecture, so reset and persistence always preserve independent pole state. *)

(* ========================================================================
   2. PURE MODEL FUNCTIONS — all receive the central input snapshot explicitly
   ======================================================================== *)

phase1InstalledPVArealMass[in_Association] := If[
  in["PrimaryPVScenario"] === "MITIntegratedFabricSpecificPowerLimited",
  in["PVIntegratedFabricArealMass_kg_m2"],
  in["PVArealMass_kg_m2"]
];

phase1Geometry[in_Association] := Module[
  {poleProjectedArea,a,h,sphereRadius,curvedArea,perimeter},
  poleProjectedArea=in["PerPoleProjectedArea_m2"];
  a=Sqrt[poleProjectedArea/Pi];
  h=in["CapDepthToPlanformRadius"] a;
  sphereRadius=(a^2+h^2)/(2. h);
  curvedArea=2. Pi sphereRadius h;
  perimeter=2. Pi a;
  If[in["GeometryProfileModel"] =!= "SphericalCapSurrogate",
    Return[Failure["UnsupportedGeometryProfileModel",<|"SelectedModel"->in["GeometryProfileModel"]|>]]];
  <|
    "TwoPoleCollectorArea_m2"->Missing["AggregateFromIndependentPoleGeometryResults"],
    "GrossProjectedAreaPerPole_m2"->poleProjectedArea,
    "GrossCurvedAreaPerPole_m2"->curvedArea,
    "PlanformEquivalentRadius_m"->a,
    "PlanformPerimeter_m"->perimeter,
    "CapDepth_m"->h,
    "GeneratingSphereRadius_m"->sphereRadius,
    "CurvedToProjectedAreaRatio"->curvedArea/poleProjectedArea,
    "GeometryModel"->in["GeometryProfileModel"],
    "GeometryModelQualification"->"Explicitly selected spherical-cap surrogate. The model form is not inferred from data; replace phase1Geometry/phase1Mesh with CAD/profile-derived mesh when a surveyed design surface is available.",
    "CalculationScope"->"All calculations are performed for the active pole alone, in that pole's independent local coordinate frame. The local +x axis is the Sun-radial coordinate convention; no global inter-pole orientation or coupling is assumed."
  |>
];

phase1Mesh[in_Association,geo_Association,nr_:Automatic,na_:Automatic] := Module[
  {nR,nA,a,sr,area,patches,rho,phi,x,norm,dAproj,dAsurf},
  nR=If[nr===Automatic,in["MeshRadialCount"],nr];
  nA=If[na===Automatic,in["MeshAzimuthCount"],na];
  a=geo["PlanformEquivalentRadius_m"];sr=geo["GeneratingSphereRadius_m"];area=geo["GrossProjectedAreaPerPole_m2"];
  patches=Flatten[Table[
    rho=a Sqrt[(i-0.5)/nR];
    phi=2. Pi (j-1)/nA;
    x=Sqrt[sr^2-rho^2]-(sr-geo["CapDepth_m"]);
    norm=Normalize[{1.,rho Cos[phi]/Sqrt[sr^2-rho^2],rho Sin[phi]/Sqrt[sr^2-rho^2]}];
    dAproj=area/(nR nA);
    dAsurf=dAproj/norm[[1]];
    <|"Position_m"->{x,rho Cos[phi],rho Sin[phi]},"Normal"->norm,
      "ProjectedAreaWeight_m2"->dAproj,"SurfaceAreaWeight_m2"->dAsurf,
      "RadialIndex"->i,"AzimuthIndex"->j|>,
    {i,nR},{j,nA}],1];
  <|"Patches"->patches,"PatchCount"->Length[patches],
    "ProjectedArea_m2"->Total[Lookup[patches,"ProjectedAreaWeight_m2"]],
    "QuadratureCurvedArea_m2"->Total[Lookup[patches,"SurfaceAreaWeight_m2"]],
    "AnalyticCurvedArea_m2"->geo["GrossCurvedAreaPerPole_m2"],
    "QuadratureAreaRelativeError"->(Total[Lookup[patches,"SurfaceAreaWeight_m2"]]/geo["GrossCurvedAreaPerPole_m2"]-1.),
    "MeshResolution"->{nR,nA},
    "SurfaceFrame"->"Local x is the Sun-radial/canopy-normal axis; y-z span the canopy planform."|>
];

phase1Optics[in_Association] := Module[{rR,tR,aR,rP,tP,aP},
  rR=in["ReflectorSolarReflectivity"];tR=in["ReflectorSolarTransmissivity"];aR=1.-rR-tR;
  rP=in["PVSolarReflectivity"];tP=in["PVSolarTransmissivity"];aP=1.-rP-tP;
  <|"Reflector"-><|"R"->rR,"A"->aR,"T"->tR|>,
    "PV"-><|"R"->rP,"A"->aP,"T"->tP|>,
    "EnergyClosure"-><|"Reflector"->rR+aR+tR,"PV"->rP+aP+tP|>,
    "Status"->"Absorptivity is calculated as 1-R-T; each incident-energy fraction is assigned exactly once."|>
];

phase1SunVector[angleDeg_] := Normalize[{Cos[angleDeg Degree],Sin[angleDeg Degree],0.}];

phase1Illumination[mesh_Association,sun_List] := Module[{patches=mesh["Patches"],cosines},
  cosines=Map[Max[0.,# ["Normal"].sun]&,patches];
  <|"SunDirection"->sun,"PatchIncidenceCosines"->cosines,
    "IlluminationWeightedProjectedArea_m2"->Total[MapThread[#1 #2&,{cosines,Lookup[patches,"SurfaceAreaWeight_m2"]}]],
    "IlluminationModel"->"One-sided illumination using local surface normals; backside illumination is not assumed."|>
];

phase1MaterialMomentumCoefficients[mesh_Association,sun_List,optics_Association] := Module[
  {patches=mesh["Patches"],absVector,reflVector,forceCoefficient},
  absVector=Total[Map[Function[p,Module[{ci=Max[0.,p["Normal"].sun]},ci p["SurfaceAreaWeight_m2"] sun]],patches]]/mesh["ProjectedArea_m2"];
  reflVector=Total[Map[Function[p,Module[{ci=Max[0.,p["Normal"].sun]},2. ci^2 p["SurfaceAreaWeight_m2"] p["Normal"]]],patches]]/mesh["ProjectedArea_m2"];
  forceCoefficient[material_] := optics[material]["A"] absVector+optics[material]["R"] reflVector;
  <|"AbsorptionVectorCoefficient"->absVector,"SpecularReflectionVectorCoefficient"->reflVector,
    "PVVectorCoefficient"->forceCoefficient["PV"],
    "ReflectorVectorCoefficient"->forceCoefficient["Reflector"]|>
];

(* Solar irradiance is evaluated from the active pole's actual distance. This
   deliberately contains no fixed AU-distance operating assumption or 34,000 W/m^2 value. *)
phase1SolarIrradiance[in_Association, distance_?NumericQ] :=
  If[TrueQ[distance > 0.],
    in["SolarLuminosity_W"]/(4. Pi distance^2),
    Failure["InvalidSolarDistance", <|"Distance_m" -> distance|>]
  ];

phase1Radiation[in_Association,geo_Association,mesh_Association,optics_Association,f_,r_,angleDeg_,sunOverride_:Automatic] := Module[
  {sun,flux,patches,forces,ci,dA,aEff,rEff,force,heat,pvIncident,pvAbsorbed,refIncident,totalForce,totalMoment,coefficients,coefficientVector,pvReflected,pvTransmitted,refReflected,refTransmitted,totalIncident,totalAbsorbed,totalReflected,totalTransmitted,energyResidual},
  sun=If[sunOverride===Automatic,phase1SunVector[angleDeg],Normalize[sunOverride]];
  flux=phase1SolarIrradiance[in,r]; If[FailureQ[flux],Return[flux]];
  patches=mesh["Patches"];
  aEff=f optics["PV"]["A"]+(1.-f) optics["Reflector"]["A"];
  rEff=f optics["PV"]["R"]+(1.-f) optics["Reflector"]["R"];
  forces=Map[Function[p,
    ci=Max[0.,p["Normal"].sun];dA=p["SurfaceAreaWeight_m2"];
    force=(flux/in["SpeedOfLight_m_s"]) ci dA (aEff sun+2. rEff ci p["Normal"]);
    heat=flux ci dA aEff;
    Join[p,<|"IncidenceCosine"->ci,"RadiationForceVector_N"->force,"AbsorbedHeat_W"->heat|>]
  ],patches];
  pvIncident=flux f Total[MapThread[#1 #2&,{Map[Max[0.,# .sun]&,Lookup[patches,"Normal"]],Lookup[patches,"SurfaceAreaWeight_m2"]}]];
  pvAbsorbed=pvIncident optics["PV"]["A"];
  refIncident=flux (1.-f) Total[MapThread[#1 #2&,{Map[Max[0.,# .sun]&,Lookup[patches,"Normal"]],Lookup[patches,"SurfaceAreaWeight_m2"]}]];
  pvReflected=pvIncident optics["PV"]["R"];pvTransmitted=pvIncident optics["PV"]["T"];
  refReflected=refIncident optics["Reflector"]["R"];refTransmitted=refIncident optics["Reflector"]["T"];
  totalIncident=pvIncident+refIncident;
  totalAbsorbed=pvAbsorbed+refIncident optics["Reflector"]["A"];
  totalReflected=pvReflected+refReflected;totalTransmitted=pvTransmitted+refTransmitted;
  energyResidual=totalIncident-totalAbsorbed-totalReflected-totalTransmitted;
  totalForce=Total[Lookup[forces,"RadiationForceVector_N"]];
  totalMoment=Total[MapThread[Cross[#1,#2]&,{Lookup[forces,"Position_m"],Lookup[forces,"RadiationForceVector_N"]}]];
  coefficients=phase1MaterialMomentumCoefficients[mesh,sun,optics];
  coefficientVector=f coefficients["PVVectorCoefficient"]+(1.-f) coefficients["ReflectorVectorCoefficient"];
  <|"Distance_m"->r,"Irradiance_W_m2"->flux,"SunDirection"->sun,
    "PVIncidentPower_W"->pvIncident,"PVAbsorbedPower_W"->pvAbsorbed,
    "PVReflectedPower_W"->pvReflected,"PVTransmittedPower_W"->pvTransmitted,
    "ReflectorIncidentPower_W"->refIncident,"ReflectorAbsorbedPower_W"->refIncident optics["Reflector"]["A"],
    "ReflectorReflectedPower_W"->refReflected,"ReflectorTransmittedPower_W"->refTransmitted,
    "TotalIncidentOpticalPower_W"->totalIncident,"TotalAbsorbedOpticalPower_W"->totalAbsorbed,
    "TotalReflectedOpticalPower_W"->totalReflected,"TotalTransmittedOpticalPower_W"->totalTransmitted,
    "OpticalEnergyClosureResidual_W"->energyResidual, 
    "TotalAbsorbedHeat_W"->Total[Lookup[forces,"AbsorbedHeat_W"]],
    "NetRadiationForceVector_N"->totalForce,"NetRadiationMoment_Nm"->totalMoment,
    "RadiationPressureVector_Pa"->totalForce/geo["GrossProjectedAreaPerPole_m2"],
    "NumericalMomentumCoefficientVector"->coefficientVector,
    "NumericalMomentumCoefficientRadial"->coefficientVector[[1]],
    "MaterialMomentumCoefficients"->coefficients,
    "PatchLoads"->forces,"PVFraction"->f,"ReflectiveFraction"->1.-f,
    "AssumedReflectionType"->in["ReflectionModel"],
    "Qualification"->"Patch integration uses local normals and area weights. Reflection is assumed specular; diffuse/backscatter terms are deferred."|>
];

phase1Mass[in_Association,geo_Association,rad_Association,f_,r_] := Module[
  {ratio,curvedArea,projectedArea,pvMass,reflectMass,substrateMass,referenceSubstrateMass,wireMass,otherMass,deferredMass,perimeterMass,stationMass,sheetMass,totalMass,sigma,flux,mu,c,gravity,radAcceleration,accVector,sigmaEq,margin,relativeResidual,integratedPVReplacesSubstrate,wind,radialDirection},
  ratio=geo["CurvedToProjectedAreaRatio"];
  curvedArea=geo["GrossCurvedAreaPerPole_m2"];projectedArea=geo["GrossProjectedAreaPerPole_m2"];
  pvMass=f curvedArea phase1InstalledPVArealMass[in];
  reflectMass=(1.-f) curvedArea in["ReflectorArealMass_kg_m2"];
  integratedPVReplacesSubstrate=TrueQ[in["PVIntegratedMassIncludesStructuralFabric"] && in["PrimaryPVScenario"]==="MITIntegratedFabricSpecificPowerLimited"];
  substrateMass=curvedArea If[integratedPVReplacesSubstrate,1.-f,1.] in["MembraneSubstrateArealMass_kg_m2"];
  referenceSubstrateMass=curvedArea (1.-f) in["MembraneSubstrateArealMass_kg_m2"];
  wireMass=curvedArea in["WiringArealMass_kg_m2"];
  otherMass=curvedArea in["OtherInstalledArealMass_kg_m2"];
  deferredMass=in["DeferredEquipmentMass_kg"];
  perimeterMass=geo["PlanformPerimeter_m"] in["PerimeterHardwareLinearMass_kg_m"];
  stationMass=in["ICARUSStationCount"] in["ICARUSStationMass_kg"];
  sheetMass=pvMass+reflectMass+substrateMass+wireMass+otherMass;
  totalMass=sheetMass+perimeterMass+stationMass+deferredMass;
  sigma=totalMass/projectedArea;
  flux=phase1SolarIrradiance[in,r]; If[FailureQ[flux],Return[flux]];
  mu=in["SolarGravitationalParameter_m3_s2"];c=in["SpeedOfLight_m_s"];
  radialDirection={1.,0.,0.};
  gravity=mu/r^2;
  radAcceleration=rad["NetRadiationForceVector_N"]/totalMass;
  wind=phase1SolarWindLoads[in,rad["PatchLoads"],r,radialDirection];
  accVector=radAcceleration+wind["TotalForce_N"]/totalMass-gravity radialDirection;
  sigmaEq=rad["NumericalMomentumCoefficientRadial"] in["SolarLuminosity_W"]/(4. Pi c mu)+Dot[wind["TotalForce_N"],radialDirection] r^2/(projectedArea mu);
  margin=sigmaEq-sigma;
  relativeResidual=(sigma-sigmaEq)/sigmaEq;
  <|"Distance_m"->r,"PVMass_kg"->pvMass,"ReflectorCoatingMass_kg"->reflectMass,
    "MembraneSubstrateMaterialName"->in["MembraneSubstrateMaterialName"],
    "MembraneSubstrateMass_kg"->substrateMass,"PerimeterHardwareMass_kg"->perimeterMass,
    "PerimeterHardwareLinearMass_kg_m"->in["PerimeterHardwareLinearMass_kg_m"],
    "PerimeterMassModel"->"User-selected linear mass distributed uniformly around the computed planform perimeter; perimeter point masses are included in centre-of-mass, inertia and distributed-gravity calculations.",
    "PVIntegratedFabricReplacesSubstrate"->integratedPVReplacesSubstrate,
    "ReferenceSubstrateMassOnReflectorArea_kg"->referenceSubstrateMass,
    "WiringMass_kg"->wireMass,"OtherInstalledArealMass_kg"->otherMass,"DeferredEquipmentMass_kg"->deferredMass,
    "SheetMass_kg"->sheetMass,"StationMassTotal_kg"->stationMass,
    "MassLedgerComponentSum_kg"->pvMass+reflectMass+substrateMass+wireMass+otherMass+perimeterMass+stationMass+deferredMass,
    "MassLedgerResidual_kg"->totalMass-(pvMass+reflectMass+substrateMass+wireMass+otherMass+perimeterMass+stationMass+deferredMass),
    "MassLedgerCloses"->TrueQ[Abs[totalMass-(pvMass+reflectMass+substrateMass+wireMass+otherMass+perimeterMass+stationMass+deferredMass)]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[totalMass]]],
    "TotalMass_kg"->totalMass,"TotalTwoPoleMass_kg"->Missing["AggregateFromIndependentPoleMassResults"],
    "InstalledPVArealMass_kg_m2"->phase1InstalledPVArealMass[in],
    "MembraneSubstrateArealMass_kg_m2"->in["MembraneSubstrateArealMass_kg_m2"],
    "ReflectorCoatingArealMass_kg_m2"->in["ReflectorArealMass_kg_m2"],
    "StationMassCountedOnce"->TrueQ[Abs[stationMass-in["ICARUSStationCount"] in["ICARUSStationMass_kg"]]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[stationMass]]],
    "TotalArealMass_kg_m2"->sigma,"EquilibriumArealMass_kg_m2"->sigmaEq,
    "SolarWindForce_N"->wind["TotalForce_N"],"SolarWindTorqueAboutCOM_Nm"->wind["TotalTorqueAboutCOM_Nm"],
    "MassMargin_kg_m2"->margin,
    "MassFeasible"->TrueQ[margin>=-in["ExactEquilibriumRelativeTolerance"] sigmaEq],
    "RelativeEquilibriumResidual"->relativeResidual,
    "NetNaturalAccelerationVector_m_s2"->accVector,
    "NetRadialAcceleration_m_s2"->accVector[[1]],
    "NaturalForceResidualMagnitude_m_s2"->Norm[accVector],
    "ExactVectorEquilibrium"->TrueQ[Norm[accVector]<=in["ExactEquilibriumAccelerationTolerance_m_s2"]],
    "ExactMassBalanceWithinTolerance"->TrueQ[Abs[relativeResidual]<=in["ExactEquilibriumRelativeTolerance"]],
    "RadiationAccelerationVector_m_s2"->radAcceleration,
    "SolarGravityAcceleration_m_s2"->gravity,
    "Interpretation"->Which[Norm[accVector]<=in["ExactEquilibriumAccelerationTolerance_m_s2"],"Natural vector equilibrium within numerical tolerance",accVector[[1]]>0.,"Outward/radiation-dominant residual; NOT equilibrium",True,"Inward/gravity-dominant or transverse residual; NOT equilibrium"]|>
];

phase1Thermal[in_Association,geo_Association,rad_Association,r_,limit_,coverage_:Automatic,electricalOutputW_:0.] := Module[
  {sides,pvEps,refEps,f,pvArea,reflectorArea,pvQ,reflectorQ,pvTemp,reflectorTemp,
   pvResidual,reflectorResidual,reflectorLimit,netPVHeatW},
  f=If[coverage===Automatic,in["PVFraction"],coverage];
  sides=If[TrueQ[in["BothSidesRadiate"]],2.,1.];
  pvEps=in["PVIRemissivity"];refEps=in["ReflectorIRemissivity"];
  pvArea=f geo["GrossCurvedAreaPerPole_m2"];
  reflectorArea=(1.-f) geo["GrossCurvedAreaPerPole_m2"];
  netPVHeatW=Max[0.,rad["PVAbsorbedPower_W"]-Max[0.,electricalOutputW]];
  pvQ=If[pvArea>0.,netPVHeatW/pvArea,0.];
  reflectorQ=If[reflectorArea>0.,rad["ReflectorAbsorbedPower_W"]/reflectorArea,0.];
  pvTemp=If[pvQ>0.,(pvQ/(sides pvEps in["StefanBoltzmann_W_m2_K4"]))^(1/4),0.];
  reflectorTemp=If[reflectorQ>0.,(reflectorQ/(sides refEps in["StefanBoltzmann_W_m2_K4"]))^(1/4),0.];
  pvResidual=sides pvEps in["StefanBoltzmann_W_m2_K4"] pvTemp^4-pvQ;
  reflectorResidual=sides refEps in["StefanBoltzmann_W_m2_K4"] reflectorTemp^4-reflectorQ;
  reflectorLimit=in["ReflectorTemperatureLimit_K"];
  <|"Distance_m"->r,"PVActiveArea_m2"->pvArea,"ReflectorActiveArea_m2"->reflectorArea,
    "PVMeanAbsorbedHeatFlux_W_m2"->pvQ,"PVAbsorbedOpticalPower_W"->rad["PVAbsorbedPower_W"],
    "PVElectricalPowerExtracted_W"->Max[0.,electricalOutputW],"PVResidualHeatPower_W"->netPVHeatW,
    "ReflectorMeanAbsorbedHeatFlux_W_m2"->reflectorQ,
    "PVTemperature_K"->pvTemp,"ReflectorTemperature_K"->reflectorTemp,
    "TemperatureLimit_K"->limit,"ReflectorTemperatureLimit_K"->reflectorLimit,
    "PVTemperatureWithinLimit"->TrueQ[pvTemp<=limit || pvQ==0.],
    "ReflectorTemperatureWithinLimit"->TrueQ[reflectorTemp<=reflectorLimit || reflectorQ==0.],
    "AllThermalLimitsWithinBounds"->TrueQ[(pvTemp<=limit || pvQ==0.) && (reflectorTemp<=reflectorLimit || reflectorQ==0.)],
    "ThermalBalanceResidual_W_m2"->pvResidual,
    "PVThermalBalanceResidual_W_m2"->pvResidual,"ReflectorThermalBalanceResidual_W_m2"->reflectorResidual,
    "RadiatingSides"->sides,"PVIRemissivity"->pvEps,"ReflectorIRemissivity"->refEps,
    "CoverageUsed"->f,
    "Model"->"Separate mean steady radiative balances per active PV and reflector area. PV electrical DC output is extracted from absorbed PV optical power before the residual PV heat balance; reflector absorbed optical power remains heat. No conduction, thermal inertia, hot-spot resolution, coating interface resistance or view-factor network."|>
];

phase1PV[in_Association,geo_Association,rad_Association,thermal_Association,f_,years_] := Module[
  {pvArea,pvMass,freeStandingMass,integratedMass,installedArealMass,incident,meanIrradiance,specificPowerIrradianceFactor,
   degAnnual,degSEP,degPV,effTemp,mitEff,projectEff,projectEffTemp,spCap,integratedCap,outputs,selected,sel,capApplicable,capPass,integratedEff},
  If[in["PVLayoutModel"] =!= "UniformSurfaceCoverage",
    Return[Failure["UnsupportedPVLayoutModel",<|"SelectedModel"->in["PVLayoutModel"]|>]]];
  pvArea=f geo["GrossCurvedAreaPerPole_m2"];
  installedArealMass=phase1InstalledPVArealMass[in];
  pvMass=pvArea installedArealMass;
  freeStandingMass=pvArea in["PVArealMass_kg_m2"];
  incident=rad["PVIncidentPower_W"];
  meanIrradiance=If[pvArea>0.,incident/pvArea,0.];
  specificPowerIrradianceFactor=If[pvArea>0.,meanIrradiance/in["PVSpecificPowerReferenceIrradiance_W_m2"],0.];
  degAnnual=(1.-in["PVAnnualDegradationFraction"])^years;
  degSEP=Clip[1.-in["PVDegradationPerSEPReferenceDoseFraction"] in["SEPDose_protons_cm2"]/in["SEPDoseReference_protons_cm2"],{0.,1.}];
  degPV=degAnnual degSEP;
  effTemp=Clip[in["MITEfficiencyReference"] (1.+in["PVEfficiencyTemperatureCoefficient_perK"] (thermal["PVTemperature_K"]-in["PVReferenceTemperature_K"])),{0.,1.}];
  mitEff=incident effTemp degPV;
  integratedEff=Clip[in["PVIntegratedEfficiencyReference"] (1.+in["PVEfficiencyTemperatureCoefficient_perK"] (thermal["PVTemperature_K"]-in["PVReferenceTemperature_K"])),{0.,1.}];
  projectEffTemp=Clip[in["ProjectTargetEfficiency"]*(1.+in["PVEfficiencyTemperatureCoefficient_perK"]*
    (thermal["PVTemperature_K"]-in["PVReferenceTemperature_K"])),{0.,1.}];
  projectEff=incident projectEffTemp degPV;
  spCap=freeStandingMass in["PVFreeStandingSpecificPower_W_kg"] specificPowerIrradianceFactor degPV;
  integratedMass=pvArea in["PVIntegratedFabricArealMass_kg_m2"];
  integratedCap=integratedMass in["PVIntegratedSpecificPower_W_kg"] specificPowerIrradianceFactor degPV;
  outputs=<|"MITSpecificPowerLimited"->Min[spCap,mitEff],
    "MITIntegratedFabricSpecificPowerLimited"->Min[integratedCap,incident integratedEff degPV],
    "MITEfficiencyReference"->mitEff,"ProjectSpecifiedTargetEfficiency"->projectEff|>;
  selected=in["PrimaryPVScenario"];
  sel=Lookup[outputs,selected,Missing["UnknownPVScenario",selected]];
  capApplicable=MemberQ[{"MITSpecificPowerLimited","MITIntegratedFabricSpecificPowerLimited"},selected];
  capPass=If[selected==="MITIntegratedFabricSpecificPowerLimited",
    TrueQ[NumericQ[sel] && sel<=integratedCap+Sqrt[$MachineEpsilon]],
    If[selected==="MITSpecificPowerLimited",TrueQ[NumericQ[sel] && sel<=spCap+Sqrt[$MachineEpsilon]],True]
  ];
  <|"PVInstalledCurvedArea_m2"->pvArea,"PVDeviceMass_kg"->pvMass,
    "MITFreeStandingDeviceMass_kg"->freeStandingMass,
    "InstalledPVArealMass_kg_m2"->installedArealMass,
    "IncidentPVPower_W"->incident,"MeanIncidentPVIrradiance_W_m2"->meanIrradiance,
    "SpecificPowerReferenceIrradiance_W_m2"->in["PVSpecificPowerReferenceIrradiance_W_m2"],
    "SpecificPowerIrradianceScalingFactor"->specificPowerIrradianceFactor,
    "EffectiveMITReferenceEfficiency"->effTemp,"EffectiveIntegratedPVReferenceEfficiency"->integratedEff,
    "EffectiveProjectTargetEfficiency"->projectEffTemp,
    "AnnualPVDegradationFactor"->degAnnual,"SEPDegradationFactor"->degSEP,
    "TotalPVDegradationFactor"->degPV,
    "MITSpecificPowerCeiling_W"->spCap,"MITIntegratedSpecificPowerCeiling_W"->integratedCap,
    "MITIntegratedFabricDeviceMass_kg"->integratedMass,"ScenarioDCOutputs_W"->outputs,
    "SelectedScenario"->selected,"SelectedDCOutput_W"->sel,
    "SpecificPowerCapApplicable"->capApplicable,
    "PVOutputDoesNotExceedAbsorbedPower"->TrueQ[NumericQ[sel] && sel<=rad["PVAbsorbedPower_W"]+Sqrt[$MachineEpsilon] Max[Sqrt[$MinMachineNumber],Abs[rad["PVAbsorbedPower_W"]]]],
    "PVOutputDoesNotExceedSpecificPower"->capPass,
    "MassPowerReconciliation"->"Each selected technology uses its own central-register device areal mass, specific power and efficiency reference. Mathematica independently evaluates the specific-power and efficiency ceilings, applies irradiance and degradation, and selects the lower bound for the chosen scenario."|>
];

phase1CoupledPVThermal[in_Association, geo_Association, mesh_Association, optics_Association,
    rad_Association, coverage_?NumericQ, distance_?NumericQ, missionYears_?NumericQ] := Module[
  {maxIterations, tolerance, initialThermal, initialState, step, states, finalState,
   thermal, pv, before, after},
  maxIterations = in["PVThermalCouplingMaxIterations"];
  tolerance = in["ThermalResidualRelativeTolerance"];
  initialThermal = phase1Thermal[in, geo, rad, distance,
    in["PVTemperatureLimit_K"], coverage, 0.];
  If[FailureQ[initialThermal], Return[initialThermal]];
  initialState = <|"Thermal" -> initialThermal, "Iteration" -> 0, "Converged" -> False|>;
  step[state_Association] := Module[{pvNow, thermalNow, priorTemperature, newTemperature, electricalOutput},
    If[TrueQ[state["Converged"]], Return[state]];
    priorTemperature = state["Thermal"]["PVTemperature_K"];
    pvNow = phase1PV[in, geo, rad, state["Thermal"], coverage, missionYears];
    If[FailureQ[pvNow], Return[pvNow]];
    electricalOutput = pvNow["SelectedDCOutput_W"];
    If[!NumericQ[electricalOutput],
      Return[Failure["PVOutputNotNumeric", <|"PVResult" -> pvNow|>]]
    ];
    thermalNow = phase1Thermal[in, geo, rad, distance,
      in["PVTemperatureLimit_K"], coverage, electricalOutput];
    If[FailureQ[thermalNow], Return[thermalNow]];
    newTemperature = thermalNow["PVTemperature_K"];
    <|"Thermal" -> thermalNow, "Iteration" -> state["Iteration"] + 1,
      "Converged" -> TrueQ[Abs[newTemperature - priorTemperature] <=
        tolerance Max[Sqrt[$MinMachineNumber], Abs[newTemperature], Abs[priorTemperature]]]|>
  ];
  states = NestWhileList[step, initialState,
    Function[state, AssociationQ[state] && !TrueQ[Lookup[state, "Converged", False]] &&
      IntegerQ[Lookup[state, "Iteration", -1]] && state["Iteration"] < maxIterations]];
  finalState = Last[states];
  If[FailureQ[finalState], Return[finalState]];
  If[!AssociationQ[finalState],
    Return[Failure["PVThermalIterationStateInvalid", <|"State" -> finalState|>]]
  ];
  thermal = finalState["Thermal"];
  pv = phase1PV[in, geo, rad, thermal, coverage, missionYears];
  If[FailureQ[pv], Return[pv]];
  before = If[Length[states] > 1,
    states[[-2]]["Thermal"]["PVTemperature_K"], thermal["PVTemperature_K"]];
  after = thermal["PVTemperature_K"];
  thermal = Join[thermal, <|"PVThermalCouplingConverged" -> TrueQ[finalState["Converged"]],
    "PVThermalCouplingIterations" -> finalState["Iteration"],
    "PVThermalCouplingRelativeTemperatureChange" ->
      Abs[after - before]/Max[Sqrt[$MinMachineNumber], Abs[after]],
    "PVThermalCouplingMethod" ->
      "Bounded fixed-point iteration; subsequent iterations stop immediately after the PV-temperature residual meets the configured tolerance."|>];
  If[!TrueQ[finalState["Converged"]],
    Return[Failure["PVThermalCouplingDidNotConverge",
      <|"Iterations" -> finalState["Iteration"], "Thermal" -> thermal, "PV" -> pv|>]]
  ];
  <|"Thermal" -> thermal, "PVPerformance" -> pv, "Converged" -> True,
    "Iterations" -> finalState["Iteration"]|>
];

phase1Power[in_Association,pv_Association] := Module[{dc,transferred,conditioned},
  dc=pv["SelectedDCOutput_W"];
  transferred=dc in["TransferEfficiency"];
  conditioned=transferred in["ConditioningEfficiency"];
  <|"PoleCount"->in["PoleCount"],
    "PVDirectCurrent_W_PerPole"->dc,"TransferredDC_W_PerPole"->transferred,
    "ConditionedDeliveredPower_W_PerPole"->conditioned,
    "TotalTwoPoleDeliveredPower_W"->Missing["AggregateFromIndependentPolePowerResults"],
    "PVDirectCurrent_W"->dc,"TransferredDC_W"->transferred,
    "ConditionedDeliveredPower_W"->conditioned,
    "TransferEfficiency"->in["TransferEfficiency"],
    "ConditioningEfficiency"->in["ConditioningEfficiency"],
    "ScenarioDCOutputs_W"->pv["ScenarioDCOutputs_W"]|>
];

phase1Structural[in_Association,geo_Association,rad_Association,coverage_:Automatic] := Module[
  {a,pressure,tension,arealMass,density,thickness,stress,strain,allowableStress,deflection,ratio,requiredTension,allowableTension,pass,patchPressures,f,wind,windForces},
  If[in["MembraneStructuralModel"] =!= "TensionedCircularMembrane",
    Return[Failure["UnsupportedMembraneStructuralModel",<|"SelectedModel"->in["MembraneStructuralModel"]|>]]];
  f=If[coverage===Automatic,in["PVFraction"],coverage];
  a=geo["PlanformEquivalentRadius_m"];
  wind=phase1SolarWindLoads[in,rad["PatchLoads"],in["Distance_m"],{1.,0.,0.}];
  windForces=wind["PatchForces_N"];
  patchPressures=MapThread[Function[{p,fw},
    Abs[(p["RadiationForceVector_N"]+fw).p["Normal"]]/p["SurfaceAreaWeight_m2"]],
    {rad["PatchLoads"],windForces}];
  pressure=Max[patchPressures];
  tension=in["MembranePretension_N_m"];
  arealMass=in["MembraneSubstrateArealMass_kg_m2"];
  density=in["MembraneMaterialDensity_kg_m3"];
  thickness=arealMass/density;
  stress=If[thickness>0.,tension/thickness,Infinity];
  strain=stress/in["MembraneEffectiveYoungsModulus_Pa"];
  allowableStress=in["MembraneEffectiveUltimateStrength_Pa"]/in["StructuralSafetyFactor"];
  deflection=If[tension>0.,pressure a^2/(in["CircularMembraneDeflectionCoefficient"] tension),Infinity];
  ratio=deflection/a;
  requiredTension=pressure a/(in["CircularMembraneDeflectionCoefficient"] in["MaximumDeflectionFractionOfRadius"]);
  allowableTension=allowableStress thickness;
  pass=TrueQ[ratio<=in["MaximumDeflectionFractionOfRadius"] && stress<=allowableStress && requiredTension<=allowableTension &&
    !(in["PrimaryPVScenario"]==="MITIntegratedFabricSpecificPowerLimited" &&
      TrueQ[in["PVIntegratedMassIncludesStructuralFabric"]] && f>0.)];
  <|"AppliedPeakLocalNormalRadiationAndSolarWindPressure_Pa"->pressure,
    "SolarWindIncludedInStaticStructuralLoad"->True,
    "BaselineSolarWindPressure_Pa"->wind["DynamicPressure_Pa"],
    "PatchPressureRange_Pa"->{Min[patchPressures],Max[patchPressures]},
    "StructuralSubstrateArealMass_kg_m2"->arealMass,
    "PlanformSpan_m"->a,"AssumedMembranePretension_N_m"->tension,
    "EquivalentMembraneThickness_m"->thickness,
    "EstimatedMembraneTensileStress_Pa"->stress,"EstimatedMembraneElasticStrain"->strain,
    "AllowableMembraneStress_Pa"->allowableStress,
    "EstimatedMaximumDeflection_m"->deflection,
    "DeflectionFractionOfRadius"->ratio,
    "MaximumAllowedDeflectionFraction"->in["MaximumDeflectionFractionOfRadius"],
    "RequiredPretensionForDeflectionLimit_N_m"->requiredTension,
    "AllowablePretensionFromStrength_N_m"->allowableTension,
    "DeflectionMargin"->in["MaximumDeflectionFractionOfRadius"]-ratio,
    "TensileStressMargin_Pa"->allowableStress-stress,
    "PretensionCapacityMargin_N_m"->allowableTension-requiredTension,
    "StructuralScreenPass"->pass,
    "IntegratedPVStructuralQualification"->If[in["PrimaryPVScenario"]==="MITIntegratedFabricSpecificPowerLimited" && TrueQ[in["PVIntegratedMassIncludesStructuralFabric"]] && f>0.,
      "Not qualified: the integrated PV fabric replaces the base membrane substrate under covered area, but a mixed-laminate constitutive model is not supplied.",
      "First-order uniform tensioned-membrane screen only; not nonlinear membrane FEA."],
    "StructuralScreenModel"->in["MembraneStructuralModel"],
    "StructuralScreenQualification"->"Tensioned circular membrane one-span formula w_max≈p a^2/(C T), driven by patch-resolved normal radiation plus baseline solar-wind traction. Material density, modulus, strength, areal mass and pretension must be supplied from project data. Uniform effective tension and equivalent thickness remain first-order approximations, not nonlinear membrane FEA."|>
];

phase1StructuralDistanceFloor[in_Association,geo_Association,mesh_Association,optics_Association,pvFraction_?NumericQ] := Module[
  {sun,patches,maxCos,maxWindCos,mixA,mixR,pressureCoefficient,windPressureCoefficient,a,thickness,allowableStress,allowableTension,
   pressureLimit,pretensionStress,minimumDistance,rad0,mass0,dyn0,meshAtt},
  sun=phase1SunVector[in["IncidenceAngle_deg"]];
  rad0=phase1Radiation[in,geo,mesh,optics,pvFraction,in["Distance_m"],in["IncidenceAngle_deg"],sun];
  mass0=phase1Mass[in,geo,rad0,pvFraction,in["Distance_m"]];
  dyn0=phase1DynamicsInitial[in,geo,mass0,mesh];
  meshAtt=phase1RotateMeshToCOM[mesh,dyn0["CenterOfMassLocal_m"],dyn0["InitialQuaternion"]];
  patches=meshAtt["Patches"];
  maxCos=Max[Map[Max[0.,# ["Normal"].sun]&,patches]];
  maxWindCos=Max[Map[Max[0.,# ["Normal"].{1.,0.,0.}]&,patches]];
  mixA=pvFraction optics["PV"]["A"]+(1.-pvFraction) optics["Reflector"]["A"];
  mixR=pvFraction optics["PV"]["R"]+(1.-pvFraction) optics["Reflector"]["R"];
  pressureCoefficient=in["SolarLuminosity_W"] maxCos^2 (mixA+2. mixR)/(4. Pi in["SpeedOfLight_m_s"]);
  windPressureCoefficient=in["SolarWindProtonDensity_1AU_cm3"] in["CentimetersPerMeter"]^3 in["ProtonMass_kg"] in["SolarWindSpeed_1AU_m_s"]^2 in["AstronomicalUnit_m"]^2 maxWindCos;
  pressureCoefficient=pressureCoefficient+windPressureCoefficient;
  a=geo["PlanformEquivalentRadius_m"];
  thickness=in["MembraneSubstrateArealMass_kg_m2"]/in["MembraneMaterialDensity_kg_m3"];
  allowableStress=in["MembraneEffectiveUltimateStrength_Pa"]/in["StructuralSafetyFactor"];
  allowableTension=allowableStress thickness;
  pretensionStress=in["MembranePretension_N_m"]/thickness;
  pressureLimit=Min[
    in["CircularMembraneDeflectionCoefficient"] in["MembranePretension_N_m"] in["MaximumDeflectionFractionOfRadius"]/a,
    in["CircularMembraneDeflectionCoefficient"] in["MaximumDeflectionFractionOfRadius"] allowableTension/a
  ];
  minimumDistance=If[pretensionStress>allowableStress || pressureLimit<=0. || pressureCoefficient<0. ||
      (in["PrimaryPVScenario"]==="MITIntegratedFabricSpecificPowerLimited" &&
       TrueQ[in["PVIntegratedMassIncludesStructuralFabric"]] && pvFraction>0.),Infinity,
    Sqrt[pressureCoefficient/pressureLimit]];
  <|"MinimumStructuralDistance_m"->minimumDistance,
    "PeakNormalCosine"->maxCos,"PeakSolarWindNormalCosine"->maxWindCos,
    "CombinedRadiationAndSolarWindPressureCoefficient_Pa_m2"->pressureCoefficient,
    "MaximumPermittedNormalPressure_Pa"->pressureLimit,
    "PretensionStress_Pa"->pretensionStress,"AllowablePretensionStress_Pa"->allowableStress,
    "AllowableTension_N_m"->allowableTension,
    "Feasible"->TrueQ[NumericQ[minimumDistance] && minimumDistance<Infinity],
    "Derivation"->"The structural distance floor is solved from the same membrane deflection and tensile-strength inequalities used by the independent structural screen. Pressure varies as 1/r^2, giving r_min=Sqrt[pressureCoefficient/pressureLimit]."|>
];

phase1DynamicsInitial[in_Association,geo_Association,mass_Association,mesh_Association] := Module[
  {a,stationMass,sheetMass,perimeterMass,nPerimeter,perimeterPositions,perimeterPointMasses,total,stationsAbsolute,patches,patchWeights,patchMasses,positions,masses,com,
   centered,inertia,theta,angle,q,omega,vHelio,rHelio,mu,helioSpeed,radialDirection},
  a=geo["PlanformEquivalentRadius_m"];
  If[in["MassDistributionModel"] =!= "UniformSheetMassWithPerimeterLineMassAndStationPointMasses",
    Return[Failure["UnsupportedMassDistributionModel",<|"SelectedModel"->in["MassDistributionModel"]|>]]];
  stationMass=in["ICARUSStationMass_kg"];
  sheetMass=mass["SheetMass_kg"];
  perimeterMass=mass["PerimeterHardwareMass_kg"];
  total=mass["TotalMass_kg"];
  stationsAbsolute=in["ICARUSStationPositionsLocal_m"];
  patches=mesh["Patches"];
  patchWeights=Lookup[patches,"SurfaceAreaWeight_m2"];
  patchMasses=sheetMass patchWeights/Total[patchWeights];
  nPerimeter=Max[Length[DeleteDuplicates[Lookup[patches,"AzimuthIndex"]]],1];
  perimeterPositions=Table[{0.,a Cos[2. Pi (j-1)/nPerimeter],a Sin[2. Pi (j-1)/nPerimeter]},{j,nPerimeter}];
  perimeterPointMasses=ConstantArray[perimeterMass/nPerimeter,nPerimeter];
  positions=Join[Lookup[patches,"Position_m"],perimeterPositions,stationsAbsolute];
  masses=Join[patchMasses,perimeterPointMasses,ConstantArray[stationMass,Length[stationsAbsolute]]];
  com=Total[MapThread[#1 #2&,{masses,positions}]]/Total[masses];
  centered=(#-com& /@ positions);
  inertia=Total[MapThread[Function[{m,rr},m*(Norm[rr]^2*IdentityMatrix[3]-Outer[Times,rr,rr])],{masses,centered}]];
  theta=in["InitialAttitudeSmallAngles_rad"];
  angle=Norm[theta];
  q=phase1Quaternion[theta,Sqrt[$MachineEpsilon]];
  omega=in["InitialAngularVelocity_rad_s"];
  vHelio=in["InitialVelocityHeliocentric_m_s"];
  radialDirection={1.,0.,0.};
  rHelio=in["Distance_m"] radialDirection;
  mu=in["SolarGravitationalParameter_m3_s2"];
  helioSpeed=Norm[vHelio];
  <|"TotalMass_kg"->total,"DistributedSheetMass_kg"->sheetMass,
    "PerimeterHardwareMass_kg"->perimeterMass,"PerimeterMassPointCount"->nPerimeter,
    "PerimeterMassPointPositionsLocal_m"->perimeterPositions,"PerimeterMassPointMasses_kg"->perimeterPointMasses,
    "StationMassTotal_kg"->Length[stationsAbsolute] stationMass,
    "CenterOfMassLocal_m"->com,
    "InertiaTensor_kg_m2"->inertia,
    "InitialPositionHeliocentric_m"->rHelio,
    "InitialVelocityHeliocentric_m_s"->vHelio,
    "HeliocentricSpeed_m_s"->helioSpeed,
    "HeliocentricSpecificAngularMomentum_m2_s"->Cross[rHelio,vHelio],
    "HeliocentricSpecificKineticEnergy_J_kg"->helioSpeed^2/2.,
    "HeliocentricCircularSpeedIfGravityOnly_m_s"->Sqrt[mu/in["Distance_m"]],
    "HeliocentricEscapeSpeedIfGravityOnly_m_s"->Sqrt[2. mu/in["Distance_m"]],
    "HeliocentricSpecificMechanicalEnergy_J_kg"->helioSpeed^2/2.-mu/in["Distance_m"],
    "LocalFrameInitialVelocityIsIndependentInput"->True,
    "HeliocentricReferenceMotionMode"->in["HeliocentricReferenceMotionMode"],
    "HeliocentricReferenceDynamics"->"The selected pole-specific reference motion mode is StaticHover. Its heliocentric reference velocity must be zero. The model calculates kinetic energy, specific angular momentum, gravity-only circular speed, escape speed and specific mechanical energy as diagnostics. Local perturbation dynamics use the separate local-frame initial position and velocity. Keplerian/orbital propagation and rotating-frame coupling are not implemented in this Phase 1 model.",
    "InitialPositionLocal_m"->in["InitialPositionLocal_m"],
    "InitialVelocityLocal_m_s"->in["InitialVelocityLocal_m_s"],
    "InitialAttitudeSmallAngles_rad"->theta,"InitialQuaternion"->q,
    "InitialAngularVelocity_rad_s"->omega,
    "StationPositionsAbsoluteLocal_m"->stationsAbsolute,
    "MassPointPositionsLocal_m"->centered,"MassPointMasses_kg"->masses,
    "StationPositionsLocal_m"->(#-com& /@ stationsAbsolute),
    "WrenchMatrix"->phase1WrenchMatrix[(#-com& /@ stationsAbsolute)],
    "MassDistributionModel"->in["MassDistributionModel"],
    "InertiaApproximation"->"User-selected uniform sheet mass is distributed over surface patches, perimeter hardware is discretized as equal point masses around the calculated planform perimeter, and stations are point masses at their registered coordinates. Centre of mass and inertia are recalculated from all registered mass points; each component mass is counted once. This is a lumped approximation, not a complete component-level mass distribution.",
    "MassConservationResidual_kg"->(Total[masses]-total),
    "HeliocentricAndLocalFramesSeparated"->True|>
];

phase1WrenchMatrix[stations_List] := Module[{blocks,skew},
  skew[p_] := {{0.,-p[[3]],p[[2]]},{p[[3]],0.,-p[[1]]},{-p[[2]],p[[1]],0.}};
  blocks=Table[Join[IdentityMatrix[3],skew[stations[[i]]]],{i,Length[stations]}];
  ArrayFlatten[{blocks}]
];

phase1Controller[dyn_Association,wrench_,capacity_] := Module[
  {w,raw,blocks,clipped,saturated,achieved},
  w=Lookup[dyn,"WrenchMatrix",phase1WrenchMatrix[dyn["StationPositionsLocal_m"]]];
  raw=PseudoInverse[w].wrench;
  blocks=Partition[raw,3];
  clipped=If[NumericQ[capacity],Map[If[Norm[#]>capacity,capacity Normalize[#],#]&,blocks],blocks];
  saturated=MapThread[Norm[#1-#2]>0.&,{blocks,clipped}];
  achieved=w.Flatten[clipped];
  <|"DesiredWrench"->wrench,"UnconstrainedStationForces_N"->blocks,
    "StationForces_N"->clipped,"AchievedWrench"->achieved,
    "SaturationByStation"->saturated,"CapacityPerStation_N"->capacity,
    "CapacityQualified"->NumericQ[capacity],"WrenchMatrix"->w|>
];

phase1LoadMap[in_Association,geo_Association,mesh_Association,dyn_Association,stationForces_List] := Module[
  {a,width,stations,patches,rawWeights,normalizedWeights,stationMaps,loads,totalForce,distributedForce,
   targetMoment,distributedMoment,forceResidual,momentResidual,forceReferenceScale,momentReferenceScale,
   perStationForceResiduals,perStationMomentResiduals,positions,centerOfMass},
  If[in["ICARUSLoadTransferModel"] =!= "GaussianMomentCorrected",
    Return[Failure["UnsupportedICARUSLoadTransferModel",<|"SelectedModel"->in["ICARUSLoadTransferModel"]|>]]];
  a=geo["PlanformEquivalentRadius_m"];
  width=in["MembraneLoadSpreadFractionOfRadius"] a;
  stations=dyn["StationPositionsLocal_m"];
  patches=mesh["Patches"];
  centerOfMass=dyn["CenterOfMassLocal_m"];
  positions=(#-centerOfMass& /@ Lookup[patches,"Position_m"]);
  rawWeights=Table[Module[{logWeights},
    logWeights=Table[-Norm[positions[[j,2;;3]]-stations[[i,2;;3]]]^2/(2. width^2)+
      Log[patches[[j]]["SurfaceAreaWeight_m2"]],{j,Length[patches]}];
    Exp[Clip[logWeights-Max[logWeights],{Log[$MinMachineNumber],0.}]]
  ],{i,Length[stations]}];
  normalizedWeights=Map[#/Total[#]&,rawWeights];
  stationMaps=Table[Module[
    {f=stationForces[[i]],w=normalizedWeights[[i]],rbar,baseForces,baseMoment,wantedMoment,
     deltaMoment,covariance,lambda,correction,correctedForces,actualForce,actualMoment},
    rbar=Total[MapThread[#1 #2&,{w,positions}]];
    baseForces=Map[# f&,w];
    baseMoment=Total[MapThread[Cross[#1,#2]&,{positions,baseForces}]];
    wantedMoment=Cross[stations[[i]],f];
    deltaMoment=wantedMoment-baseMoment;
    covariance=Total[MapThread[#1 (Norm[#2-rbar]^2 IdentityMatrix[3]-Outer[Times,#2-rbar,#2-rbar])&,{w,positions}]];
    lambda=PseudoInverse[covariance].deltaMoment;
    correction=MapThread[#1 Cross[lambda,#2-rbar]&,{w,positions}];
    correctedForces=baseForces+correction;
    actualForce=Total[correctedForces];
    actualMoment=Total[MapThread[Cross[#1,#2]&,{positions,correctedForces}]];
    <|"PatchForces_N"->correctedForces,"TargetForce_N"->f,"TargetMoment_Nm"->wantedMoment,
      "DistributedForce_N"->actualForce,"DistributedMoment_Nm"->actualMoment,
      "ForceResidual_N"->Norm[actualForce-f],"MomentResidual_Nm"->Norm[actualMoment-wantedMoment]|>
  ],{i,Length[stations]}];
  loads=Table[Module[{localForce=Total[Lookup[stationMaps,"PatchForces_N"][[All,j]]]},
    Join[patches[[j]],<|"PositionCOM_m"->positions[[j]],
      "StationLoadWeights"->normalizedWeights[[All,j]],
      "EstimatedLocalLoadVector_N"->localForce|>]
  ],{j,Length[patches]}];
  totalForce=Total[stationForces];
  distributedForce=Total[Lookup[loads,"EstimatedLocalLoadVector_N"]];
  targetMoment=Total[MapThread[Cross[#1,#2]&,{stations,stationForces}]];
  distributedMoment=Total[MapThread[Cross[#1,#2]&,{positions,Lookup[loads,"EstimatedLocalLoadVector_N"]}]];
  forceResidual=Norm[distributedForce-totalForce];
  momentResidual=Norm[distributedMoment-targetMoment];
  forceReferenceScale=Max[Sqrt[$MinMachineNumber],Norm[totalForce],Total[Norm/@stationForces]];
  momentReferenceScale=Max[Sqrt[$MinMachineNumber],Norm[targetMoment],
    Total[MapThread[Norm[Cross[#1,#2]]&,{stations,stationForces}]]];
  perStationForceResiduals=Lookup[stationMaps,"ForceResidual_N"];
  perStationMomentResiduals=Lookup[stationMaps,"MomentResidual_Nm"];
  <|"Patches"->loads,"StationForceTotal_N"->totalForce,
    "DistributedPatchForceTotal_N"->distributedForce,
    "StationMomentTotal_Nm"->targetMoment,"DistributedPatchMomentTotal_Nm"->distributedMoment,
    "ForceConservationResidual_N"->forceResidual,"MomentConservationResidual_Nm"->momentResidual,
    "PerStationForceResiduals_N"->perStationForceResiduals,
    "PerStationMomentResiduals_Nm"->perStationMomentResiduals,
    "PerStationPatchWeightSums"->(Total/@normalizedWeights),
    "ForceConservationPass"->TrueQ[forceResidual<=in["ICARUSLoadMapRelativeTolerance"] forceReferenceScale],
    "MomentConservationPass"->TrueQ[momentResidual<=in["ICARUSLoadMapRelativeTolerance"] momentReferenceScale],
    "ForceAndMomentConservationPass"->TrueQ[
      forceResidual<=in["ICARUSLoadMapRelativeTolerance"] forceReferenceScale &&
      momentResidual<=in["ICARUSLoadMapRelativeTolerance"] momentReferenceScale],
    "LoadTransferModel"->in["ICARUSLoadTransferModel"],
    "Model"->"For the explicitly selected GaussianMomentCorrected model, station and patch locations are both evaluated in the centre-of-mass frame. Log-shifted Gaussian weights prevent numerical underflow; each station's spatial load is normalized across all surface patches. A zero-net-force correction then preserves the station's exact resultant moment; global force and moment are independently checked. Conservation tolerances scale against the sum of the individual station resultants/moments, so pure torque commands with nearly zero net force are not falsely failed by cancellation roundoff. This is a reduced-order load-transfer surrogate, not a constitutive finite-element stress solution."|>
];


phase1RotationMatrix[qInput_List] := Module[{qv=Normalize[qInput],q0,q1,q2,q3},
  {q0,q1,q2,q3}=qv;
  {{1.-2. (q2^2+q3^2),2. (q1 q2-q0 q3),2. (q1 q3+q0 q2)},
   {2. (q1 q2+q0 q3),1.-2. (q1^2+q3^2),2. (q2 q3-q0 q1)},
   {2. (q1 q3-q0 q2),2. (q2 q3+q0 q1),1.-2. (q1^2+q2^2)}}
];

phase1RotateMeshToCOM[mesh_Association,center_List,q_List] := Module[{rot,patches},
  rot=phase1RotationMatrix[q];
  patches=Map[Function[p,Join[p,<|"Position_m"->rot.(p["Position_m"]-center),
    "Normal"->Normalize[rot.p["Normal"]]|>]],mesh["Patches"]];
  Join[mesh,<|"Patches"->patches,"ReferencePointLocal_m"->center,
    "AttitudeQuaternion"->Normalize[q],"FrameDescription"->"Patch positions are relative to centre of mass and rotated into the inertial frame."|>]
];

phase1GravityLoads[in_Association,dyn_Association,heliocentricCenter_List,q_List] := Module[
  {rot,bodyPositions,masses,inertialPositions,forces,torques},
  rot=phase1RotationMatrix[q];
  bodyPositions=dyn["MassPointPositionsLocal_m"];
  masses=dyn["MassPointMasses_kg"];
  inertialPositions=Map[heliocentricCenter+rot.#&,bodyPositions];
  forces=MapThread[-in["SolarGravitationalParameter_m3_s2"] #1 #2/Norm[#2]^3&,{masses,inertialPositions}];
  torques=MapThread[Cross[rot.#1,#2]&,{bodyPositions,forces}];
  <|"IndividualMassPointPositionsHeliocentric_m"->inertialPositions,
    "IndividualGravityForces_N"->forces,"IndividualGravityTorquesAboutCOM_Nm"->torques,
    "TotalGravityForce_N"->Total[forces],"TotalGravityTorqueInertial_Nm"->Total[torques],
    "GravityModel"->"Solar gravity is evaluated at every discretized sheet, perimeter-hardware and configured station mass point; the resulting net force and gravity-gradient torque are summed about the system centre of mass."|>
];


phase1SolarWindLoads[in_Association,patches_List,r_?NumericQ,radialDirection_List] := Module[
  {pressure,dir,forces,torques,totalForce,totalTorque,projectedArea},
  dir=Normalize[radialDirection];
  pressure=in["SolarWindProtonDensity_1AU_cm3"] in["CentimetersPerMeter"]^3 in["ProtonMass_kg"] in["SolarWindSpeed_1AU_m_s"]^2 (in["AstronomicalUnit_m"]/r)^2;
  forces=Map[Function[p,pressure Max[0.,p["Normal"].dir] p["SurfaceAreaWeight_m2"] dir],patches];
  torques=MapThread[Cross[#1,#2]&,{Lookup[patches,"Position_m"],forces}];
  totalForce=Total[forces];totalTorque=Total[torques];
  projectedArea=Total[Map[Max[0.,# ["Normal"].dir] # ["SurfaceAreaWeight_m2"]&,patches]];
  <|"DynamicPressure_Pa"->pressure,"ProjectedArea_m2"->projectedArea,
    "PatchForces_N"->forces,"PatchTorquesAboutCOM_Nm"->torques,
    "TotalForce_N"->totalForce,"TotalTorqueAboutCOM_Nm"->totalTorque,
    "Model"->"Proton ram pressure at local heliocentric distance, applied patchwise along the outward Sun-radial direction using local projected area. Magnetic-field, alpha-particle and anisotropic-flow terms are omitted."|>
];

phase1NaturalEquilibrium[in_Association,rad_Association,mass_Association,dyn_Association] := Module[
  {center,q,gravity,wind,netForce,netTorque,acc,forceResidual,torqueResidual,forcePass,torquePass},
  center={in["Distance_m"],0.,0.};q=dyn["InitialQuaternion"];
  gravity=phase1GravityLoads[in,dyn,center,q];
  wind=phase1SolarWindLoads[in,rad["PatchLoads"],in["Distance_m"],Normalize[center]];
  netForce=rad["NetRadiationForceVector_N"]+gravity["TotalGravityForce_N"]+wind["TotalForce_N"];
  netTorque=rad["NetRadiationMoment_Nm"]+gravity["TotalGravityTorqueInertial_Nm"]+wind["TotalTorqueAboutCOM_Nm"];
  acc=netForce/mass["TotalMass_kg"];
  forceResidual=Norm[acc];torqueResidual=Norm[netTorque];
  forcePass=TrueQ[forceResidual<=in["ExactEquilibriumAccelerationTolerance_m_s2"]];
  torquePass=TrueQ[torqueResidual<=in["ExactEquilibriumTorqueTolerance_Nm"]];
  <|"GravityLoads"->KeyDrop[gravity,{"IndividualMassPointPositionsHeliocentric_m","IndividualGravityForces_N","IndividualGravityTorquesAboutCOM_Nm"}],
    "SolarWindLoads"->KeyDrop[wind,{"PatchForces_N","PatchTorquesAboutCOM_Nm"}],
    "NetNaturalForceVector_N"->netForce,"NetNaturalTorqueAboutCOM_Nm"->netTorque,
    "NetNaturalAccelerationVector_m_s2"->acc,"NaturalForceResidualMagnitude_m_s2"->forceResidual,
    "NaturalTorqueResidualMagnitude_Nm"->torqueResidual,
    "ExactVectorEquilibrium"->forcePass,"ExactTorqueEquilibrium"->torquePass,
    "ExactNaturalEquilibrium"->(forcePass&&torquePass),
    "ExactNaturalEquilibriumPerPoleAssembly"->(forcePass&&torquePass),
    "EquilibriumScope"->"One independently operated pole system; evaluated separately for Pole1 and Pole2.",
    "PoleOperatingStateIsIndependent"->True,
  "WholeTwoPoleSystemEquilibriumEvaluated"->False,
    "WholeSystemEquilibriumNotEvaluatedReason"->"The two pole systems are intentionally independent. No inter-pole force, torque, controller, operating-state or structural coupling is modelled or required. Each pole receives its own independent force/torque equilibrium assessment; only scalar outputs such as mass and power are summed for reporting.",
    "ForceEquilibriumModel"->"Distributed solar gravity plus attitude-dependent patch-integrated radiation and continuous solar-wind ram-pressure force at the supplied initial attitude.",
    "TorqueEquilibriumModel"->"Radiation-pressure torque, gravity-gradient torque and patch-resolved solar-wind ram-pressure torque; thermal recoil and elastic coupling remain outside this Phase 1 model.",
    "NaturalEquilibriumQualification"->If[forcePass&&torquePass,"Per-pole force and torque residuals both satisfy user-supplied tolerances within the stated reduced-order model; whole two-pole system balance is not evaluated.","NOT a natural equilibrium: one or both force/torque residuals exceed their user-supplied tolerances." ]|>
];

phase1MergeNaturalEquilibrium[mass_Association,nat_Association] := Join[mass,<|
  "NetNaturalForceVector_N"->nat["NetNaturalForceVector_N"],
  "NetNaturalTorqueAboutCOM_Nm"->nat["NetNaturalTorqueAboutCOM_Nm"],
  "NetNaturalAccelerationVector_m_s2"->nat["NetNaturalAccelerationVector_m_s2"],
  "NetRadialAcceleration_m_s2"->nat["NetNaturalAccelerationVector_m_s2"][[1]],
  "NaturalForceResidualMagnitude_m_s2"->nat["NaturalForceResidualMagnitude_m_s2"],
  "NaturalTorqueResidualMagnitude_Nm"->nat["NaturalTorqueResidualMagnitude_Nm"],
  "ExactVectorEquilibrium"->nat["ExactVectorEquilibrium"],
  "ExactTorqueEquilibrium"->nat["ExactTorqueEquilibrium"],
  "ExactNaturalEquilibrium"->nat["ExactNaturalEquilibrium"],
  "ExactNaturalEquilibriumPerPoleAssembly"->nat["ExactNaturalEquilibriumPerPoleAssembly"],
  "EquilibriumScope"->nat["EquilibriumScope"],
  "WholeTwoPoleSystemEquilibriumEvaluated"->nat["WholeTwoPoleSystemEquilibriumEvaluated"],
  "WholeSystemEquilibriumNotEvaluatedReason"->nat["WholeSystemEquilibriumNotEvaluatedReason"],
  "NaturalEquilibriumQualification"->nat["NaturalEquilibriumQualification"]|>];


phase1NaturalCandidateAt[in_Association,geo_Association,mesh_Association,optics_Association,
    pvFraction_?NumericQ,distance_?NumericQ] := Module[
  {candidateInputs,rad0,mass0,dyn0,attitudeMesh,rad,mass,dyn,natural},
  candidateInputs=Join[in,<|"Distance_m"->distance,"PVFraction"->pvFraction|>];
  rad0=phase1Radiation[candidateInputs,geo,mesh,optics,pvFraction,distance,
    candidateInputs["IncidenceAngle_deg"]];
  mass0=phase1Mass[candidateInputs,geo,rad0,pvFraction,distance];
  dyn0=phase1DynamicsInitial[candidateInputs,geo,mass0,mesh];
  attitudeMesh=phase1RotateMeshToCOM[mesh,dyn0["CenterOfMassLocal_m"],dyn0["InitialQuaternion"]];
  rad=phase1Radiation[candidateInputs,geo,attitudeMesh,optics,pvFraction,distance,
    candidateInputs["IncidenceAngle_deg"],phase1SunVector[candidateInputs["IncidenceAngle_deg"]]];
  mass=phase1Mass[candidateInputs,geo,rad,pvFraction,distance];
  dyn=phase1DynamicsInitial[candidateInputs,geo,mass,mesh];
  natural=phase1NaturalEquilibrium[candidateInputs,rad,mass,dyn];
  <|"Inputs"->candidateInputs,"Radiation"->rad,"RawMass"->mass,
    "Mass"->phase1MergeNaturalEquilibrium[mass,natural],"Dynamics"->dyn,
    "AttitudeMesh"->attitudeMesh,"Natural"->natural|>
];

(* Independent bracketed bisection used by the joint optimizer. The standalone
   exact-equilibrium solver uses FindRoot/Brent on the same distributed-force
   residual, so the two root methods can be compared without duplicating physics. *)
phase1BracketedBisection[f_,{lo_?NumericQ,hi_?NumericQ},tol_?NumericQ,maxIter_Integer] := Module[
  {a=lo,b=hi,fa,fb,m,fm,k=0,width},
  If[!TrueQ[a<b] || !TrueQ[tol>0.] || !TrueQ[maxIter>0],Return[$Failed]];
  fa=f[a];fb=f[b];
  If[!NumericQ[fa] || !NumericQ[fb],Return[$Failed]];
  If[Abs[fa]<=tol,Return[a]];
  If[Abs[fb]<=tol,Return[b]];
  If[fa fb>0.,Return[$Failed]];
  While[k<maxIter,
    m=(a+b)/2;fm=f[m];
    If[!NumericQ[fm],Return[$Failed]];
    If[Abs[fm]<=tol,Return[m]];
    If[fa fm<0.,b=m;fb=fm,a=m;fa=fm];
    width=Abs[b-a];
    If[width<=tol Max[Sqrt[$MinMachineNumber],Abs[a],Abs[b]],
      m=(a+b)/2;fm=f[m];
      If[NumericQ[fm] && Abs[fm]<=tol,Return[m],Return[$Failed]]
    ];
    k++
  ];
  $Failed
];


phase1InputChecksPass[checks_Association] := Module[{metadata, booleanChecks},
  metadata = {"RequiredInputsPresent", "OptionalSourceNotesPresent",
    "MissingRequiredInputKeys", "OptionalSourceNotesMissing", "InputValidationEvaluationFailed"};
  booleanChecks = KeyDrop[checks, metadata];
  TrueQ[Lookup[checks, "RequiredInputsPresent", False]] &&
    Lookup[checks, "MissingRequiredInputKeys", {"MissingMetadata"}] === {} &&
    !TrueQ[Lookup[checks, "InputValidationEvaluationFailed", False]] &&
    And @@ (TrueQ /@ Values[booleanChecks])
];

phase1InputChecks[in_Association] := Module[{missing,checks},
  missing=Select[Keys[in],MissingQ[in[#]]&];
  If[missing =!= {},Return[<|"RequiredInputsPresent"->False,"MissingRequiredInputKeys"->missing|>]];
  checks=Quiet@Check[<|
    "PositivePhysicalConstants"->TrueQ[And@@(NumericQ[#]&&#>0.&/@{in["SolarLuminosity_W"],in["SolarGravitationalParameter_m3_s2"],in["UniversalGravitationalConstant_m3_kg_s2"],in["SolarIrradianceAt1AU_W_m2"],in["SpeedOfLight_m_s"],in["AstronomicalUnit_m"],in["StefanBoltzmann_W_m2_K4"]})],
    "PositiveDistance"->TrueQ[NumericQ[in["Distance_m"]]&&in["Distance_m"]>0.],
    "PositiveGeometryAndPoleInputs"->TrueQ[NumericQ[in["PerPoleProjectedArea_m2"]]&&in["PerPoleProjectedArea_m2"]>0.&&in["PoleCount"]===2&&IntegerQ[in["PoleCount"]]&&0.<in["CapDepthToPlanformRadius"]<1.&&NumericQ[in["IncidenceAngle_deg"]]&&-90.<in["IncidenceAngle_deg"]<90.],
    "ICARUSStationCountScopeSupported"->TrueQ[in["ICARUSStationCountScope"]==="PerPoleAssembly"],
    "CoverageWithinUnitInterval"->TrueQ[0.<=in["PVFraction"]<=1.],
    "OpticalFractionsPhysicallyValid"->TrueQ[0.<=in["ReflectorSolarReflectivity"]<=1.&&0.<=in["ReflectorSolarTransmissivity"]<=1.&&in["ReflectorSolarReflectivity"]+in["ReflectorSolarTransmissivity"]<=1.&&0.<=in["PVSolarReflectivity"]<=1.&&0.<=in["PVSolarTransmissivity"]<=1.&&in["PVSolarReflectivity"]+in["PVSolarTransmissivity"]<=1.],
    "MembraneSubstrateMaterialNamePresent"->TrueQ[StringQ[in["MembraneSubstrateMaterialName"]]&&StringTrim[in["MembraneSubstrateMaterialName"]]=!=""],
    "MassInputsNonnegative"->TrueQ[And@@(NumericQ[#]&&#>=0.&/@{in["PVArealMass_kg_m2"],in["PVIntegratedFabricArealMass_kg_m2"],in["ReflectorArealMass_kg_m2"],in["MembraneSubstrateArealMass_kg_m2"],in["WiringArealMass_kg_m2"],in["OtherInstalledArealMass_kg_m2"],in["ICARUSStationMass_kg"],in["DeferredEquipmentMass_kg"]})],
    "PVSpecificPowerReferenceIrradiancePositive"->TrueQ[NumericQ[in["PVSpecificPowerReferenceIrradiance_W_m2"]]&&in["PVSpecificPowerReferenceIrradiance_W_m2"]>0.],
    "PerimeterHardwareLinearMassValid"->TrueQ[NumericQ[in["PerimeterHardwareLinearMass_kg_m"]]&&in["PerimeterHardwareLinearMass_kg_m"]>=0.],
    "DeferredEquipmentMassExcludedFromPhase1MassDistribution"->TrueQ[in["DeferredEquipmentMass_kg"]==0.],
    "StationCountMatchesRegisteredStationPositions"->TrueQ[IntegerQ[in["ICARUSStationCount"]] && in["ICARUSStationCount"]>=1 &&
      ListQ[in["ICARUSStationPositionsLocal_m"]] && Length[in["ICARUSStationPositionsLocal_m"]]==in["ICARUSStationCount"] &&
      And@@(Function[p,Length[p]==3 && VectorQ[p,NumericQ]]/@in["ICARUSStationPositionsLocal_m"])],
    "StationCoordinatesWithinPlanform"->TrueQ[And@@(Function[p,Norm[p[[2;;3]]]<=Sqrt[in["PerPoleProjectedArea_m2"]/Pi] (1.+Sqrt[$MachineEpsilon])]/@in["ICARUSStationPositionsLocal_m"])],
    "MassDistributionInputsValid"->TrueQ[in["ICARUSStationMass_kg"]>=0.&&in["ICARUSStationForceCapacity_N"]>0.&&0.<in["MembraneLoadSpreadFractionOfRadius"]<1.],
    "ICARUSValidationInputsValid"->TrueQ[in["ICARUSLoadMapRelativeTolerance"]>0.],
    "DisturbanceInputsValid"->TrueQ[in["FlarePeakFraction"]>=0.&&in["FlarePeakTime_s"]>=0.&&in["FlareDuration_s"]>0.&&0.<in["FlareTailCutoffFraction"]<1.&&phase1FlareTimeBounds[in]["StartTime_s"]>=0.&&in["CMEOnset_s"]>=0.&&in["CMEWindPressureMultiplier"]>=1.&&in["CMEDuration_s"]>0.&&in["Year_s"]>0.&&in["ReferenceMissionYears"]>0.],
    "ControllerAndWobbleInputsValid"->TrueQ[And@@(#>=0.&/@{in["ControllerTranslationKp_perS2"],in["ControllerTranslationKd_perS"],in["ControllerAttitudeKp_perS2"],in["ControllerAttitudeKd_perS"],in["WobbleDampingRatio"]})&&in["WobbleNaturalPeriod_s"]>0.],
    "PVScenarioOptionsValid"->TrueQ[Sort[in["PVScenarioOptions"]]===Sort[{"MITSpecificPowerLimited","MITIntegratedFabricSpecificPowerLimited","MITEfficiencyReference","ProjectSpecifiedTargetEfficiency"}]],
        "PVScenarioRecognized"->MemberQ[in["PVScenarioOptions"],in["PrimaryPVScenario"]],
    "PVLayoutModelSupported"->TrueQ[in["PVLayoutModel"]==="UniformSurfaceCoverage"],
    "GeometryProfileModelSupported"->TrueQ[in["GeometryProfileModel"]==="SphericalCapSurrogate"],
    "MassDistributionModelSupported"->TrueQ[in["MassDistributionModel"]==="UniformSheetMassWithPerimeterLineMassAndStationPointMasses"],
    "FlareTemporalProfileSupported"->TrueQ[in["FlareTemporalProfile"]==="GaussianFWHM"],
    "CMETemporalProfileSupported"->TrueQ[in["CMETemporalProfile"]==="RectangularPressureEnvelope"],
    "ICARUSLoadTransferModelSupported"->TrueQ[in["ICARUSLoadTransferModel"]==="GaussianMomentCorrected"],
    "MembraneStructuralModelSupported"->TrueQ[in["MembraneStructuralModel"]==="TensionedCircularMembrane"],
    "WobbleRestoringModelSupported"->TrueQ[in["WobbleRestoringModel"]==="LinearSecondOrderAttitudeRestoring"],
    "PVIntegratedFabricMassPolicyValid"->MemberQ[{True,False},in["PVIntegratedMassIncludesStructuralFabric"]],
    "ReflectionModelSupported"->TrueQ[in["ReflectionModel"]==="Specular"],
    "ThermalAndStructuralInputsPositive"->TrueQ[And@@(#>0.&/@{in["PVIRemissivity"],in["ReflectorIRemissivity"],in["ReflectorTemperatureLimit_K"],in["PVTemperatureLimit_K"],in["MembraneMaterialDensity_kg_m3"],in["MembraneEffectiveYoungsModulus_Pa"],in["MembraneEffectiveUltimateStrength_Pa"],in["StructuralSafetyFactor"],in["MaximumDeflectionFractionOfRadius"],in["MembranePretension_N_m"],in["CentimetersPerMeter"],in["CircularMembraneDeflectionCoefficient"],in["SEPDoseReference_protons_cm2"]})&&in["PVIRemissivity"]<=1.&&in["ReflectorIRemissivity"]<=1.&&in["MaximumDeflectionFractionOfRadius"]<1.],
    "ThermalInputsValid"->TrueQ[MemberQ[{True,False},in["BothSidesRadiate"]]&&0.<in["PVIRemissivity"]<=1.&&0.<in["ReflectorIRemissivity"]<=1.&&in["PVTemperatureLimit_K"]>0.&&in["ReflectorTemperatureLimit_K"]>0.],
    "SolarWindInputsValid"->TrueQ[in["SolarWindProtonDensity_1AU_cm3"]>=0.&&in["SolarWindSpeed_1AU_m_s"]>=0.&&in["ProtonMass_kg"]>0.],
    "DegradationInputsValid"->TrueQ[0.<=in["PVAnnualDegradationFraction"]<1.&&0.<=in["ReflectivityAnnualLossFraction"]<1.&&0.<=in["PVDegradationPerSEPReferenceDoseFraction"]<1.&&in["SEPDose_protons_cm2"]>=0.],
    "EfficiencyAndElectricalInputsValid"->TrueQ[0.<=in["MITEfficiencyReference"]<=1.&&0.<=in["PVIntegratedEfficiencyReference"]<=1.&&0.<=in["ProjectTargetEfficiency"]<=1.&&0.<in["TransferEfficiency"]<=1.&&0.<in["ConditioningEfficiency"]<=1.],
    "RecoveryCriteriaValid"->TrueQ[in["RecoveryTimeMaximum_s"]>0.&&in["VelocityRecoveryTolerance_m_s"]>0.&&in["AngularRateRecoveryTolerance_rad_s"]>0.&&in["DynamicCheckDuration_s"]>Max[phase1FlareTimeBounds[in]["EndTime_s"],in["CMEOnset_s"]+in["CMEDuration_s"]]+in["RecoveryTimeMaximum_s"]],
    "AcceptanceTolerancesValid"->TrueQ[And@@(#>0.&/@{in["ExactEquilibriumAccelerationTolerance_m_s2"],in["ExactEquilibriumTorqueTolerance_Nm"],in["ExactEquilibriumRelativeTolerance"],in["RadialDeviationToleranceFractionOfRadius"],in["LateralDeviationToleranceFractionOfRadius"],in["AttitudeTolerance_rad"],in["RecoveryTimeMaximum_s"],in["VelocityRecoveryTolerance_m_s"],in["AngularRateRecoveryTolerance_rad_s"],in["DynamicCheckDuration_s"],in["MeshCoefficientCrossCheckTolerance"],in["OptimizerGridCrossCheckRelativeTolerance"]})&&in["AttitudeTolerance_rad"]<Pi&&0.<=in["PVSearchRange"][[1]]<in["PVSearchRange"][[2]]<=1.],
    "ModelCoefficientInputsValid"->TrueQ[NumericQ[in["PVEfficiencyTemperatureCoefficient_perK"]]&&in["PVReferenceTemperature_K"]>0.],
    "DynamicAndMeshCountsValid"->TrueQ[And@@(IntegerQ[#]&&#>0&/@{in["MeshRadialCount"],in["MeshAzimuthCount"],in["OptimizerMeshRadialCount"],in["OptimizerMeshAzimuthCount"],in["DynamicSampleCount"],in["DynamicLoadPropagationSampleCount"]})&&IntegerQ[in["DynamicAccuracyGoal"]]&&in["DynamicAccuracyGoal"]>0&&IntegerQ[in["DynamicPrecisionGoal"]]&&in["DynamicPrecisionGoal"]>0&&(in["DynamicMaxSteps"]===Infinity||(IntegerQ[in["DynamicMaxSteps"]]&&in["DynamicMaxSteps"]>0))],
    "SearchBoundsValid"->TrueQ[VectorQ[in["DistanceSearchRange_m"],NumericQ]&&Length[in["DistanceSearchRange_m"]]==2&&in["DistanceSearchRange_m"][[1]]>0.&&in["DistanceSearchRange_m"][[2]]>in["DistanceSearchRange_m"][[1]]&&0.<=in["PVSearchRange"][[1]]<in["PVSearchRange"][[2]]<=1.],
    "VectorInitialConditionsValid"->TrueQ[And@@(Function[v,Length[v]==3&&VectorQ[v,NumericQ]]/@{in["InitialAngularVelocity_rad_s"],in["InitialAttitudeSmallAngles_rad"],in["InitialPositionLocal_m"],in["InitialVelocityLocal_m_s"],in["InitialVelocityHeliocentric_m_s"]})],
    "HeliocentricReferenceMotionModeSupported"->TrueQ[in["HeliocentricReferenceMotionMode"]==="StaticHover"],
    "HeliocentricStaticHoverVelocityValid"->TrueQ[in["HeliocentricReferenceMotionMode"]==="StaticHover"&&Norm[in["InitialVelocityHeliocentric_m_s"]]==0.],
    "NumericalSolverSettingsValid"->TrueQ[IntegerQ[in["OptimizerMaxIterations"]]&&in["OptimizerMaxIterations"]>0&&IntegerQ[in["PVThermalCouplingMaxIterations"]]&&in["PVThermalCouplingMaxIterations"]>0&&IntegerQ[in["OptimizerGridPointCount"]]&&in["OptimizerGridPointCount"]>=1&&
      IntegerQ[in["OptimizerCoverageGridPointCount"]]&&in["OptimizerCoverageGridPointCount"]>=1&&in["OptimizerGridCrossCheckRelativeTolerance"]>0.&&(in["NumericalWorkingPrecision"]===MachinePrecision||(NumericQ[in["NumericalWorkingPrecision"]]&&in["NumericalWorkingPrecision"]>=MachinePrecision))&&And@@(#>0.&/@{in["MeshAreaRelativeTolerance"],in["AccelerationCrossCheckRelativeTolerance"],in["SolarReferenceConsistencyRelativeTolerance"],in["ThermalResidualRelativeTolerance"],in["QuaternionNormalizationTolerance"],in["OpticalClosureTolerance"],in["PowerLedgerRelativeTolerance"],in["ICARUSLoadMapRelativeTolerance"]})]
  |>,False];
  If[!AssociationQ[checks],<|"RequiredInputsPresent"->True,"InputValidationEvaluationFailed"->True|>,
    Join[<|"RequiredInputsPresent"->True,"MissingRequiredInputKeys"->{}|>,checks]]
];

(* ========================================================================
   3. PUBLIC CALCULATION PIPELINE — dependency order and central storage
   ======================================================================== *)

phase1StoreRun[derived_Association,results_Association,dependencies_Association] := Module[{stamp},
  stamp=DateString[{"Year","-","Month","-","Day"," ","Hour",":","Minute",":","Second"}];
  $Phase1State=Join[$Phase1State,<|"Derived"->derived,"Results"->results,
    "LastRun"-><|"Time"->stamp,"InputSnapshot"->$Phase1State["Inputs"],
      "InputSnapshotHash"->Hash[$Phase1State["Inputs"],"SHA256"],
      "OptionalSourceNotesSnapshot"->$Phase1State["InputNotes"],
      "OptionalSourceNotesSnapshotHash"->Hash[$Phase1State["InputNotes"],"SHA256"],
      "CalculationManifest"->dependencies|>|>];
  phase1Audit["FullCalculationPipelineCompleted",<|"ResultNames"->Keys[results],"DerivedNames"->Keys[derived]|>];
  results
];

phase1ComputeCurrentPole[] := Module[
  {in,inputChecks,geo,mesh,optics,sun,illum,rad,mass,thermal,pv,power,missionEnd,structure,dyn,wrench,capacity,coupledPerformance,
   zeroWrench,allocation,loadmap,testAllocations,testLoadMaps,disturbance,checks,derived,results,manifest,
   meshAttitude,naturalEquilibrium},
  in=Phase1GetInputs[];
  inputChecks=phase1InputChecks[in];
  If[!phase1InputChecksPass[inputChecks],
    phase1Audit["InputValidationFailed",inputChecks];
    Return[Failure["InvalidPhase1Inputs",<|"Checks"->inputChecks|>]]
  ];
  geo=phase1Geometry[in];
  mesh=phase1Mesh[in,geo];
  optics=phase1Optics[in];
  sun=phase1SunVector[in["IncidenceAngle_deg"]];
  illum=phase1Illumination[mesh,sun];
  (* A first radiation/mass pass establishes sheet mass and centre of mass. *)
  rad=phase1Radiation[in,geo,mesh,optics,in["PVFraction"],in["Distance_m"],in["IncidenceAngle_deg"]];
  mass=phase1Mass[in,geo,rad,in["PVFraction"],in["Distance_m"]];
  dyn=phase1DynamicsInitial[in,geo,mass,mesh];
  (* Recompute radiation force and torque using the actual supplied initial attitude and COM. *)
  meshAttitude=phase1RotateMeshToCOM[mesh,dyn["CenterOfMassLocal_m"],dyn["InitialQuaternion"]];
  rad=phase1Radiation[in,geo,meshAttitude,optics,in["PVFraction"],in["Distance_m"],in["IncidenceAngle_deg"],sun];
  mass=phase1Mass[in,geo,rad,in["PVFraction"],in["Distance_m"]];
  dyn=phase1DynamicsInitial[in,geo,mass,mesh];
  naturalEquilibrium=phase1NaturalEquilibrium[in,rad,mass,dyn];
  mass=phase1MergeNaturalEquilibrium[mass,naturalEquilibrium];
  coupledPerformance=phase1CoupledPVThermal[in,geo,meshAttitude,optics,rad,in["PVFraction"],in["Distance_m"],0.];
  If[FailureQ[coupledPerformance],Return[coupledPerformance]];
  thermal=coupledPerformance["Thermal"];pv=coupledPerformance["PVPerformance"];
  power=phase1Power[in,pv];
  missionEnd=phase1PerformanceAtTime[in,geo,meshAttitude,in["ReferenceMissionYears"] in["Year_s"],
    dyn["InitialPositionLocal_m"],dyn["InitialQuaternion"]];
  If[FailureQ[missionEnd],Return[missionEnd]];
  structure=phase1Structural[in,geo,rad];
  wrench=dyn["WrenchMatrix"];
  capacity=in["ICARUSStationForceCapacity_N"];
  zeroWrench=ConstantArray[0.,6];
  allocation=phase1Controller[dyn,zeroWrench,capacity];
  loadmap=phase1LoadMap[in,geo,mesh,dyn,allocation["StationForces_N"]];
  testAllocations=Table[phase1Controller[dyn,UnitVector[6,i],Infinity],{i,6}];
  testLoadMaps=Table[phase1LoadMap[in,geo,mesh,dyn,testAllocations[[i]]["StationForces_N"]],{i,6}];
  disturbance=<|"FlarePeakFraction"->in["FlarePeakFraction"],"FlarePeakTime_s"->in["FlarePeakTime_s"],
    "FlareDuration_s"->in["FlareDuration_s"],"FlareTailCutoffFraction"->in["FlareTailCutoffFraction"],"CMEWindPressureMultiplier"->in["CMEWindPressureMultiplier"],
    "CMEOnset_s"->in["CMEOnset_s"],"CMEDuration_s"->in["CMEDuration_s"],
    "BaselineSolarWindDynamicPressureAt1AU_Pa"->in["SolarWindProtonDensity_1AU_cm3"] in["CentimetersPerMeter"]^3 in["ProtonMass_kg"] in["SolarWindSpeed_1AU_m_s"]^2|>;
  checks=phase1ValidateCore[in,geo,meshAttitude,optics,rad,mass,thermal,pv,power,structure,dyn,wrench,naturalEquilibrium];
  checks=Join[checks,<|
    "StationCoordinatesWithinPlanform"->TrueQ[Lookup[inputChecks,"StationCoordinatesWithinPlanform",False]],
    "HeliocentricReferenceMotionModeSupported"->TrueQ[Lookup[inputChecks,"HeliocentricReferenceMotionModeSupported",False]],
    "HeliocentricStaticHoverVelocityValid"->TrueQ[Lookup[inputChecks,"HeliocentricStaticHoverVelocityValid",False]],
    "AllCentralInputChecksPass"->TrueQ[phase1InputChecksPass[inputChecks]],
    "PVScenarioOptionsValid"->TrueQ[Lookup[inputChecks,"PVScenarioOptionsValid",False]],
    "PVScenarioRecognized"->TrueQ[Lookup[inputChecks,"PVScenarioRecognized",False]],
    "ICARUSWrenchAllocatorReconstructsDemand"->TrueQ[Max[Table[Norm[testAllocations[[i]]["AchievedWrench"]-UnitVector[6,i]],{i,6}]]<=in["ICARUSLoadMapRelativeTolerance"]],
    "ICARUSLoadMapConservesStationForce"->TrueQ[Length[testLoadMaps]==6 && And@@(AssociationQ[#] && TrueQ[Lookup[#,"ForceConservationPass",False]]&/@testLoadMaps)],
    "ICARUSLoadMapConservesStationMoment"->TrueQ[Length[testLoadMaps]==6 && And@@(AssociationQ[#] && TrueQ[Lookup[#,"MomentConservationPass",False]]&/@testLoadMaps)],
    "ICARUSPerStationLoadWeightsNormalize"->TrueQ[Max[Flatten[Abs[Lookup[testLoadMaps,"PerStationPatchWeightSums"]-1.]]]<=in["ICARUSLoadMapRelativeTolerance"]]
  |>];
  derived=<|"Geometry"->geo,"SurfaceMesh"->mesh,"InitialAttitudeSurfaceMesh"->meshAttitude,
    "OpticalRegister"->optics,"SunVector"->sun,"Illumination"->KeyDrop[illum,"PatchIncidenceCosines"]|>;
  results=<|"InputValidation"->inputChecks,"LocalRadiation"->rad,"MassBalance"->mass,
    "NaturalEquilibrium"->naturalEquilibrium,"Thermal"->thermal,"PVPerformance"->pv,"PowerLedger"->power,
    "MissionEndPerformance"->missionEnd,"StructuralScreen"->structure,"DynamicInitialConditions"->dyn,
    "ICARUSWrenchMatrix"->wrench,"ICARUSCapacityPerStation_N"->capacity,
    "ICARUSZeroCommandAllocation"->KeyDrop[allocation,"WrenchMatrix"],
    "ICARUSInitialLoadMap"->KeyDrop[loadmap,"Patches"],
    "ICARUSWrenchAllocatorCrossCheck"->testAllocations,
    "ICARUSLoadMapCrossCheck"->Map[KeyDrop[#,"Patches"]&,testLoadMaps],
    "DisturbanceInputs"->disturbance,"Validation"->checks|>;
  manifest=<|
    "01_Geometry"-><|"Inputs"->{"GeometryProfileModel","PerPoleProjectedArea_m2","CapDepthToPlanformRadius"},"Outputs"->{"Geometry"}|>,
    "02_SurfaceMesh"-><|"DependsOn"->{"Geometry"},"Outputs"->{"SurfaceMesh","LocalNormals","AreaWeights"}|>,
    "03_OpticalClosure"-><|"Inputs"->{"ReflectorSolarReflectivity","ReflectorSolarTransmissivity","PVSolarReflectivity","PVSolarTransmissivity"},"Outputs"->{"OpticalRegister"}|>,
    "04_LocalRadiation"-><|"DependsOn"->{"SurfaceMesh","OpticalRegister","Distance_m","PVFraction","IncidenceAngle_deg","InitialAttitudeSmallAngles_rad"},"Outputs"->{"LocalRadiation","MomentumCoefficient","RadiationForce","RadiationMoment"}|>,
    "05_MassAndNaturalEquilibrium"-><|"DependsOn"->{"MassDistributionModel","Geometry","LocalRadiation","PVModuleMass","MembraneSubstrateMass","ReflectiveCoatingMass","WiringMass","PerimeterHardwareLinearMass","StationMass","StationCoordinates"},"Outputs"->{"MassBalance","DistributedGravity","NaturalForceResidual","NaturalTorqueResidual"}|>,
    "06_Thermal"-><|"DependsOn"->{"Geometry","LocalRadiation","OpticalRegister","ThermalInputs"},"Outputs"->{"Thermal"}|>,
    "07_PVAndPower"-><|"DependsOn"->{"PVLayoutModel","Thermal","LocalRadiation","PVInputs","SpecificPowerReference","ElectricalInputs","Degradation","MissionDuration"},"Outputs"->{"PVPerformance","PowerLedger","MissionEndPerformance"}|>,
    "08_Structure"-><|"DependsOn"->{"MembraneStructuralModel","Geometry","LocalRadiation","MembraneInputs"},"Outputs"->{"StructuralScreen"}|>,
    "09_DynamicsAndICARUS"-><|"DependsOn"->{"MassDistributionModel","ICARUSLoadTransferModel","WobbleRestoringModel","MassBalance","Geometry","ICARUSInputs","DynamicsInputs"},"Outputs"->{"DynamicInitialConditions","ICARUSWrenchMatrix","ICARUSCapacityPerStation_N","ICARUSInitialLoadMap","NaturalEquilibrium"}|>,
    "10_Validation"-><|"DependsOn"->{"All preceding calculation outputs"},"Outputs"->{"Validation"}|>,
    "11_CentralStateAudit"-><|"InputsFrom"->{"$Phase1State[Inputs]"},"OutputsStoredIn"->{"$Phase1State[Derived]","$Phase1State[Results]","$Phase1State[LastRun]"},
      "FreshnessRule"->"Every core accessor verifies the exact numerical/model input snapshot and calculation manifest; optional source notes do not affect cache freshness."|>
  |>;
  phase1StoreRun[derived,results,manifest];
  results
];

phase1ValidateCore[in_,geo_,mesh_,optics_,rad_,mass_,thermal_,pv_,power_,structure_,dyn_,wrench_,natural_] := Module[
  {analyticCoefficient,numericalCoefficient,coefficientError,independentAccel,arealAccel,qNorm,
   fineMesh,fineMeshAtt,fineCoefficients,meshMomentumError,energyScale,validation,independentPVTemp,independentRefTemp,
   independentRadiationForce,massComponentResidual,solarMassDerived,luminosityFromSolarConstant,
   luminosityRelativeDifference,pvSpecificPowerImpliedEfficiency,integratedSpecificPowerImpliedEfficiency,
   independentScenarioOutputs,pvOutputIndependent,deliveredPowerIndependent,inertiaEigenvalues,expectedSubstrateMass,
   independentPVIrradianceFactor,independentTorque,gravityRotation,gravityPositionsHelio,gravityForcesIndependent,
   gravityTorquesIndependent,gravityForceIndependent,gravityTorqueIndependent,windPressureIndependent,
   windDirection,windForcesIndependent,windTorquesIndependent,windForceIndependent,windTorqueIndependent,
   independentRadiationFlux,independentSunDirection,independentMixAbsorptivity,independentMixReflectivity,
   independentRadiationPatchForces,independentRadiationTorque,fineMeshRadiationForce,
   independentMITReferenceEfficiency,independentIntegratedReferenceEfficiency,independentProjectTargetEfficiency},
  analyticCoefficient=Module[{a=geo["PlanformEquivalentRadius_m"],sr=geo["GeneratingSphereRadius_m"],f=in["PVFraction"],aPV=optics["PV"]["A"],rPV=optics["PV"]["R"],aR=optics["Reflector"]["A"],rR=optics["Reflector"]["R"],mixA,mixR,meanCosSquared},
    mixA=f aPV+(1.-f) aR;mixR=f rPV+(1.-f) rR;
    meanCosSquared=1.-a^2/(2. sr^2);
    mixA+2. mixR meanCosSquared
  ];
  numericalCoefficient=rad["NumericalMomentumCoefficientRadial"];
  coefficientError=Abs[numericalCoefficient-analyticCoefficient]/Max[Abs[analyticCoefficient],$MinMachineNumber];
  fineMesh=phase1Mesh[in,geo,2 in["MeshRadialCount"],2 in["MeshAzimuthCount"]];
  fineMeshAtt=phase1RotateMeshToCOM[fineMesh,dyn["CenterOfMassLocal_m"],dyn["InitialQuaternion"]];
  fineCoefficients=phase1MaterialMomentumCoefficients[fineMeshAtt,phase1SunVector[in["IncidenceAngle_deg"]],optics];
  meshMomentumError=Norm[rad["NumericalMomentumCoefficientVector"]-(in["PVFraction"] fineCoefficients["PVVectorCoefficient"]+(1.-in["PVFraction"]) fineCoefficients["ReflectorVectorCoefficient"]) ]/
    Max[Norm[fineCoefficients["PVVectorCoefficient"]],$MinMachineNumber];
  (* Independent radiation-force and torque ledger: recompute local specular momentum transfer
     from each rotated patch's normal, area and material fractions. Do not reuse phase1Radiation's
     stored force or moment, nor its stored momentum-coefficient vector. *)
  independentRadiationFlux=phase1SolarIrradiance[in,in["Distance_m"]];
  If[FailureQ[independentRadiationFlux],Return[independentRadiationFlux]];
  independentSunDirection=Normalize[{Cos[in["IncidenceAngle_deg"] Degree],Sin[in["IncidenceAngle_deg"] Degree],0.}];
  independentMixAbsorptivity=in["PVFraction"] optics["PV"]["A"]+(1.-in["PVFraction"]) optics["Reflector"]["A"];
  independentMixReflectivity=in["PVFraction"] optics["PV"]["R"]+(1.-in["PVFraction"]) optics["Reflector"]["R"];
  independentRadiationPatchForces=Map[Function[p,Module[{ci=Max[0.,p["Normal"].independentSunDirection]},
    (independentRadiationFlux/in["SpeedOfLight_m_s"])*ci*p["SurfaceAreaWeight_m2"]*
      (independentMixAbsorptivity*independentSunDirection+2.*independentMixReflectivity*ci*p["Normal"])]],rad["PatchLoads"]];
  independentRadiationForce=Total[independentRadiationPatchForces];
  independentRadiationTorque=Total[MapThread[Cross[#1,#2]&,
    {Lookup[rad["PatchLoads"],"Position_m"],independentRadiationPatchForces}]];
  fineMeshRadiationForce=independentRadiationFlux*geo["GrossProjectedAreaPerPole_m2"]/in["SpeedOfLight_m_s"]*
    (in["PVFraction"]*fineCoefficients["PVVectorCoefficient"]+(1.-in["PVFraction"])*fineCoefficients["ReflectorVectorCoefficient"]);
  (* Independent gravity recomputation: directly sum Newtonian attraction over the registered
     distributed mass points, without calling phase1GravityLoads. *)
  gravityRotation=phase1RotationMatrix[dyn["InitialQuaternion"]];
  gravityPositionsHelio=Map[{in["Distance_m"],0.,0.}+gravityRotation.#&,dyn["MassPointPositionsLocal_m"]];
  gravityForcesIndependent=MapThread[-in["SolarGravitationalParameter_m3_s2"] #1 #2/Norm[#2]^3&,
    {dyn["MassPointMasses_kg"],gravityPositionsHelio}];
  gravityTorquesIndependent=MapThread[Cross[gravityRotation.#1,#2]&,
    {dyn["MassPointPositionsLocal_m"],gravityForcesIndependent}];
  gravityForceIndependent=Total[gravityForcesIndependent];gravityTorqueIndependent=Total[gravityTorquesIndependent];
  (* Independent solar-wind recomputation: recalculate density conversion, inverse-square pressure,
     local projected patch forces and COM moments directly rather than reusing phase1SolarWindLoads. *)
  windDirection={1.,0.,0.};
  windPressureIndependent=in["SolarWindProtonDensity_1AU_cm3"]*in["CentimetersPerMeter"]^3*in["ProtonMass_kg"]*in["SolarWindSpeed_1AU_m_s"]^2*
    (in["AstronomicalUnit_m"]/in["Distance_m"])^2;
  windForcesIndependent=Map[Function[p,windPressureIndependent*Max[0.,p["Normal"].windDirection]*
    p["SurfaceAreaWeight_m2"]*windDirection],rad["PatchLoads"]];
  windTorquesIndependent=MapThread[Cross[#1,#2]&,{Lookup[rad["PatchLoads"],"Position_m"],windForcesIndependent}];
  windForceIndependent=Total[windForcesIndependent];windTorqueIndependent=Total[windTorquesIndependent];
  independentAccel=(independentRadiationForce+gravityForceIndependent+windForceIndependent)/mass["TotalMass_kg"];
  independentTorque=independentRadiationTorque+gravityTorqueIndependent+windTorqueIndependent;
  massComponentResidual=mass["TotalMass_kg"]-(mass["PVMass_kg"]+mass["ReflectorCoatingMass_kg"]+mass["MembraneSubstrateMass_kg"]+mass["WiringMass_kg"]+mass["OtherInstalledArealMass_kg"]+mass["PerimeterHardwareMass_kg"]+mass["StationMassTotal_kg"]+mass["DeferredEquipmentMass_kg"]);
  arealAccel=independentRadiationForce/(geo["GrossProjectedAreaPerPole_m2"] mass["TotalArealMass_kg_m2"])+
    (gravityForceIndependent+windForceIndependent)/mass["TotalMass_kg"];
  qNorm=Norm[dyn["InitialQuaternion"]];
  independentPVTemp=If[thermal["PVActiveArea_m2"]>0.,
    (Max[0.,rad["PVAbsorbedPower_W"]-pv["SelectedDCOutput_W"]]/(thermal["PVActiveArea_m2"] (If[TrueQ[in["BothSidesRadiate"]],2.,1.] in["PVIRemissivity"] in["StefanBoltzmann_W_m2_K4"])))^(1/4),0.];
  independentRefTemp=If[thermal["ReflectorActiveArea_m2"]>0.,
    (rad["ReflectorAbsorbedPower_W"]/(thermal["ReflectorActiveArea_m2"] (If[TrueQ[in["BothSidesRadiate"]],2.,1.] in["ReflectorIRemissivity"] in["StefanBoltzmann_W_m2_K4"])))^(1/4),0.];
  energyScale=Max[Sqrt[$MinMachineNumber],Abs[rad["TotalIncidentOpticalPower_W"]]];
  solarMassDerived=in["SolarGravitationalParameter_m3_s2"]/in["UniversalGravitationalConstant_m3_kg_s2"];
  luminosityFromSolarConstant=4. Pi in["AstronomicalUnit_m"]^2 in["SolarIrradianceAt1AU_W_m2"];
  luminosityRelativeDifference=Abs[luminosityFromSolarConstant-in["SolarLuminosity_W"]]/in["SolarLuminosity_W"];
  pvSpecificPowerImpliedEfficiency=in["PVArealMass_kg_m2"] in["PVFreeStandingSpecificPower_W_kg"]/in["PVSpecificPowerReferenceIrradiance_W_m2"];
  integratedSpecificPowerImpliedEfficiency=in["PVIntegratedFabricArealMass_kg_m2"] in["PVIntegratedSpecificPower_W_kg"]/in["PVSpecificPowerReferenceIrradiance_W_m2"];
  independentPVIrradianceFactor=If[pv["PVInstalledCurvedArea_m2"]>0.,
    pv["IncidentPVPower_W"]/(pv["PVInstalledCurvedArea_m2"] in["PVSpecificPowerReferenceIrradiance_W_m2"]),0.];
  independentMITReferenceEfficiency=Clip[in["MITEfficiencyReference"]*(1.+in["PVEfficiencyTemperatureCoefficient_perK"]*
    (thermal["PVTemperature_K"]-in["PVReferenceTemperature_K"])),{0.,1.}];
  independentIntegratedReferenceEfficiency=Clip[in["PVIntegratedEfficiencyReference"]*(1.+in["PVEfficiencyTemperatureCoefficient_perK"]*
    (thermal["PVTemperature_K"]-in["PVReferenceTemperature_K"])),{0.,1.}];
  independentProjectTargetEfficiency=Clip[in["ProjectTargetEfficiency"]*(1.+in["PVEfficiencyTemperatureCoefficient_perK"]*
    (thermal["PVTemperature_K"]-in["PVReferenceTemperature_K"])),{0.,1.}];
  independentScenarioOutputs=<|
    "MITSpecificPowerLimited"->Min[pv["MITFreeStandingDeviceMass_kg"] in["PVFreeStandingSpecificPower_W_kg"] independentPVIrradianceFactor pv["TotalPVDegradationFactor"],
      pv["IncidentPVPower_W"] independentMITReferenceEfficiency pv["TotalPVDegradationFactor"]],
    "MITIntegratedFabricSpecificPowerLimited"->Min[pv["MITIntegratedFabricDeviceMass_kg"] in["PVIntegratedSpecificPower_W_kg"] independentPVIrradianceFactor pv["TotalPVDegradationFactor"],
      pv["IncidentPVPower_W"] independentIntegratedReferenceEfficiency pv["TotalPVDegradationFactor"]],
    "MITEfficiencyReference"->pv["IncidentPVPower_W"] independentMITReferenceEfficiency pv["TotalPVDegradationFactor"],
    "ProjectSpecifiedTargetEfficiency"->pv["IncidentPVPower_W"] independentProjectTargetEfficiency pv["TotalPVDegradationFactor"]|>;
  pvOutputIndependent=Lookup[independentScenarioOutputs,pv["SelectedScenario"],Missing["ScenarioMismatch"]];
  deliveredPowerIndependent=pvOutputIndependent in["TransferEfficiency"] in["ConditioningEfficiency"];
  inertiaEigenvalues=Eigenvalues[dyn["InertiaTensor_kg_m2"]];
  expectedSubstrateMass=geo["GrossCurvedAreaPerPole_m2"]*
    If[TrueQ[in["PVIntegratedMassIncludesStructuralFabric"] &&
      in["PrimaryPVScenario"]==="MITIntegratedFabricSpecificPowerLimited"],
      1.-in["PVFraction"],1.]*in["MembraneSubstrateArealMass_kg_m2"];
  validation=<|
    "CentralInputSchemaComplete"->TrueQ[Sort[Keys[in]]===Sort[Join[Keys[$Phase1DefaultInputs],$Phase1PoleOperatingKeys]]],
    "SolarLuminosityNominalReferenceConsistencyCheck"->TrueQ[luminosityRelativeDifference<=in["SolarReferenceConsistencyRelativeTolerance"]],
    "SolarGravitationalParameterPositive"->TrueQ[in["SolarGravitationalParameter_m3_s2"]>0.],
    "DerivedSolarMassFromNominalGM_kg"->solarMassDerived,
    "SolarParameterCrossCheckQualification"->"The GM/G mass reconstruction is an algebraic identity. The luminosity/TSI/AU comparison checks internal consistency of nominal reference constants; neither is an independent measurement of solar GM or luminosity.",
    "SolarParameterCrossCheckValues"-><|"NominalSolarGM_m3_s2"->in["SolarGravitationalParameter_m3_s2"],
      "DerivedSolarMass_kg"->solarMassDerived,
      "GMReconstructionResidual_m3_s2"->Abs[in["UniversalGravitationalConstant_m3_kg_s2"] solarMassDerived-in["SolarGravitationalParameter_m3_s2"]],
      "GMReconstructionIsAlgebraicIdentity"->True,
      "LuminosityFromNominalSolarIrradiance_W"->luminosityFromSolarConstant,
      "NominalSolarLuminosity_W"->in["SolarLuminosity_W"],"LuminosityRelativeDifference"->luminosityRelativeDifference,
      "LuminosityComparisonType"->"Consistency of IAU nominal reference constants, not an independent physical measurement."|>,
    "MITSpecificPowerImpliedEfficiency"->pvSpecificPowerImpliedEfficiency,
    "MITIntegratedSpecificPowerImpliedEfficiency"->integratedSpecificPowerImpliedEfficiency,
    "FreeStandingSpecificPowerImpliedEfficiencyDoesNotExceedFreeStandingReference"->TrueQ[
      pvSpecificPowerImpliedEfficiency<=in["MITEfficiencyReference"]+in["PowerLedgerRelativeTolerance"]],
    "IntegratedSpecificPowerImpliedEfficiencyDoesNotExceedIntegratedReference"->TrueQ[
      integratedSpecificPowerImpliedEfficiency<=in["PVIntegratedEfficiencyReference"]+in["PowerLedgerRelativeTolerance"]],
    "PVSpecificPowerReferenceIrradiance_W_m2"->in["PVSpecificPowerReferenceIrradiance_W_m2"],
    "PVSpecificPowerIrradianceScalingIndependentlyRecalculated"->TrueQ[Abs[independentPVIrradianceFactor-pv["SpecificPowerIrradianceScalingFactor"]]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[independentPVIrradianceFactor],Abs[pv["SpecificPowerIrradianceScalingFactor"]]]],
    "PVTechnologyScenarioMassesIndependentlyRecalculated"->TrueQ[
      Abs[pv["MITFreeStandingDeviceMass_kg"]-pv["PVInstalledCurvedArea_m2"] in["PVArealMass_kg_m2"]]<=
        in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[pv["MITFreeStandingDeviceMass_kg"]]] &&
      Abs[pv["MITIntegratedFabricDeviceMass_kg"]-pv["PVInstalledCurvedArea_m2"] in["PVIntegratedFabricArealMass_kg_m2"]]<=
        in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[pv["MITIntegratedFabricDeviceMass_kg"]]]],
    "MITTemperatureAdjustedEfficiencyIndependentRecalculation"->TrueQ[
      Abs[independentMITReferenceEfficiency-pv["EffectiveMITReferenceEfficiency"]]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[independentMITReferenceEfficiency]]],
    "IntegratedPVTemperatureAdjustedEfficiencyIndependentRecalculation"->TrueQ[
      Abs[independentIntegratedReferenceEfficiency-pv["EffectiveIntegratedPVReferenceEfficiency"]]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[independentIntegratedReferenceEfficiency]]],
    "ProjectTargetTemperatureAdjustedEfficiencyIndependentRecalculation"->TrueQ[
      Abs[independentProjectTargetEfficiency-pv["EffectiveProjectTargetEfficiency"]]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[independentProjectTargetEfficiency]]],
    "PVScenarioOutputIndependentRecalculation"->TrueQ[NumericQ[pvOutputIndependent] &&
      Abs[pvOutputIndependent-pv["SelectedDCOutput_W"]]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[pvOutputIndependent]]],
    "ConditionedPowerIndependentRecalculation"->TrueQ[NumericQ[deliveredPowerIndependent] &&
      Abs[deliveredPowerIndependent-power["ConditionedDeliveredPower_W_PerPole"]]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[deliveredPowerIndependent]]],
    "OpticalReflectorEnergyClosure"->TrueQ[Abs[optics["EnergyClosure"]["Reflector"]-1.]<in["OpticalClosureTolerance"]],
    "OpticalPVEnergyClosure"->TrueQ[Abs[optics["EnergyClosure"]["PV"]-1.]<in["OpticalClosureTolerance"]],
    "WholeSurfaceOpticalEnergyConservation"->TrueQ[Abs[rad["OpticalEnergyClosureResidual_W"]]<=in["PowerLedgerRelativeTolerance"] energyScale],
    "PVFractionEnergyLedgerConnected"->TrueQ[Abs[rad["PVIncidentPower_W"]-rad["PVAbsorbedPower_W"]-rad["PVReflectedPower_W"]-rad["PVTransmittedPower_W"]]<=in["PowerLedgerRelativeTolerance"] energyScale],
    "ReflectorEnergyLedgerConnected"->TrueQ[Abs[rad["ReflectorIncidentPower_W"]-rad["ReflectorAbsorbedPower_W"]-rad["ReflectorReflectedPower_W"]-rad["ReflectorTransmittedPower_W"]]<=in["PowerLedgerRelativeTolerance"] energyScale],
    "CoverageRange"->TrueQ[0.<=in["PVFraction"]<=1.],
    "DistancePositive"->TrueQ[in["Distance_m"]>0.],
    "GeometryMeshCurvedAreaConverges"->TrueQ[Abs[mesh["QuadratureAreaRelativeError"]]<in["MeshAreaRelativeTolerance"]],
    "MeshMomentumResolutionConverges"->TrueQ[meshMomentumError<=in["MeshCoefficientCrossCheckTolerance"]],
    "MeshMomentumRelativeDifference"->meshMomentumError,
    "NumericalVsAnalyticMomentumCoefficient"->If[Abs[in["IncidenceAngle_deg"]]<Sqrt[$MachineEpsilon] &&
        Norm[in["InitialAttitudeSmallAngles_rad"]]<Sqrt[$MachineEpsilon],
      TrueQ[coefficientError<=in["MeshCoefficientCrossCheckTolerance"]],Missing["AnalyticFaceOnCheckNotApplicableAtTiltOrAttitude"]],
    "AnalyticFaceOnSpecularMeanCosineSquared"->1.-geo["PlanformEquivalentRadius_m"]^2/(2. geo["GeneratingSphereRadius_m"]^2),
    "MomentumCoefficientRelativeError"->If[Abs[in["IncidenceAngle_deg"]]<Sqrt[$MachineEpsilon] &&
        Norm[in["InitialAttitudeSmallAngles_rad"]]<Sqrt[$MachineEpsilon],coefficientError,Missing["NotApplicableAtTiltOrAttitude"]],
    "RadiationPatchForceIndependentRecalculation"->TrueQ[Norm[independentRadiationForce-rad["NetRadiationForceVector_N"]]<=in["AccelerationCrossCheckRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Norm[independentRadiationForce],Norm[rad["NetRadiationForceVector_N"]]]],
    "RadiationTorqueIndependentRecalculation"->TrueQ[Norm[independentRadiationTorque-rad["NetRadiationMoment_Nm"]]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Norm[independentRadiationTorque],Norm[rad["NetRadiationMoment_Nm"]]]],
    "PatchForceVsMomentumCoefficientCrossCheck"->TrueQ[Norm[independentRadiationForce-fineMeshRadiationForce]<=in["MeshCoefficientCrossCheckTolerance"] Max[Sqrt[$MinMachineNumber],Norm[independentRadiationForce],Norm[fineMeshRadiationForce]]],
    "RadiationForceMassAccelerationCrossCheck"->TrueQ[Norm[independentAccel-mass["NetNaturalAccelerationVector_m_s2"]]<=in["AccelerationCrossCheckRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Norm[independentAccel],Norm[rad["NetRadiationForceVector_N"]/mass["TotalMass_kg"]]]],
    "ArealAndTotalForceAccelerationCrossCheck"->TrueQ[Norm[independentAccel-arealAccel]<=in["AccelerationCrossCheckRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Norm[independentAccel],Norm[arealAccel]]],
    "NaturalVectorEquilibriumAtCurrentInputs"->mass["ExactVectorEquilibrium"],
    "NaturalTorqueEquilibriumAtCurrentInputs"->mass["ExactTorqueEquilibrium"],
    "ExactNaturalEquilibriumAtCurrentInputs"->mass["ExactNaturalEquilibrium"],
    "DistributedGravityIndependentRecalculation"->TrueQ[Norm[gravityForceIndependent-natural["GravityLoads"]["TotalGravityForce_N"]]<=in["AccelerationCrossCheckRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Norm[gravityForceIndependent],Norm[natural["GravityLoads"]["TotalGravityForce_N"]]]],
    "SolarWindForceIndependentRecalculation"->TrueQ[Norm[windForceIndependent-natural["SolarWindLoads"]["TotalForce_N"]]<=in["AccelerationCrossCheckRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Norm[windForceIndependent],Norm[natural["SolarWindLoads"]["TotalForce_N"]]]],
    "SolarWindForceIncludedInEquilibrium"->TrueQ[Norm[independentAccel-natural["NetNaturalAccelerationVector_m_s2"]]<=in["AccelerationCrossCheckRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Norm[independentAccel],Norm[natural["NetNaturalAccelerationVector_m_s2"]]]],
    "NaturalTorqueIndependentRecalculation"->TrueQ[Norm[independentTorque-natural["NetNaturalTorqueAboutCOM_Nm"]]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Norm[independentTorque],Norm[natural["NetNaturalTorqueAboutCOM_Nm"]]]],
    "EquilibriumRequiresMassAndVectorResidual"->TrueQ[!mass["ExactNaturalEquilibrium"] || (mass["MassFeasible"] && mass["ExactVectorEquilibrium"] && mass["ExactTorqueEquilibrium"])],
    "PVTemperatureIndependentRecalculation"->TrueQ[Abs[independentPVTemp-thermal["PVTemperature_K"]]<=in["ThermalResidualRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[independentPVTemp]]],
    "ReflectorTemperatureIndependentRecalculation"->TrueQ[Abs[independentRefTemp-thermal["ReflectorTemperature_K"]]<=in["ThermalResidualRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[independentRefTemp]]],
    "PVThermalBalanceResidual"->TrueQ[Abs[thermal["PVThermalBalanceResidual_W_m2"]]<in["ThermalResidualRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[thermal["PVMeanAbsorbedHeatFlux_W_m2"]]]],
    "PVThermalCouplingConverged"->TrueQ[thermal["PVThermalCouplingConverged"]],
    "ReflectorThermalBalanceResidual"->TrueQ[Abs[thermal["ReflectorThermalBalanceResidual_W_m2"]]<in["ThermalResidualRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[thermal["ReflectorMeanAbsorbedHeatFlux_W_m2"]]]],
    "AllThermalLimitsWithinBounds"->thermal["AllThermalLimitsWithinBounds"],
    "PVOutputBelowAbsorbedEnergy"->pv["PVOutputDoesNotExceedAbsorbedPower"],
    "PVSpecificPowerCapApplied"->pv["PVOutputDoesNotExceedSpecificPower"],
    "PVMassConsistentAcrossMassAndPowerLedgers"->TrueQ[Abs[mass["PVMass_kg"]-pv["PVDeviceMass_kg"]]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[mass["PVMass_kg"]]]],
    "TransferAndConditioningConnected"->TrueQ[Abs[power["ConditionedDeliveredPower_W"]-power["PVDirectCurrent_W"] in["TransferEfficiency"] in["ConditioningEfficiency"]]<in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[power["PVDirectCurrent_W"]]]],
    "StationMassCountedOnce"->TrueQ[Abs[mass["StationMassTotal_kg"]-in["ICARUSStationCount"] in["ICARUSStationMass_kg"]]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[mass["StationMassTotal_kg"]]] && Abs[dyn["StationMassTotal_kg"]-mass["StationMassTotal_kg"]]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[mass["StationMassTotal_kg"]]]],
    "PerimeterHardwareMassIncludedInMassLedger"->TrueQ[Abs[mass["PerimeterHardwareMass_kg"]-geo["PlanformPerimeter_m"] in["PerimeterHardwareLinearMass_kg_m"]]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[mass["PerimeterHardwareMass_kg"]]] && mass["PerimeterHardwareMass_kg"]==dyn["PerimeterHardwareMass_kg"] && Abs[dyn["MassConservationResidual_kg"]]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[mass["TotalMass_kg"]]]],
    "MembraneSubstrateIncludedInMassLedger"->TrueQ[
      Abs[mass["MembraneSubstrateMass_kg"]-expectedSubstrateMass]<=
        in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[expectedSubstrateMass]]],
    "ExpectedMembraneSubstrateMass_kg"->expectedSubstrateMass,
    "TotalMassComponentLedgerCloses"->TrueQ[Abs[massComponentResidual]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[mass["TotalMass_kg"]]]],
    "InertiaTensorPositive"->TrueQ[Min[inertiaEigenvalues]>0.],
    "InertiaTensorEigenvalues_kg_m2"->inertiaEigenvalues,
    "DistributedMassConservation"->TrueQ[Abs[dyn["MassConservationResidual_kg"]]<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[mass["TotalMass_kg"]]]],
    "CenterOfMassFinite"->TrueQ[VectorQ[dyn["CenterOfMassLocal_m"],NumericQ]],
    "QuaternionNormalized"->TrueQ[Abs[qNorm-1.]<in["QuaternionNormalizationTolerance"]],
    "ICARUSWrenchMatrixFullRank"->TrueQ[MatrixRank[wrench]==6],
    "StructuralScreenCalculated"->TrueQ[NumericQ[structure["DeflectionFractionOfRadius"]]],
    "AllSelectedModelFormInputsSupported"->Module[{modelChecks=phase1InputChecks[in],modelKeys},
      modelKeys={"PVLayoutModelSupported","GeometryProfileModelSupported","MassDistributionModelSupported",
        "FlareTemporalProfileSupported","CMETemporalProfileSupported","HeliocentricReferenceMotionModeSupported",
        "ICARUSLoadTransferModelSupported","MembraneStructuralModelSupported","WobbleRestoringModelSupported",
        "ICARUSStationCountScopeSupported"};
      TrueQ[AssociationQ[modelChecks] && And@@(TrueQ[Lookup[modelChecks,#,False]]&/@modelKeys)]],
    "ICARUSCapacityUserInputNumeric"->TrueQ[NumericQ[in["ICARUSStationForceCapacity_N"]]]
  |>;
  validation
];

(* ========================================================================
   4. PUBLIC CALCULATION ACCESSORS — read central output store
   ======================================================================== *)

phase1EnsureCalculated[] := Module[{results=phase1RawResults[],run=Lookup[$Phase1State,"LastRun",Missing["NotRun"]],
  currentInputs=Phase1GetInputs[],requiredResults},
  requiredResults={"InputValidation","LocalRadiation","MassBalance","Thermal","PVPerformance","PowerLedger",
    "MissionEndPerformance","StructuralScreen","DynamicInitialConditions","ICARUSWrenchMatrix",
    "ICARUSCapacityPerStation_N","ICARUSZeroCommandAllocation","ICARUSInitialLoadMap",
    "ICARUSWrenchAllocatorCrossCheck","ICARUSLoadMapCrossCheck","DisturbanceInputs","NaturalEquilibrium","Validation"};
  If[Lookup[$Phase1State,"SchemaVersion",""]  =!= "11.9" || !AssociationQ[run] || !KeyExistsQ[run,"CalculationManifest"] ||
      Lookup[run,"InputSnapshot",Missing["NoInputSnapshot"]]=!=currentInputs ||
      Lookup[run,"InputSnapshotHash",Missing["NoInputHash"]]=!=Hash[currentInputs,"SHA256"] ||
      !And@@(KeyExistsQ[results,#]&/@requiredResults) ||
      !And@@(KeyExistsQ[$Phase1State["Derived"],#]&/@{"Geometry","SurfaceMesh","InitialAttitudeSurfaceMesh","OpticalRegister","SunVector","Illumination"}),
    results=Phase1ComputeAll[]
  ];
  results
];

Phase1LocalSurfaceMesh[] := Module[{results=phase1EnsureCalculated[]},If[FailureQ[results],results,Phase1GetState[]["Derived"]["SurfaceMesh"]]];
Phase1LocalRadiationLoads[] := Module[{results=phase1EnsureCalculated[]},If[FailureQ[results],results,Phase1GetResult["LocalRadiation"]]];
Phase1MassBalance[] := Module[{results=phase1EnsureCalculated[]},If[FailureQ[results],results,Phase1GetResult["MassBalance"]]];
Phase1ThermalScreen[] := Module[{results=phase1EnsureCalculated[]},If[FailureQ[results],results,Phase1GetResult["Thermal"]]];
Phase1PowerLedger[] := Module[{results=phase1EnsureCalculated[]},If[FailureQ[results],results,Phase1GetResult["PowerLedger"]]];
Phase1DynamicInitialConditions[] := Module[{results=phase1EnsureCalculated[]},If[FailureQ[results],results,Phase1GetResult["DynamicInitialConditions"]]];


(* ========================================================================
   5. INDEPENDENT NUMERICAL SOLVES AND OPTIMIZATION
   ======================================================================== *)

phase1SolveExactEquilibriumCurrent[] := Module[
  {in=Phase1GetInputs[],geo,mesh,optics,sun,coeff,lo,hi,seed,root,ff,rad,mass,fn,result,lowResidual,highResidual,dyn,meshAtt,natural,candidate},
  If[!phase1InputChecksPass[phase1InputChecks[in]],Return[Failure["InvalidPhase1Inputs",<|"Checks"->phase1InputChecks[in]|>]]];
  geo=phase1Geometry[in];mesh=phase1Mesh[in,geo,in["OptimizerMeshRadialCount"],in["OptimizerMeshAzimuthCount"]];
  optics=phase1Optics[in];sun=phase1SunVector[in["IncidenceAngle_deg"]];
  coeff=phase1MaterialMomentumCoefficients[mesh,sun,optics];
  lo=in["PVSearchRange"][[1]];hi=in["PVSearchRange"][[2]];
  seed=Clip[in["PVFraction"],{lo,hi}];
  fn[x_?NumericQ] := Module[{trialCandidate=phase1NaturalCandidateAt[in,geo,mesh,optics,x,in["Distance_m"]]},
    trialCandidate["Natural"]["NetNaturalAccelerationVector_m_s2"][[1]] /
      (in["SolarGravitationalParameter_m3_s2"]/in["Distance_m"]^2)
  ];
  lowResidual=fn[lo];highResidual=fn[hi];
  root=Quiet@Check[FindRoot[fn[ff]==0.,{ff,seed,lo,hi},Method->"Brent",WorkingPrecision->in["NumericalWorkingPrecision"]],$Failed];
  If[root===$Failed,
    result=<|"Status"->"No radial equilibrium root found within the configured PV coverage range.",
      "Root"->Missing["NoRoot"],"PVFractionSearchBounds"->{lo,hi},
      "NetRadialAccelerationAtLowerCoverage_m_s2"->lowResidual,
      "NetRadialAccelerationAtUpperCoverage_m_s2"->highResidual,
      "EndpointResidualsBracketRoot"->TrueQ[lowResidual highResidual<=0.],
      "Interpretation"->"The selected PV technology, areal masses, optical momentum coefficient and station mass do not produce a radial equilibrium root within the allowed coverage interval."|>,
    ff=ff/.root;candidate=phase1NaturalCandidateAt[in,geo,mesh,optics,ff,in["Distance_m"]];
    rad=candidate["Radiation"];mass=candidate["Mass"];dyn=candidate["Dynamics"];
    meshAtt=candidate["AttitudeMesh"];natural=candidate["Natural"];
    result=<|"Status"->If[mass["ExactNaturalEquilibrium"],"Natural force and torque equilibrium found within user-supplied tolerances.","A one-dimensional PV-coverage radial root was found, but exact vector-force and/or torque equilibrium failed; it remains diagnostic only."],
      "InputSnapshot"->in,"OptimizerMeshResolution"->mesh["MeshResolution"],
      "MomentumCoefficients"->coeff,"PVFraction"->ff,"MassBalance"->mass,"NaturalEquilibrium"->natural,
      "ExactNaturalEquilibrium"->mass["ExactNaturalEquilibrium"],"RootRule"->root|>
  ];
  phase1StoreResult["ExactEquilibriumSolve",result]
];

phase1DistanceThermalFloorCurrent[coverage_:Automatic] := Module[
  {in=Phase1GetInputs[],f,geo,mesh,optics,sun,illum,sides,pvCoeff,refCoeff,pvRoot,refRoot,numericPV,numericRef,x,
   pvLimit,refLimit,pvEps,refEps,pvFloor,refFloor,limiting,rad0,mass0,dyn0,meshAtt},
  If[!phase1InputChecksPass[phase1InputChecks[in]],Return[Failure["InvalidPhase1Inputs",<|"Checks"->phase1InputChecks[in]|>]]];
  f=If[coverage===Automatic,in["PVFraction"],coverage];
  If[!TrueQ[NumericQ[f] && 0.<=f<=1.],Return[Failure["InvalidThermalCoverage",<|"PVFraction"->f|>]]];
  geo=phase1Geometry[in];mesh=phase1Mesh[in,geo,in["OptimizerMeshRadialCount"],in["OptimizerMeshAzimuthCount"]];
  optics=phase1Optics[in];sun=phase1SunVector[in["IncidenceAngle_deg"]];
  rad0=phase1Radiation[in,geo,mesh,optics,f,in["Distance_m"],in["IncidenceAngle_deg"],sun];
  mass0=phase1Mass[in,geo,rad0,f,in["Distance_m"]];dyn0=phase1DynamicsInitial[in,geo,mass0,mesh];
  meshAtt=phase1RotateMeshToCOM[mesh,dyn0["CenterOfMassLocal_m"],dyn0["InitialQuaternion"]];
  illum=phase1Illumination[meshAtt,sun];
  sides=If[TrueQ[in["BothSidesRadiate"]],2.,1.];
  pvLimit=in["PVTemperatureLimit_K"];refLimit=in["ReflectorTemperatureLimit_K"];
  pvEps=in["PVIRemissivity"];refEps=in["ReflectorIRemissivity"];
  pvCoeff=optics["PV"]["A"] in["SolarLuminosity_W"] illum["IlluminationWeightedProjectedArea_m2"]/(4. Pi geo["GrossCurvedAreaPerPole_m2"]);
  refCoeff=optics["Reflector"]["A"] in["SolarLuminosity_W"] illum["IlluminationWeightedProjectedArea_m2"]/(4. Pi geo["GrossCurvedAreaPerPole_m2"]);
  pvRoot=If[f>0.,Sqrt[pvCoeff/(sides pvEps in["StefanBoltzmann_W_m2_K4"] pvLimit^4)],0.];
  refRoot=If[f<1.,Sqrt[refCoeff/(sides refEps in["StefanBoltzmann_W_m2_K4"] refLimit^4)],0.];
  numericPV=If[pvRoot>0.,Quiet@Check[FindRoot[pvCoeff/x^2==sides pvEps in["StefanBoltzmann_W_m2_K4"] pvLimit^4,{x,pvRoot},WorkingPrecision->in["NumericalWorkingPrecision"]],$Failed],$Failed];
  numericRef=If[refRoot>0.,Quiet@Check[FindRoot[refCoeff/x^2==sides refEps in["StefanBoltzmann_W_m2_K4"] refLimit^4,{x,refRoot},WorkingPrecision->in["NumericalWorkingPrecision"]],$Failed],$Failed];
  pvFloor=If[pvRoot==0.,0.,If[numericPV===$Failed,pvRoot,x/.numericPV]];
  refFloor=If[refRoot==0.,0.,If[numericRef===$Failed,refRoot,x/.numericRef]];
  limiting=If[pvFloor>=refFloor,"PV", "Reflector"];
  phase1StoreResult["ThermalDistanceFloor",<|"PVFractionUsed"->f,"MinimumDistance_m"->Max[pvFloor,refFloor],
    "MinimumDistance_AU"->Max[pvFloor,refFloor]/in["AstronomicalUnit_m"],
    "PVMinimumDistance_m"->pvFloor,"ReflectorMinimumDistance_m"->refFloor,
    "LimitingThermalSubsystem"->limiting,
    "PVAnalyticDistance_m"->pvRoot,"ReflectorAnalyticDistance_m"->refRoot,
    "PVFindRootResult"->numericPV,"ReflectorFindRootResult"->numericRef,
    "TemperatureLimitPV_K"->pvLimit,"TemperatureLimitReflector_K"->refLimit,
    "Qualification"->"Both material-specific thermal boundaries use local-normal illumination and separate infrared emissivity. The larger distance is the operating floor."|>]
];

phase1EvaluateCandidateTransient[distance_?NumericQ,coverage_?NumericQ,preChecks_Association:<||>] := Module[
  {liveState=$Phase1State,candidateInputs,candidateProvenance,candidateState,core,dynamicRun,
   dynamicSummary,checks,accepted,temporaryResult,noLeak,candidatePoleInputs,candidatePoleProvenance},
  If[!TrueQ[$Phase1ExecutingPole],
    Return[Failure["CandidateEvaluationRequiresPoleContext",<|"Reason"->"A candidate must be evaluated inside one pole's isolated execution context."|>]]];
  candidateInputs=Join[Phase1GetInputs[],<|"Distance_m"->distance,"PVFraction"->coverage|>];
  candidateProvenance=Join[Lookup[$Phase1State,"InputNotes",<||>],<|
    "Distance_m"->"Transient Mathematica optimizer candidate calculated from this pole's input snapshot; not a user-supplied value and not retained.",
    "PVFraction"->"Transient Mathematica optimizer candidate calculated from this run's independent pole optimizations; not retained in the common design register."|>];
  candidatePoleInputs=Join[Lookup[Lookup[$Phase1State,"PoleOperatingInputs",<||>],$Phase1CurrentPole,<||>],<|"Distance_m"->distance|>];
  candidatePoleProvenance=Join[Lookup[Lookup[$Phase1State,"PoleOperatingNotes",<||>],$Phase1CurrentPole,<||>],<|
    "Distance_m"->("Transient optimizer candidate local to "<>ToString[$Phase1CurrentPole]<>
      "; calculated by Mathematica, used only in this temporary isolated evaluation, and not retained.")|>];
  candidateState=Join[$Phase1State,<|"Inputs"->candidateInputs,"InputNotes"->candidateProvenance,
    "PoleOperatingInputs"-><|$Phase1CurrentPole->candidatePoleInputs|>,
    "PoleOperatingNotes"-><|$Phase1CurrentPole->candidatePoleProvenance|>,
    "Derived"-><||>,"Results"-><||>,"LastRun"->Missing["TransientCandidateRequiresFullRecalculation"]|>];
  temporaryResult=Block[{$Phase1State=candidateState},
    core=Phase1ComputeAll[];
    If[FailureQ[core],
      <|"CandidateEvaluatedTransiently"->True,"CandidateEvaluationPole"->$Phase1CurrentPole,
        "CandidateDistance_m"->distance,"CandidatePVFraction"->coverage,
        "CandidateCoreRecalculation"->core,
        "DynamicSimulation"->Missing["NotRunCoreRecalculationFailed"],
        "AcceptanceChecks"->Join[preChecks,<|"TransientCoreRecalculation"->False|>],
        "ModelledAcceptanceUnderAssumptions"->False,"CandidateAppliedToCentralInputs"->False,
        "CandidateInputsRetained"->False,"CandidateInputSnapshot"->candidateInputs,
        "CandidateInputProvenanceSnapshot"->candidateProvenance,
        "Status"->"Transient core recalculation failed; no dynamic acceptance is claimed."|>,
      dynamicRun=Phase1IntegratedSimulation[];
      dynamicSummary=If[AssociationQ[dynamicRun],KeyDrop[dynamicRun,"Solution"],dynamicRun];
      checks=Join[preChecks,<|
        "TransientCoreRecalculation"->True,
        "MassLedgerCloses"->TrueQ[Lookup[Lookup[core,"MassBalance",<||>],"MassLedgerCloses",False]],
        "NaturalVectorEquilibrium"->TrueQ[Lookup[Lookup[core,"NaturalEquilibrium",<||>],"ExactVectorEquilibrium",False]],
        "NaturalTorqueEquilibrium"->TrueQ[Lookup[Lookup[core,"NaturalEquilibrium",<||>],"ExactTorqueEquilibrium",False]],
        "ExactNaturalEquilibrium"->TrueQ[Lookup[Lookup[core,"NaturalEquilibrium",<||>],"ExactNaturalEquilibrium",False]],
        "ThermalLimits"->TrueQ[Lookup[Lookup[core,"Thermal",<||>],"AllThermalLimitsWithinBounds",False]],
        "PVThermalCouplingConverged"->TrueQ[Lookup[Lookup[core,"Validation",<||>],"PVThermalCouplingConverged",False]],
        "StaticStructuralScreen"->TrueQ[Lookup[Lookup[core,"StructuralScreen",<||>],"StructuralScreenPass",False]],
        "DynamicIntegration"->(AssociationQ[dynamicRun]&&KeyExistsQ[dynamicRun,"Solution"]&&dynamicRun["Solution"] =!= $Failed),
        "BaseAccelerationConsistency"->If[AssociationQ[dynamicRun],TrueQ[Lookup[dynamicRun,"BaseAccelerationConsistencyRelativeError",Infinity]<=candidateInputs["AccelerationCrossCheckRelativeTolerance"]],False],
        "QuaternionNormalization"->If[AssociationQ[dynamicRun],TrueQ[Lookup[dynamicRun,"MaximumQuaternionNormalizationError",Infinity]<=candidateInputs["QuaternionNormalizationTolerance"]],False],
        "RadialStability"->If[AssociationQ[dynamicRun],TrueQ[Lookup[dynamicRun,"RadialDeviationWithinLimit",False]],False],
        "LateralStability"->If[AssociationQ[dynamicRun],TrueQ[Lookup[dynamicRun,"LateralDeviationWithinLimit",False]],False],
        "AttitudeStability"->If[AssociationQ[dynamicRun],TrueQ[Lookup[dynamicRun,"AttitudeWithinLimit",False]],False],
        "ICARUSCapacity"->If[AssociationQ[dynamicRun],TrueQ[Lookup[dynamicRun,"ICARUSWithinCapacity",False]],False],
        "DynamicLoadMapForceAndMomentConserved"->If[AssociationQ[dynamicRun],TrueQ[Lookup[dynamicRun,"DynamicLoadMapForceAndMomentConserved",False]],False],
        "DynamicStructuralLoadScreen"->If[AssociationQ[dynamicRun],TrueQ[Lookup[dynamicRun,"DynamicStructuralLoadScreenPass",False]],False],
        "RecoveryTime"->If[AssociationQ[dynamicRun],TrueQ[Lookup[dynamicRun,"RecoveryWithinLimit",False]],False]|>];
      accepted=And@@(TrueQ/@Values[checks]);
      <|"CandidateEvaluatedTransiently"->True,"CandidateEvaluationPole"->$Phase1CurrentPole,
        "CandidateDistance_m"->distance,"CandidatePVFraction"->coverage,
        "CandidateCoreRecalculation"->KeyDrop[core,"CalculationManifest"],
        "DynamicSimulation"->dynamicSummary,"AcceptanceChecks"->checks,
        "ModelledAcceptanceUnderAssumptions"->accepted,
        "CandidateAppliedToCentralInputs"->False,"CandidateInputsRetained"->False,
        "CandidateInputSnapshot"->candidateInputs,"CandidateInputProvenanceSnapshot"->candidateProvenance,
        "Status"->If[accepted,"Candidate passed the static and dynamic model gates in a temporary per-pole snapshot; live inputs were not modified.",
          "Candidate failed one or more static or dynamic gates in a temporary per-pole snapshot; live inputs were not modified."]|>
    ]
  ];
  noLeak=SameQ[$Phase1State,liveState];
  checks=Join[Lookup[temporaryResult,"AcceptanceChecks",<||>],<|"NoLivePoleStateMutation"->noLeak|>];
  accepted=TrueQ[Lookup[temporaryResult,"ModelledAcceptanceUnderAssumptions",False]]&&TrueQ[noLeak];
  Join[temporaryResult,<|"AcceptanceChecks"->checks,"ModelledAcceptanceUnderAssumptions"->accepted,
    "NoLivePoleStateMutation"->noLeak,"CandidateAppliedToCentralInputs"->False,
    "CandidateInputsRetained"->False|>]
];

phase1JointOptimizationCurrent[] := Module[
  {in=Phase1GetInputs[],inProvenance,computed,geo,mesh,optics,sun,coeff,illum,loF,hiF,loR,hiR,
   full,screen,rr,ff,radCandidate,massCandidate,thermalCandidate,pvCandidate,powerCandidate,
   structureCandidate,capacity,fullFeasible,dynamicAccepted,results,candidateEvaluation,
   validOptimizationResultQ,gridDistancePoints,gridCoveragePoints,gridRecords,
   gridFeasibleRecords,gridBest,gridCrossCheckPass,gridConstraintCrossCheckPass,gridConstraintViolations,
   fullCandidateDistance,fullCandidateCoverage,tempFloorResult,exactEquilibriumCheck,
   candidateBisectionRoot,candidateFindRoot,candidateRootCrossCheck,candidateRootResidual,
   optimizerMassCheck,optimizerPowerCheck,optimizerPowerResidual,optimizerThermalCheck,optimizerStructuralCheck,
   structuralFloorResult,lowerDistance,gridTolerance,naturalStateAt,performanceStateAt,thermalStateAt,structuralStateAt,
   forceMargin,torqueMargin,pvTemperatureMargin,reflectorTemperatureMargin,deflectionMargin,
   stressMargin,pretensionMargin,structuralModelGate,thermalOK,structOK,equilibriumOK,objective,
   candidateFeasibleQ,candidateMassResidual,rootSymbol,selectedCandidate,rootAtCandidate,
   candidateState,dynCandidate,meshCandidate,naturalCandidate,independentAcceleration,residualScale,
   objectiveAtCandidate},
  computed=phase1EnsureCalculated[];
  If[FailureQ[computed],Return[computed]];
  in=Phase1GetInputs[];inProvenance=Lookup[$Phase1State,"InputNotes",<||>];
  exactEquilibriumCheck=Phase1SolveExactEquilibrium[];
  If[FailureQ[exactEquilibriumCheck],Return[exactEquilibriumCheck]];
  geo=phase1Geometry[in];mesh=phase1Mesh[in,geo,in["OptimizerMeshRadialCount"],in["OptimizerMeshAzimuthCount"]];
  optics=phase1Optics[in];sun=phase1SunVector[in["IncidenceAngle_deg"]];
  coeff=phase1MaterialMomentumCoefficients[mesh,sun,optics];illum=phase1Illumination[mesh,sun];
  loF=in["PVSearchRange"][[1]];hiF=in["PVSearchRange"][[2]];
  loR=in["DistanceSearchRange_m"][[1]];hiR=in["DistanceSearchRange_m"][[2]];
  (* Candidate functions are memoized by both independent optimizer variables. *)
  naturalStateAt[r_?NumericQ,f_?NumericQ] := naturalStateAt[r,f]=
    phase1NaturalCandidateAt[in,geo,mesh,optics,f,r];
  performanceStateAt[r_?NumericQ,f_?NumericQ] := performanceStateAt[r,f]=Module[{candidate=naturalStateAt[r,f],coupled},
    coupled=phase1CoupledPVThermal[candidate["Inputs"],geo,candidate["AttitudeMesh"],optics,candidate["Radiation"],f,r,0.];
    If[FailureQ[coupled],
      <|"Thermal"-><|"PVTemperature_K"->Infinity,"ReflectorTemperature_K"->Infinity,
          "AllThermalLimitsWithinBounds"->False,"PVThermalCouplingConverged"->False|>,
        "PVPerformance"-><|"SelectedDCOutput_W"->0.,"PVOutputDoesNotExceedAbsorbedPower"->False,
          "PVOutputDoesNotExceedSpecificPower"->False|>,"ConvergenceFailure"->coupled|>,coupled]];
  thermalStateAt[r_?NumericQ,f_?NumericQ] := performanceStateAt[r,f]["Thermal"];
  structuralStateAt[r_?NumericQ,f_?NumericQ] := structuralStateAt[r,f]=Module[{candidate=naturalStateAt[r,f]},
    phase1Structural[candidate["Inputs"],geo,candidate["Radiation"],f]];
  forceMargin[r_?NumericQ,f_?NumericQ] := in["ExactEquilibriumAccelerationTolerance_m_s2"]-
    naturalStateAt[r,f]["Natural"]["NaturalForceResidualMagnitude_m_s2"];
  torqueMargin[r_?NumericQ,f_?NumericQ] := in["ExactEquilibriumTorqueTolerance_Nm"]-
    naturalStateAt[r,f]["Natural"]["NaturalTorqueResidualMagnitude_Nm"];
  pvTemperatureMargin[r_?NumericQ,f_?NumericQ] := in["PVTemperatureLimit_K"]-thermalStateAt[r,f]["PVTemperature_K"];
  reflectorTemperatureMargin[r_?NumericQ,f_?NumericQ] := in["ReflectorTemperatureLimit_K"]-
    thermalStateAt[r,f]["ReflectorTemperature_K"];
  deflectionMargin[r_?NumericQ,f_?NumericQ] := structuralStateAt[r,f]["DeflectionMargin"];
  stressMargin[r_?NumericQ,f_?NumericQ] := structuralStateAt[r,f]["TensileStressMargin_Pa"];
  pretensionMargin[r_?NumericQ,f_?NumericQ] := structuralStateAt[r,f]["PretensionCapacityMargin_N_m"];
  structuralModelGate[r_?NumericQ,f_?NumericQ] := If[TrueQ[structuralStateAt[r,f]["StructuralScreenPass"]],1.,-1.];
  thermalOK[r_?NumericQ,f_?NumericQ] := TrueQ[thermalStateAt[r,f]["AllThermalLimitsWithinBounds"]];
  structOK[r_?NumericQ,f_?NumericQ] := TrueQ[structuralStateAt[r,f]["StructuralScreenPass"]];
  equilibriumOK[r_?NumericQ,f_?NumericQ] := TrueQ[forceMargin[r,f]>=0. && torqueMargin[r,f]>=0.];
  candidateFeasibleQ[r_?NumericQ,f_?NumericQ] := TrueQ[
    loR<=r<=hiR && loF<=f<=hiF && equilibriumOK[r,f] && thermalOK[r,f] && structOK[r,f] &&
    TrueQ[performanceStateAt[r,f]["PVPerformance"]["PVOutputDoesNotExceedAbsorbedPower"]] &&
    TrueQ[performanceStateAt[r,f]["PVPerformance"]["PVOutputDoesNotExceedSpecificPower"]]];
  objective[r_?NumericQ,f_?NumericQ] := Module[{candidate,thermal,pv,power},
    candidate=naturalStateAt[r,f];thermal=thermalStateAt[r,f];
    pv=performanceStateAt[r,f]["PVPerformance"];
    power=phase1Power[candidate["Inputs"],pv];power["ConditionedDeliveredPower_W_PerPole"]
  ];
  (* The thermal and structural floors at the current coverage are reported as diagnostics only;
     candidate-specific calculated margins below are the actual optimization constraints. *)
  tempFloorResult=Phase1DistanceThermalFloor[];
  structuralFloorResult=phase1StructuralDistanceFloor[in,geo,mesh,optics,in["PVFraction"]];
  full=Quiet@Check[NMaximize[
    {objective[r,f],
      loR<=r<=hiR && loF<=f<=hiF && forceMargin[r,f]>=0. && torqueMargin[r,f]>=0. &&
      pvTemperatureMargin[r,f]>=0. && reflectorTemperatureMargin[r,f]>=0. &&
      deflectionMargin[r,f]>=0. && stressMargin[r,f]>=0. && pretensionMargin[r,f]>=0. &&
      structuralModelGate[r,f]>=0.},
    {r,f},MaxIterations->in["OptimizerMaxIterations"],
    WorkingPrecision->in["NumericalWorkingPrecision"]],$Failed];
  gridDistancePoints=Subdivide[loR,hiR,in["OptimizerGridPointCount"]];
  gridCoveragePoints=Subdivide[loF,hiF,in["OptimizerCoverageGridPointCount"]];
  gridRecords=Flatten[Table[
    With[{rr0=dr,ff0=fc},
      {If[candidateFeasibleQ[rr0,ff0],objective[rr0,ff0],-Infinity],rr0,ff0,
       candidateFeasibleQ[rr0,ff0]}],
    {dr,gridDistancePoints},{fc,gridCoveragePoints}],1];
  gridFeasibleRecords=Select[gridRecords,TrueQ[#[[4]]]&];
  gridConstraintViolations=Select[gridRecords,Not@TrueQ[#[[4]]]&];
  gridConstraintCrossCheckPass=(Length[gridFeasibleRecords]>0);
  gridBest=If[gridConstraintCrossCheckPass,First@MaximalBy[gridFeasibleRecords,First],Missing["NoGridFeasiblePoint"]];
  validOptimizationResultQ[res_] := Module[{candR,candF},
    If[!ListQ[res] || Length[res]!=2 || !ListQ[res[[2]]],Return[False]];
    candR=Quiet@Check[N[r/.res[[2]]],Indeterminate];candF=Quiet@Check[N[f/.res[[2]]],Indeterminate];
    TrueQ[NumericQ[res[[1]]] && -Infinity<res[[1]]<Infinity && NumericQ[candR] && NumericQ[candF] &&
      candidateFeasibleQ[candR,candF]]
  ];
  If[validOptimizationResultQ[full],
    fullCandidateDistance=N[r/.full[[2]]];fullCandidateCoverage=N[f/.full[[2]]],
    fullCandidateDistance=Missing["NoCandidate"];fullCandidateCoverage=Missing["NoCandidate"]];
  gridTolerance=If[gridConstraintCrossCheckPass,
    in["OptimizerGridCrossCheckRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[gridBest[[1]]],
      Abs[If[NumericQ[fullCandidateDistance]&&NumericQ[fullCandidateCoverage],objective[fullCandidateDistance,fullCandidateCoverage],0.]]],Infinity];
  gridCrossCheckPass=If[validOptimizationResultQ[full]&&gridConstraintCrossCheckPass,
    TrueQ[objective[fullCandidateDistance,fullCandidateCoverage]+gridTolerance>=gridBest[[1]]],False];
  (* A coarse grid candidate is diagnostic only; it is never promoted to an accepted optimizer result. *)
  selectedCandidate=If[validOptimizationResultQ[full],full,
    If[gridConstraintCrossCheckPass,{gridBest[[1]],{r->gridBest[[2]],f->gridBest[[3]]}},$Failed]];
  If[!ListQ[selectedCandidate],
    results=<|"Status"->"No candidate satisfies the exact natural force/torque, thermal and structural constraints within the configured distance and PV-coverage intervals.",
      "FullConstraintOptimization"->full,"IndependentFeasibleGridBest"->gridBest,
      "GridConstraintCrossCheck"->gridConstraintCrossCheckPass,
      "ThermalDistanceFloorAtCurrentCoverage"->tempFloorResult,
      "StructuralDistanceFloorAtCurrentCoverage"->structuralFloorResult,
      "DistanceSearchRange_m"->{loR,hiR},"PVSearchRange"->{loF,hiF},
      "ExactNaturalEquilibrium"->False,"StaticConstraintProblemFeasible"->False,
      "DynamicCandidateAcceptancePassed"->False,"FullConstraintProblemFeasible"->False|>;
    $Phase1State=Join[$Phase1State,<|"Results"->Join[$Phase1State["Results"],<|"JointOptimization"->results|>]|>];
    phase1Audit["JointOptimizationNoFeasibleCandidate",results];Return[results]
  ];
  rr=N[r/.selectedCandidate[[2]]];ff=N[f/.selectedCandidate[[2]]];
  candidateState=naturalStateAt[rr,ff];radCandidate=candidateState["Radiation"];
  massCandidate=candidateState["Mass"];dynCandidate=candidateState["Dynamics"];
  meshCandidate=candidateState["AttitudeMesh"];naturalCandidate=candidateState["Natural"];
  thermalCandidate=thermalStateAt[rr,ff];pvCandidate=performanceStateAt[rr,ff]["PVPerformance"];
  powerCandidate=phase1Power[candidateState["Inputs"],pvCandidate];structureCandidate=structuralStateAt[rr,ff];
  independentAcceleration=(radCandidate["NetRadiationForceVector_N"]+
    naturalCandidate["GravityLoads"]["TotalGravityForce_N"]+naturalCandidate["SolarWindLoads"]["TotalForce_N"])/massCandidate["TotalMass_kg"];
  residualScale=Max[Sqrt[$MinMachineNumber],Norm[independentAcceleration],
    Norm[naturalCandidate["NetNaturalAccelerationVector_m_s2"]]];
  optimizerMassCheck=TrueQ[massCandidate["MassLedgerCloses"] &&
    Norm[independentAcceleration-naturalCandidate["NetNaturalAccelerationVector_m_s2"]]<=
      in["AccelerationCrossCheckRelativeTolerance"] residualScale];
  objectiveAtCandidate=objective[rr,ff];
  optimizerPowerResidual=Abs[objectiveAtCandidate-powerCandidate["ConditionedDeliveredPower_W_PerPole"]];
  optimizerPowerCheck=TrueQ[optimizerPowerResidual<=in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[pvCandidate["SelectedDCOutput_W"]]]];
  optimizerThermalCheck=TrueQ[TrueQ[thermalOK[rr,ff]]===TrueQ[thermalCandidate["AllThermalLimitsWithinBounds"]]];
  optimizerStructuralCheck=TrueQ[TrueQ[structOK[rr,ff]]===TrueQ[structureCandidate["StructuralScreenPass"]]];
  (* Independent bisection and FindRoot checks of the radial mass-balance coverage root at the selected distance. *)
  candidateMassResidual[z_?NumericQ] := naturalStateAt[rr,z]["Natural"]["NetNaturalAccelerationVector_m_s2"][[1]]/
    (in["SolarGravitationalParameter_m3_s2"]/rr^2);
  candidateBisectionRoot=phase1BracketedBisection[candidateMassResidual,{loF,hiF},
    in["ExactEquilibriumRelativeTolerance"],in["OptimizerMaxIterations"]];
  candidateFindRoot=Quiet@Check[FindRoot[candidateMassResidual[rootSymbol]==0.,
    {rootSymbol,ff,loF,hiF},Method->"Brent",WorkingPrecision->in["NumericalWorkingPrecision"]],$Failed];
  rootAtCandidate=If[candidateFindRoot===$Failed,Missing["FindRootFailed"],N[rootSymbol/.candidateFindRoot]];
  candidateRootCrossCheck=NumericQ[candidateBisectionRoot]&&NumericQ[rootAtCandidate]&&
    Abs[candidateBisectionRoot-rootAtCandidate]<=in["ExactEquilibriumRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[ff],Abs[candidateBisectionRoot]];
  candidateRootResidual=Abs[candidateMassResidual[ff]];
  capacity=in["ICARUSStationForceCapacity_N"];
  fullFeasible=validOptimizationResultQ[full] && gridCrossCheckPass && gridConstraintCrossCheckPass &&
    optimizerMassCheck && optimizerPowerCheck && optimizerThermalCheck && optimizerStructuralCheck &&
    candidateRootCrossCheck && massCandidate["MassLedgerCloses"] && naturalCandidate["ExactNaturalEquilibrium"] &&
    thermalCandidate["AllThermalLimitsWithinBounds"] && structureCandidate["StructuralScreenPass"] &&
    TrueQ[pvCandidate["PVOutputDoesNotExceedAbsorbedPower"]] && TrueQ[pvCandidate["PVOutputDoesNotExceedSpecificPower"]] &&
    TrueQ[thermalCandidate["PVThermalCouplingConverged"]];
  results=<|"Status"->"Joint distance/PV-coverage optimization; every candidate is evaluated with patch-integrated radiation, distributed gravity and gravity-gradient torque, its own mass/inertia, PV output, thermal state and structural margins.",
    "InputSnapshot"->in,"OptionalSourceNotesSnapshot"->inProvenance,
    "OptimizationGeometry"->geo,"OptimizationMeshResolution"->mesh["MeshResolution"],
    "OptimizationMomentumCoefficients"->coeff,"OptimizationIllumination"->illum,
    "ThermalDistanceFloorAtCurrentCoverage"->tempFloorResult,
    "StructuralDistanceFloorAtCurrentCoverage"->structuralFloorResult,
    "DistanceSearchRange_m"->{loR,hiR},"PVSearchRange"->{loF,hiF},
    "FullConstraintOptimization"->full,"FullConstraintOptimizerResultValid"->validOptimizationResultQ[full],
    "IndependentInitialDistanceExactEquilibriumDiagnostic"->exactEquilibriumCheck,
    "CandidateCoverageRootBisection"->candidateBisectionRoot,
    "CandidateCoverageRootFindRoot"->candidateFindRoot,
    "CandidateCoverageRootCrossCheck"->candidateRootCrossCheck,
    "CandidateRadialResidualNormalizedToSolarGravity"->candidateRootResidual,
    "OptimizerMassVectorCrossCheck"->optimizerMassCheck,
    "OptimizerPowerOutputCrossCheck"->optimizerPowerCheck,
    "OptimizerPowerOutputResidual_W"->optimizerPowerResidual,
    "OptimizerThermalFunctionCrossCheck"->optimizerThermalCheck,
    "OptimizerStructuralFunctionCrossCheck"->optimizerStructuralCheck,
    "OptimizerNaturalForceResidual_m_s2"->naturalCandidate["NaturalForceResidualMagnitude_m_s2"],
    "OptimizerNaturalTorqueResidual_Nm"->naturalCandidate["NaturalTorqueResidualMagnitude_Nm"],
    "ScalarMassFeasibilityDiagnosticOnly"->massCandidate["MassFeasible"],
    "OptimizerPVTemperatureMargin_K"->pvTemperatureMargin[rr,ff],
    "OptimizerReflectorTemperatureMargin_K"->reflectorTemperatureMargin[rr,ff],
    "OptimizerStructuralDeflectionMargin"->deflectionMargin[rr,ff],
    "OptimizerStructuralStressMargin_Pa"->stressMargin[rr,ff],
    "OptimizerStructuralPretensionMargin_N_m"->pretensionMargin[rr,ff],
    "OptimizerExactNaturalEquilibrium"->naturalCandidate["ExactNaturalEquilibrium"],
    "CandidateKind"->Which[TrueQ[fullFeasible],"StaticGatesPassedCandidateAwaitingDynamicAcceptance",
      validOptimizationResultQ[full],"NMaximizeCandidateFailedOneOrMoreStaticCrossChecks",
      True,"IndependentTwoDimensionalGridDiagnosticOnly"],
    "IndependentDistanceGridPointCount"->Length[gridDistancePoints],
    "IndependentCoverageGridPointCount"->Length[gridCoveragePoints],
    "IndependentGridPointCount"->Length[gridRecords],
    "IndependentGridFeasiblePointCount"->Length[gridFeasibleRecords],
    "IndependentTwoDimensionalGridBestFeasiblePoint"->gridBest,
    "IndependentGridConstraintCrossCheck"->gridConstraintCrossCheckPass,
    "IndependentGridConstraintViolationCount"->Length[gridConstraintViolations],
    "IndependentGridConstraintCrossCheckRule"->"At least one point on the user-configured distance-by-coverage grid must satisfy all natural force, torque, thermal and structural constraints; all other sampled points are counted as infeasible.",
    "OptimizerBeatsIndependentTwoDimensionalGrid"->gridCrossCheckPass,
    "StaticConstraintProblemFeasible"->fullFeasible,
    "FullConstraintProblemFeasible"->False,
    "DynamicCandidateAcceptancePassed"->False,
    "FullConstraintProblemFeasibleDefinition"->"True only when all static vector-equilibrium, thermal, structural, solver/grid and independent calculation gates pass AND a transient candidate-local recalculation plus integrated dynamic acceptance checks pass.",
    "CandidateDistance_m"->rr,"CandidateDistance_AU"->rr/in["AstronomicalUnit_m"],
    "CandidatePVFraction"->ff,"CandidateReflectiveFraction"->1.-ff,
    "CandidateDeliveredPower_W_PerPole"->powerCandidate["ConditionedDeliveredPower_W_PerPole"],
    "OptimizerObjectiveDeliveredPower_W_PerPole"->objectiveAtCandidate,
    "CandidateDeliveredPower_W_TwoPoles"->Missing["PerPoleOptimizerOnly; reconcile shared design across both poles"],
    "MassBalance"->massCandidate,"NaturalEquilibrium"->naturalCandidate,
    "DynamicInitialConditions"->dynCandidate,"Thermal"->thermalCandidate,"PVThermalCouplingFailure"->Lookup[performanceStateAt[rr,ff],"ConvergenceFailure",Missing["None"]],
    "PowerLedger"->powerCandidate,"StructuralScreen"->structureCandidate,
    "ICARUSCapacityPerStation_N"->capacity,
    "ExactNaturalEquilibrium"->naturalCandidate["ExactNaturalEquilibrium"],
    "ExactNaturalEquilibriumPerPoleAssembly"->naturalCandidate["ExactNaturalEquilibrium"],
    "WholeTwoPoleSystemEquilibriumEvaluated"->False,
    "OptimizationPowerReferenceEpoch"->"Start-of-mission; mission-end degradation is calculated separately and is not included in this objective.",
    "ApproximationPolicy"->"All non-universal model inputs and model-form choices are project-supplied, centrally stored and value-gated. Both distance and PV coverage are independent optimization variables. Candidate natural equilibrium is recomputed at each pair using attitude-dependent patch radiation and distributed solar gravity/torque. Thermal/structural/dynamic models remain explicitly reduced-order screens."|>;
  (* Recalculate and dynamically integrate every statically feasible optimizer candidate
     in a temporary pole-local snapshot. No optimizer value is written to live inputs. *)
  candidateEvaluation=If[TrueQ[fullFeasible],
    phase1EvaluateCandidateTransient[rr,ff,<|
      "FullJointConstraintOptimizationFeasible"->TrueQ[fullFeasible],
      "OptimizerIndependentTwoDimensionalGridCrossCheck"->TrueQ[gridCrossCheckPass],
      "OptimizerCandidateCoverageRootCrossCheck"->TrueQ[candidateRootCrossCheck],
      "OptimizerMassVectorCrossCheck"->TrueQ[optimizerMassCheck],
      "OptimizerPowerOutputCrossCheck"->TrueQ[optimizerPowerCheck],
      "OptimizerThermalFunctionCrossCheck"->TrueQ[optimizerThermalCheck],
      "OptimizerStructuralFunctionCrossCheck"->TrueQ[optimizerStructuralCheck]|>],
    <|"DynamicSimulation"->Missing["NotRunBecauseFullStaticOptimizerGatesDidNotPass"],
      "AcceptanceChecks"-><|"FullJointConstraintOptimizationFeasible"->False|>,
      "ModelledAcceptanceUnderAssumptions"->False,"CandidateEvaluatedTransiently"->False,
      "CandidateAppliedToCentralInputs"->False,"CandidateInputsRetained"->False,
      "Status"->"Dynamic evaluation was not run because the full static optimizer gates did not pass."|>
  ];
  dynamicAccepted=TrueQ[Lookup[candidateEvaluation,"ModelledAcceptanceUnderAssumptions",False]] &&
    TrueQ[Lookup[candidateEvaluation,"NoLivePoleStateMutation",False]];
  results=Join[results,candidateEvaluation,<|
    "StaticConstraintProblemFeasible"->TrueQ[fullFeasible],
    "DynamicCandidateAcceptancePassed"->dynamicAccepted,
    "FullConstraintProblemFeasible"->(TrueQ[fullFeasible]&&TrueQ[dynamicAccepted]),
    "FullConstraintProblemAcceptanceScope"->"This flag includes both the independent static optimizer cross-checks and the transient per-pole integrated dynamic acceptance checks; a static-only candidate is not an accepted full candidate."
  |>];
  $Phase1State=Join[$Phase1State,<|"Results"->Join[$Phase1State["Results"],<|"JointOptimization"->results|>]|>];
  phase1Audit["JointOptimizationCompleted",KeyDrop[results,"DynamicSimulation"]];
  results
];

(* ========================================================================
   6. DISTURBANCES, 3-D ROTATION, ICARUS AND INTEGRATED DYNAMICS
   ======================================================================== *)

phase1Quaternion[theta_List,tol_:Sqrt[$MachineEpsilon]] := Module[{a=Norm[theta]},If[a<tol,{1.,0.,0.,0.},Join[{Cos[a/2.]},Sin[a/2.] Normalize[theta]]]];
phase1QuaternionToRotationVector[qIn_List,tol_:Sqrt[$MachineEpsilon]] := Module[{qv=Normalize[qIn],vnorm,angle},
  If[qv[[1]]<0.,qv=-qv];vnorm=Norm[qv[[2;;4]]];
  If[vnorm<tol,{0.,0.,0.},angle=2. ArcTan[qv[[1]],vnorm];(angle/vnorm) qv[[2;;4]]]
];
phase1QuaternionRate[q_,w_] := 0.5 {{-q[[2]],-q[[3]],-q[[4]]},{q[[1]],-q[[4]],q[[3]]},{q[[4]],q[[1]],-q[[2]]},{-q[[3]],q[[2]],q[[1]]}}.w;

(* Software-only synthetic tests. These test pure mathematical helpers without
   requiring collector inputs and without changing the central model state. *)
Phase1RunSoftwareSelfTests[] := Module[
  {rotationVector = {0.13, -0.21, 0.08}, q, rotation, stations, wrench,
   irradiance1, irradiance2, root, bisectionChecks, checks, stateBefore, stateAfter},
  stateBefore = $Phase1State;
  q = phase1Quaternion[rotationVector];
  rotation = phase1RotationMatrix[q];
  stations = {{0., 1., 0.}, {0., 0., 1.}, {0., -1., 0.}, {0., 0., -1.}};
  wrench = phase1WrenchMatrix[stations];
  irradiance1 = phase1SolarIrradiance[<|"SolarLuminosity_W" -> 4. Pi|>, 1.];
  irradiance2 = phase1SolarIrradiance[<|"SolarLuminosity_W" -> 4. Pi|>, 2.];
  root = phase1BracketedBisection[Function[x, x^2 - 2.], {1., 2.}, 10.^-10, 100];
  bisectionChecks = <|
    "InteriorRootConverges" -> TrueQ[NumericQ[root] && Abs[root - Sqrt[2.]] < 10.^-8],
    "EndpointRootAccepted" -> TrueQ[phase1BracketedBisection[Function[x, x - 1.], {1., 2.}, 10.^-10, 20] === 1.],
    "UnbracketedRootRejected" -> (phase1BracketedBisection[Function[x, x^2 + 1.], {-1., 1.}, 10.^-8, 20] === $Failed)
  |>;
  checks = <|
    "QuaternionFiniteAndUnit" -> TrueQ[VectorQ[q, NumericQ] && Length[q] == 4 && Abs[Norm[q] - 1.] < 10.^-12],
    "QuaternionRoundTrip" -> TrueQ[Norm[phase1QuaternionToRotationVector[q] - rotationVector] < 10.^-10],
    "RotationMatrixOrthogonal" -> TrueQ[Norm[Flatten[rotation.Transpose[rotation] - IdentityMatrix[3]]] < 10.^-10],
    "RotationMatrixProper" -> TrueQ[Abs[Det[rotation] - 1.] < 10.^-10],
    "WrenchMatrixDimensions" -> TrueQ[Dimensions[wrench] === {6, 12}],
    "FourStationWrenchMatrixFullRank" -> TrueQ[MatrixRank[wrench] == 6],
    "SolarIrradianceInverseSquare" -> TrueQ[NumericQ[irradiance1] && NumericQ[irradiance2] && Abs[irradiance2/irradiance1 - 1./4.] < 10.^-12],
    "InvalidSolarDistanceRejected" -> FailureQ[phase1SolarIrradiance[<|"SolarLuminosity_W" -> 4. Pi|>, 0.]],
    "OptionalNotesDoNotEnterThisTest" -> True
  |>;
  checks = Join[checks, bisectionChecks];
  stateAfter = $Phase1State;
  checks = Join[checks, <|"ProjectStateUnchanged" -> SameQ[stateBefore, stateAfter]|>];
  <|"TestCount" -> Length[checks], "PassedCount" -> Count[Values[checks], True],
    "FailedChecks" -> Select[checks, !TrueQ[#] &], "Passed" -> And @@ (TrueQ /@ Values[checks]),
    "TestScope" -> "Pure software/math-path tests only; these are not engineering feasibility tests."|>
];

(* Torque-free rotation and damped wobble are solved using separate scalar
   dependent functions for each quaternion and angular-velocity component.
   NDSolveValue treats each listed dependent function as scalar; representing
   q[t] and w[t] as vector-valued unknown functions and then Part-indexing them
   is not a valid vector ODE formulation. The output samples are reassembled
   into four-component quaternion and three-component angular-rate vectors. *)
phase1FreeRotationTrajectoryCurrent[durationS_:Automatic] := Module[
  {in=Phase1GetInputs[],dyn,inertiaMat,q0,w0,ts,sol,computed,sampleTimes,samples,
   momentumNorms,rotationalEnergies,quaternionNormError,energyDrift,momentumDrift,
   t,q0f,q1f,q2f,q3f,w1f,w2f,w3f,qFunctions,wFunctions,qVector,wVector,
   qDerivative,wDerivative,equations,dependentFunctions,qAt,wAt},
  computed=phase1EnsureCalculated[];If[FailureQ[computed],Return[computed]];
  dyn=Phase1GetResult["DynamicInitialConditions"];
  If[!AssociationQ[dyn],Return[Failure["DynamicInitialConditionsUnavailable",<||>]]];
  inertiaMat=dyn["InertiaTensor_kg_m2"];q0=dyn["InitialQuaternion"];w0=dyn["InitialAngularVelocity_rad_s"];
  ts=If[durationS===Automatic,in["DynamicCheckDuration_s"],durationS];
  If[!NumericQ[ts]||!TrueQ[ts>0.],Return[Failure["InvalidRotationDuration",<|"Duration_s"->ts|>]]];
  qFunctions={q0f,q1f,q2f,q3f};wFunctions={w1f,w2f,w3f};
  qVector={q0f[t],q1f[t],q2f[t],q3f[t]};
  wVector={w1f[t],w2f[t],w3f[t]};
  qDerivative={q0f'[t],q1f'[t],q2f'[t],q3f'[t]};
  wDerivative={w1f'[t],w2f'[t],w3f'[t]};
  dependentFunctions=Join[qFunctions,wFunctions];
  equations=Join[
    Thread[qDerivative==phase1QuaternionRate[qVector,wVector]],
    Thread[inertiaMat.wDerivative+Cross[wVector,inertiaMat.wVector]=={0.,0.,0.}],
    Thread[{q0f[0.],q1f[0.],q2f[0.],q3f[0.]}==q0],
    Thread[{w1f[0.],w2f[0.],w3f[0.]}==w0]
  ];
  sol=Quiet@Check[NDSolveValue[equations,dependentFunctions,{t,0.,ts},
    AccuracyGoal->in["DynamicAccuracyGoal"],PrecisionGoal->in["DynamicPrecisionGoal"],
    MaxSteps->in["DynamicMaxSteps"]],$Failed];
  If[sol===$Failed,
    phase1StoreResult["FreeRotationTrajectory",<|"Solution"->$Failed,"SolverSucceeded"->False,
      "Status"->"Scalar-component torque-free rigid-body integration failed; no rotational stability result is claimed."|>],
    qAt[tt_?NumericQ]:=(#[tt]&/@Take[sol,4]);
    wAt[tt_?NumericQ]:=(#[tt]&/@Take[sol,-3]);
    sampleTimes=Subdivide[0.,ts,in["DynamicSampleCount"]];
    samples=Table[{qAt[tt],wAt[tt]},{tt,sampleTimes}];
    momentumNorms=Norm/@(inertiaMat.#&/@samples[[All,2]]);
    rotationalEnergies=(0.5 #.inertiaMat.#&/@samples[[All,2]]);
    quaternionNormError=Max[Abs[(Norm/@samples[[All,1]])-1.]];
    momentumDrift=Max[Abs[momentumNorms-momentumNorms[[1]]]]/Max[Sqrt[$MinMachineNumber],momentumNorms[[1]]];
    energyDrift=Max[Abs[rotationalEnergies-rotationalEnergies[[1]]]]/Max[Sqrt[$MinMachineNumber],Abs[rotationalEnergies[[1]]]];
    phase1StoreResult["FreeRotationTrajectory",<|"Solution"->sol,"SolverSucceeded"->True,"Duration_s"->ts,
      "SampleTimes_s"->sampleTimes,"SampleStates"->samples,
      "MaximumAngularRate_rad_s"->Max[Norm/@samples[[All,2]]],
      "MaximumQuaternionNormalizationError"->quaternionNormError,
      "SpecificAngularMomentumNormRelativeDrift"->momentumDrift,
      "RotationalKineticEnergyRelativeDrift"->energyDrift,
      "QuaternionNormalizationPass"->TrueQ[quaternionNormError<=in["QuaternionNormalizationTolerance"]],
      "AngularMomentumConservationPass"->TrueQ[momentumDrift<=in["PowerLedgerRelativeTolerance"]],
      "RotationalEnergyConservationPass"->TrueQ[energyDrift<=in["PowerLedgerRelativeTolerance"]],
      "Equations"->"Four scalar quaternion component equations and three scalar torque-free Euler angular-velocity equations; inertia is the central lumped-mass approximation. Angular momentum and rotational kinetic energy are independently monitored."|>]
  ]
];

phase1WobbleSimulationCurrent[durationS_:Automatic] := Module[
  {in=Phase1GetInputs[],dyn,inertiaMat,q0,w0,kMat,dMat,omegaN,ts,sol,computed,sampleTimes,samples,
   angleOf,maxAngle,maxRate,quaternionNormError,initialEnergy,finalEnergy,dampedEnergy,
   t,q0f,q1f,q2f,q3f,w1f,w2f,w3f,qFunctions,wFunctions,qVector,wVector,
   qDerivative,wDerivative,equations,dependentFunctions,qAt,wAt},
  computed=phase1EnsureCalculated[];If[FailureQ[computed],Return[computed]];
  dyn=Phase1GetResult["DynamicInitialConditions"];
  If[!AssociationQ[dyn],Return[Failure["DynamicInitialConditionsUnavailable",<||>]]];
  If[in["WobbleRestoringModel"] =!= "LinearSecondOrderAttitudeRestoring",
    Return[Failure["UnsupportedWobbleRestoringModel",<|"SelectedModel"->in["WobbleRestoringModel"]|>]]];
  inertiaMat=dyn["InertiaTensor_kg_m2"];q0=dyn["InitialQuaternion"];w0=dyn["InitialAngularVelocity_rad_s"];
  omegaN=2. Pi/in["WobbleNaturalPeriod_s"];
  kMat=omegaN^2 inertiaMat;
  dMat=2. in["WobbleDampingRatio"] omegaN inertiaMat;
  ts=If[durationS===Automatic,in["DynamicCheckDuration_s"],durationS];
  If[!NumericQ[ts]||!TrueQ[ts>0.],Return[Failure["InvalidWobbleDuration",<|"Duration_s"->ts|>]]];
  qFunctions={q0f,q1f,q2f,q3f};wFunctions={w1f,w2f,w3f};
  qVector={q0f[t],q1f[t],q2f[t],q3f[t]};
  wVector={w1f[t],w2f[t],w3f[t]};
  qDerivative={q0f'[t],q1f'[t],q2f'[t],q3f'[t]};
  wDerivative={w1f'[t],w2f'[t],w3f'[t]};
  dependentFunctions=Join[qFunctions,wFunctions];
  equations=Join[
    Thread[qDerivative==phase1QuaternionRate[qVector,wVector]],
    Thread[inertiaMat.wDerivative+Cross[wVector,inertiaMat.wVector]==-kMat.(2. qVector[[2;;4]])-dMat.wVector],
    Thread[{q0f[0.],q1f[0.],q2f[0.],q3f[0.]}==q0],
    Thread[{w1f[0.],w2f[0.],w3f[0.]}==w0]
  ];
  sol=Quiet@Check[NDSolveValue[equations,dependentFunctions,{t,0.,ts},
    AccuracyGoal->in["DynamicAccuracyGoal"],PrecisionGoal->in["DynamicPrecisionGoal"],
    MaxSteps->in["DynamicMaxSteps"]],$Failed];
  If[sol===$Failed,
    phase1StoreResult["WobbleSimulation",<|"Solution"->$Failed,"SolverSucceeded"->False,
      "Status"->"Scalar-component damped wobble integration failed; no bounded-wobble result is claimed."|>],
    qAt[tt_?NumericQ]:=(#[tt]&/@Take[sol,4]);
    wAt[tt_?NumericQ]:=(#[tt]&/@Take[sol,-3]);
    sampleTimes=Subdivide[0.,ts,in["DynamicSampleCount"]];
    samples=Table[{qAt[tt],wAt[tt]},{tt,sampleTimes}];
    angleOf[qv_?VectorQ]:=2. ArcCos[Clip[Abs[Normalize[qv][[1]]],{0.,1.}]];
    maxAngle=Max[angleOf/@samples[[All,1]]];
    maxRate=Max[Norm/@samples[[All,2]]];
    quaternionNormError=Max[Abs[(Norm/@samples[[All,1]])-1.]];
    initialEnergy=0.5 w0.inertiaMat.w0+0.5 (2. q0[[2;;4]]).kMat.(2. q0[[2;;4]]);
    dampedEnergy=Table[0.5 samples[[i,2]].inertiaMat.samples[[i,2]]+
      0.5 (2. samples[[i,1,2;;4]]).kMat.(2. samples[[i,1,2;;4]]),{i,Length[samples]}];
    finalEnergy=Last[dampedEnergy];
    phase1StoreResult["WobbleSimulation",<|"Solution"->sol,"SolverSucceeded"->True,"Duration_s"->ts,
      "SampleTimes_s"->sampleTimes,"SampleStates"->samples,
      "MaximumAttitudeDeviation_rad"->maxAngle,"MaximumAngularRate_rad_s"->maxRate,
      "MaximumQuaternionNormalizationError"->quaternionNormError,
      "InitialProxyMechanicalEnergy_J"->initialEnergy,"FinalProxyMechanicalEnergy_J"->finalEnergy,
      "ProxyMechanicalEnergyNonIncreasing"->TrueQ[finalEnergy<=initialEnergy+in["PowerLedgerRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[initialEnergy]]],
      "AttitudeWithinTolerance"->TrueQ[maxAngle<=in["AttitudeTolerance_rad"]],
      "AngularRateWithinTolerance"->TrueQ[maxRate<=in["AngularRateRecoveryTolerance_rad_s"]],
      "QuaternionNormalizationPass"->TrueQ[quaternionNormError<=in["QuaternionNormalizationTolerance"]],
      "RestoringStiffnessProxy_Nm_rad"->kMat,"DampingProxy_Nms_rad"->dMat,
      "SelectedWobbleRestoringModel"->in["WobbleRestoringModel"],
      "Model"->"Four scalar quaternion component equations and three scalar Euler rigid-body angular-velocity equations with explicitly selected linear second-order restoring and damping. The attitude restoring term and membrane response are reduced-order surrogates; proxy mechanical energy, attitude, angular rate and quaternion norm are checked."|>]
  ]
];

phase1FlareTimeBounds[in_Association] := Module[{sigma,cutoff,extent,peak},
  sigma=in["FlareDuration_s"]/(2. Sqrt[2. Log[2.]]);
  cutoff=in["FlareTailCutoffFraction"];
  peak=in["FlarePeakTime_s"];
  extent=sigma Sqrt[2. Log[1./cutoff]];
  <|"Sigma_s"->sigma,"PeakTime_s"->peak,"StartTime_s"->peak-extent,
    "EndTime_s"->peak+extent,"RawGaussianTailCutoffFraction"->cutoff,
    "NominalGaussianFWHM_s"->in["FlareDuration_s"]|>
];

phase1Disturbance[in_Association,timeS_?NumericQ,r_?NumericQ] := Module[
  {flareBounds,flareWidth,cutoff,extent,delta,rawGaussian,flareShape,flare,years,pwindAU,pwind,cme,deltaCME,irradiance,sepFactor},
  If[in["FlareTemporalProfile"] =!= "GaussianFWHM" || in["CMETemporalProfile"] =!= "RectangularPressureEnvelope",
    Return[Failure["UnsupportedDisturbanceProfile",<|"Flare"->in["FlareTemporalProfile"],"CME"->in["CMETemporalProfile"]|>]]];
  (* The flare is a finite-support, baseline-corrected Gaussian. PeakTime is its centre;
     Duration is the raw Gaussian FWHM; TailCutoffFraction sets the exact support boundary. *)
  flareBounds=phase1FlareTimeBounds[in];
  flareWidth=flareBounds["Sigma_s"];cutoff=in["FlareTailCutoffFraction"];
  extent=flareBounds["EndTime_s"]-flareBounds["PeakTime_s"];
  delta=Abs[timeS-flareBounds["PeakTime_s"]];
  rawGaussian=If[delta<=extent,Exp[-delta^2/(2. flareWidth^2)],0.];
  flareShape=If[delta<=extent,Clip[(rawGaussian-cutoff)/(1.-cutoff),{0.,1.}],0.];
  flare=1.+in["FlarePeakFraction"] flareShape;
  years=Max[0.,timeS/in["Year_s"]];
  pwindAU=in["SolarWindProtonDensity_1AU_cm3"]*in["CentimetersPerMeter"]^3*in["ProtonMass_kg"]*in["SolarWindSpeed_1AU_m_s"]^2;
  pwind=pwindAU*(in["AstronomicalUnit_m"]/r)^2;
  cme=If[in["CMEOnset_s"]<=timeS<=in["CMEOnset_s"]+in["CMEDuration_s"],in["CMEWindPressureMultiplier"],1.];
  deltaCME=pwind*(cme-1.);
  irradiance=phase1SolarIrradiance[in,r]*flare;
  sepFactor=Clip[1.-in["PVDegradationPerSEPReferenceDoseFraction"]*in["SEPDose_protons_cm2"]/in["SEPDoseReference_protons_cm2"],{0.,1.}];
  <|"FlareMultiplier"->flare,"FlareProfileStartTime_s"->flareBounds["StartTime_s"],
    "FlareProfilePeakTime_s"->flareBounds["PeakTime_s"],"FlareProfileEndTime_s"->flareBounds["EndTime_s"],
    "FlareNominalGaussianFWHM_s"->in["FlareDuration_s"],"FlareRawGaussianTailCutoffFraction"->cutoff,
    "FlareAdjustedIrradiance_W_m2"->irradiance,
    "CMEWindMultiplier"->cme,"BaselineSolarWindPressure_Pa"->pwind,
    "CMEExcessDynamicPressure_Pa"->deltaCME,
    "PVAnnualDegradationFactor"->(1.-in["PVAnnualDegradationFraction"])^years,
    "PVSEPDegradationFactor"->sepFactor,
    "PVDegradationFactor"->(1.-in["PVAnnualDegradationFraction"])^years sepFactor,
    "ReflectivityFactor"->(1.-in["ReflectivityAnnualLossFraction"])^years,
    "ElapsedMissionYears"->years|>
];

phase1DisturbanceScenariosCurrent[] := Module[{in=Phase1GetInputs[],pwind,result,computed},
  computed=phase1EnsureCalculated[];If[FailureQ[computed],Return[computed]];
  in=Phase1GetInputs[];
  pwind=in["SolarWindProtonDensity_1AU_cm3"] in["CentimetersPerMeter"]^3 in["ProtonMass_kg"] in["SolarWindSpeed_1AU_m_s"]^2;
  result=<|"Flare"-><|"PeakIncreaseFraction"->in["FlarePeakFraction"],"PeakTime_s"->in["FlarePeakTime_s"],"NominalGaussianFWHM_s"->in["FlareDuration_s"],"TailCutoffFraction"->in["FlareTailCutoffFraction"],"FiniteSupportBounds"->phase1FlareTimeBounds[in],"Profile"->in["FlareTemporalProfile"]|>,
    "CME"-><|"PressureMultiplier"->in["CMEWindPressureMultiplier"],"Onset_s"->in["CMEOnset_s"],"Duration_s"->in["CMEDuration_s"],"BaselinePressureAt1AU_Pa"->pwind,"Profile"->in["CMETemporalProfile"]|>,
    "SolarEnergeticParticles"-><|"Fluence_protons_cm2"->in["SEPDose_protons_cm2"],"Use"->"Degradation sensitivity placeholder; not a radiation transport calculation"|>,
    "LongTermDegradation"-><|"PVAnnualLossFraction"->in["PVAnnualDegradationFraction"],"ReflectivityAnnualLossFraction"->in["ReflectivityAnnualLossFraction"],"MissionYears"->in["ReferenceMissionYears"]|>|>;
  phase1StoreResult["DisturbanceScenarios",result]
];

phase1PerformanceAtTime[in_Association,geo_Association,mesh_Association,timeS_?NumericQ,
    localPosition_List:{0.,0.,0.},attitudeQuaternion_:Automatic] := Module[
  {d,optics,reflectorR,reflectorT,reflectorA,timeInputs,rad,coupled,thermal,pv,power,
   heliocentricPosition,actualDistance,radialDirection,solarRotation,sun,q},
  If[Length[localPosition]!=3 || !VectorQ[localPosition,NumericQ],
    Return[Failure["InvalidLocalPositionForTimeDependentPower",<|"Position"->localPosition|>]]];
  q=If[attitudeQuaternion===Automatic,Lookup[mesh,"AttitudeQuaternion",{1.,0.,0.,0.}],attitudeQuaternion];
  If[!VectorQ[q,NumericQ] || Length[q]!=4 || Norm[q]==0.,
    Return[Failure["InvalidAttitudeForTimeDependentPower",<|"Quaternion"->q|>]]];
  heliocentricPosition={in["Distance_m"],0.,0.}+localPosition;
  actualDistance=Norm[heliocentricPosition];
  If[!TrueQ[actualDistance>0.],Return[Failure["InvalidHeliocentricDistanceAtTime",<|"Position"->heliocentricPosition|>]]];
  radialDirection=Normalize[heliocentricPosition];
  solarRotation={{Cos[in["IncidenceAngle_deg"] Degree],-Sin[in["IncidenceAngle_deg"] Degree],0.},
    {Sin[in["IncidenceAngle_deg"] Degree],Cos[in["IncidenceAngle_deg"] Degree],0.},{0.,0.,1.}};
  sun=Normalize[solarRotation.radialDirection];
  d=phase1Disturbance[in,timeS,actualDistance];
  If[FailureQ[d],Return[d]];
  optics=phase1Optics[in];
  If[FailureQ[optics] || !AssociationQ[optics] || !AssociationQ[Lookup[optics,"Reflector",Missing["NoReflectorOptics"]]],
    Return[Failure["OpticalStateUnavailable",<|"Time_s"->timeS,"Optics"->optics|>]]];
  reflectorT=optics["Reflector"]["T"];
  reflectorR=Clip[in["ReflectorSolarReflectivity"] d["ReflectivityFactor"],{0.,1.-reflectorT}];
  reflectorA=1.-reflectorR-reflectorT;
  optics=Join[optics,<|"Reflector"-><|"R"->reflectorR,"A"->reflectorA,"T"->reflectorT|>,
    "EnergyClosure"->Join[optics["EnergyClosure"],<|"Reflector"->reflectorR+reflectorA+reflectorT|>]|>];
  timeInputs=Join[in,<|"SolarLuminosity_W"->in["SolarLuminosity_W"] d["FlareMultiplier"]|>];
  rad=phase1Radiation[timeInputs,geo,mesh,optics,in["PVFraction"],actualDistance,in["IncidenceAngle_deg"],sun];
  If[FailureQ[rad] || !AssociationQ[rad],Return[Failure["TimeDependentRadiationCalculationFailed",<|"Time_s"->timeS,"Result"->rad|>]]];
  coupled=phase1CoupledPVThermal[timeInputs,geo,mesh,optics,rad,in["PVFraction"],actualDistance,d["ElapsedMissionYears"]];
  If[FailureQ[coupled],Return[coupled]];
  thermal=coupled["Thermal"];pv=coupled["PVPerformance"];
  power=phase1Power[in,pv];
  <|"Time_s"->timeS,"MissionYears"->d["ElapsedMissionYears"],"DistanceAtTime_m"->actualDistance,
    "LocalPositionAtTime_m"->localPosition,"AttitudeQuaternionAtTime"->Normalize[q],
    "SunDirectionAtTime"->sun,"Disturbance"->d,"OpticalRegister"->optics,
    "LocalRadiation"->rad,"Thermal"->thermal,"PVPerformance"->pv,
    "PowerLedger"->power,"PVThermalCoupling"->KeyDrop[coupled,{"Thermal","PVPerformance"}]|>
];

phase1TimeDependentPowerCurrent[timeS_?NumericQ] := Module[
  {in,computed,geo,mesh,dyn,sim,sol,localPosition,attitude,attitudeSource,solutionRange,result},
  If[!TrueQ[timeS>=0.],Return[Failure["NegativeTimeNotAllowed",<|"Time_s"->timeS|>]]];
  in=Phase1GetInputs[];
  computed=phase1EnsureCalculated[];
  If[FailureQ[computed],Return[computed]];
  If[!AssociationQ[Lookup[$Phase1State,"Derived",Missing["NoDerivedState"]]] ||
     !AssociationQ[Lookup[$Phase1State,"Results",Missing["NoResultState"]]],
    Return[Failure["CentralCalculationStateUnavailable",<||>]]];
  geo=Lookup[$Phase1State["Derived"],"Geometry",Missing["GeometryUnavailable"]];
  dyn=Lookup[$Phase1State["Results"],"DynamicInitialConditions",Missing["DynamicInitialConditionsUnavailable"]];
  mesh=Lookup[$Phase1State["Derived"],"SurfaceMesh",Missing["SurfaceMeshUnavailable"]];
  If[!AssociationQ[geo] || !AssociationQ[dyn] || !AssociationQ[mesh],
    Return[Failure["DerivedGeometryOrDynamicStateUnavailable",<||>]]];
  sim=Lookup[$Phase1State["Results"],"IntegratedSimulation",Missing["NoIntegratedSimulation"]];
  If[AssociationQ[sim] && KeyExistsQ[sim,"Solution"] && sim["Solution"] =!= $Failed,
    solutionRange=Lookup[sim,"Duration_s",0.];
    If[!TrueQ[0.<=timeS<=solutionRange],
      Return[Failure["TimeOutsideIntegratedSimulationDuration",<|"Time_s"->timeS,"Duration_s"->solutionRange|>]]];
    sol=sim["Solution"];
    If[!AssociationQ[sol] || !And@@(KeyExistsQ[sol,#]& /@ {"PositionFunctions","VelocityFunctions","AttitudeFunctions","AngularVelocityFunctions"}),
      Return[Failure["IntegratedTrajectorySolutionFormatInvalid",<|"Time_s"->timeS|>]]];
    localPosition=Quiet@Check[(#[timeS]& /@ sol["PositionFunctions"]),$Failed];
    attitude=Quiet@Check[(#[timeS]& /@ sol["AttitudeFunctions"]),$Failed];
    If[localPosition===$Failed || attitude===$Failed || !VectorQ[localPosition,NumericQ] || Length[localPosition]!=3 ||
       !VectorQ[attitude,NumericQ] || Length[attitude]!=4,
      Return[Failure["IntegratedTrajectoryEvaluationFailed",<|"Time_s"->timeS|>]]];
    mesh=phase1RotateMeshToCOM[mesh,dyn["CenterOfMassLocal_m"],attitude];
    attitudeSource="IntegratedSimulationTrajectory";
    ,
    If[AssociationQ[sim] && Lookup[sim,"Solution",None]===$Failed,
      Return[Failure["IntegratedSimulationFailed",<|"Reason"->"Dynamic attitude and position are unavailable; refusing to substitute static conditions."|>]]];
    localPosition=dyn["InitialPositionLocal_m"];
    attitude=dyn["InitialQuaternion"];
    mesh=phase1RotateMeshToCOM[mesh,dyn["CenterOfMassLocal_m"],attitude];
    attitudeSource="InitialConditions; no integrated trajectory has been stored"
  ];
  result=phase1PerformanceAtTime[in,geo,mesh,timeS,localPosition,attitude];
  If[FailureQ[result] || !AssociationQ[result],Return[If[FailureQ[result],result,Failure["TimeDependentPerformanceResultInvalid",<|"Result"->result|>]]]];
  result=Join[result,<|"AttitudeAndPositionSource"->attitudeSource,
    "UsesIntegratedPositionWhenAvailable"->True,"UsesIntegratedAttitudeWhenAvailable"->True|>];
  phase1StoreResult["TimeDependentPower",result];
  phase1Audit["TimeDependentPowerCalculated",<|"Time_s"->timeS,"MissionYears"->result["MissionYears"],
    "DistanceAtTime_m"->result["DistanceAtTime_m"],
    "AttitudeAndPositionSource"->attitudeSource,
    "DeliveredPower_W_PerPole"->result["PowerLedger"]["ConditionedDeliveredPower_W_PerPole"]|>];
  result
];

phase1ICARUSControlLawCurrent[desiredWrench_List,capacityN_:Automatic] := Module[
  {in=Phase1GetInputs[],dyn,cap,res},
  With[{computed=phase1EnsureCalculated[]},If[FailureQ[computed],Return[computed]]];
  dyn=Phase1GetResult["DynamicInitialConditions"];
  If[!AssociationQ[dyn],Return[Failure["DynamicInitialConditionsUnavailable",<||>]]];
  cap=If[capacityN===Automatic,Phase1GetResult["ICARUSCapacityPerStation_N"],capacityN];
  res=phase1Controller[dyn,desiredWrench,cap];
  phase1StoreResult["ICARUSLastControlAllocation",res]
];

phase1ICARUSLoadPropagationCurrent[localPosition_List,localVelocity_List,attitudeQuaternion_List,angularVelocity_List] := Module[
  {in=Phase1GetInputs[],dyn,mass,inertia,kp,kd,kt,kw,att,wrench,allocation,mesh,geo,loadmap},
  With[{computed=phase1EnsureCalculated[]},If[FailureQ[computed],Return[computed]]];
  dyn=Phase1GetResult["DynamicInitialConditions"];
  If[!AssociationQ[dyn],Return[Failure["DynamicInitialConditionsUnavailable",<||>]]];
  mass=dyn["TotalMass_kg"];inertia=dyn["InertiaTensor_kg_m2"];
  kp=in["ControllerTranslationKp_perS2"];kd=in["ControllerTranslationKd_perS"];kt=in["ControllerAttitudeKp_perS2"];kw=in["ControllerAttitudeKd_perS"];
  att=2. attitudeQuaternion[[2;;4]];
  wrench=Join[{0.,-mass (kp localPosition+kd localVelocity)[[2]],-mass (kp localPosition+kd localVelocity)[[3]]},-inertia.(kt att+kw angularVelocity)];
  allocation=Phase1ICARUSControlLaw[wrench];
  geo=$Phase1State["Derived"]["Geometry"];
  mesh=phase1Mesh[in,geo];
  loadmap=phase1LoadMap[in,geo,mesh,dyn,allocation["StationForces_N"]];
  phase1StoreResult["ICARUSLastLoadPropagation",<|"DesiredWrench"->wrench,"Allocation"->allocation,"LocalMembraneLoadMap"->loadmap,
    "RadialControl"->"Disabled by governing rule; controller cannot conceal radial natural-force imbalance."|>]
];

(* Integrated translation and attitude dynamics are solved with thirteen
   scalar dependent functions. Wolfram Language NDSolveValue dependent
   functions are scalar; vector states are reconstructed only inside numeric
   right-hand-side evaluations and after the solver returns. This avoids the
   invalid use of Part on a vector-valued dependent function such as x[t][[2]]. *)
phase1IntegratedSimulationCurrent[durationS_:Automatic] := Module[
  {in=Phase1GetInputs[],core,dyn,geo,mesh,mass,inertia,capacity,wrenchMatrix,arealMass,
   kp,kd,kt,kw,rawControl,actualControl,numericStateQ,numericVectorQ,rotationMatrix,
   disturbanceState,sol,solutionAccessors,ts,sampleTimes,samples,maxRad,maxLat,maxAtt,maxReq,maxUsed,
   saturation,struct,results,withinQ,disturbanceEnd,postIndices,recoveryIndex,
   recoveryTime,radialTol,lateralTol,angleOf,velTol,rateTol,baseAccelerationCrossCheck,
   centeredPatches,radialDirection,peakReq,peakApplied,quatNormError,loadIndices,loadRecords,
   loadMapAtPeak,peakLoadIndex,peakLocalLoad,maxLoadMapResidual,maxLoadMapMomentResidual,
   peakPatchTraction,maxPatchTraction,peakICARUSTraction,structuralPressureLimit,structuralLoadPass,
   initialStateAcceleration,initialStateAttitude,patchForcesBody,combinedPatchForces,patchTractions,
   baseAccelerationScale,peakState,peakEnvironmentalForces,peakICARUSForces,peakCombinedPatchForces,peakPatchTractions,
   translationalAccelerationComponent,angularAccelerationComponent,environmentNow,controlNow,controlWrenchNow,
   t,x1f,x2f,x3f,v1f,v2f,v3f,q0f,q1f,q2f,q3f,w1f,w2f,w3f,
   xFunctions,vFunctions,qFunctions,wFunctions,xVector,vVector,qVector,wVector,
   xDerivative,vDerivative,qDerivative,wDerivative,dependentFunctions,equations,stateVector},
  core=phase1EnsureCalculated[];
  If[FailureQ[core],Return[core]];
  dyn=core["DynamicInitialConditions"];
  geo=Phase1GetState[]["Derived"]["Geometry"];
  mesh=Phase1GetState[]["Derived"]["SurfaceMesh"];
  mass=dyn["TotalMass_kg"];
  inertia=dyn["InertiaTensor_kg_m2"];
  arealMass=core["MassBalance"]["TotalArealMass_kg_m2"];
  capacity=core["ICARUSCapacityPerStation_N"];
  wrenchMatrix=core["ICARUSWrenchMatrix"];
  kp=in["ControllerTranslationKp_perS2"];kd=in["ControllerTranslationKd_perS"];
  kt=in["ControllerAttitudeKp_perS2"];kw=in["ControllerAttitudeKd_perS"];
  radialDirection={1.,0.,0.};
  centeredPatches=Map[Function[p,Join[p,<|"Position_m"->(p["Position_m"]-dyn["CenterOfMassLocal_m"])|>]],mesh["Patches"]];
  numericVectorQ[v_] := VectorQ[v,NumericQ];
  numericStateQ[z_] := ListQ[z] && Length[z]==4 && And@@(numericVectorQ /@ z);
  rotationMatrix[qInput_] := Module[{qv=Normalize[qInput],q0,q1,q2,q3},
    {q0,q1,q2,q3}=qv;
    {{1.-2. (q2^2+q3^2),2. (q1 q2-q0 q3),2. (q1 q3+q0 q2)},
     {2. (q1 q2+q0 q3),1.-2. (q1^2+q3^2),2. (q2 q3-q0 q1)},
     {2. (q1 q3-q0 q2),2. (q2 q3+q0 q1),1.-2. (q1^2+q2^2)}}
  ];
  rawControl[state_?numericStateQ] := Module[{x,v,q,w,rot,xb,vb,qbody,thetaBody,forceBody,torqueBody,wrench},
    {x,v,q,w}=state;rot=rotationMatrix[q];
    xb=Transpose[rot].x;vb=Transpose[rot].v;
    qbody=If[q[[1]]<0.,-q,q];
    thetaBody=If[Norm[qbody[[2;;4]]]<Sqrt[$MachineEpsilon],{0.,0.,0.},
      (2. ArcCos[Clip[qbody[[1]],{-1.,1.}]]/Norm[qbody[[2;;4]]]) qbody[[2;;4]]];
    forceBody={0.,-mass (kp xb+kd vb)[[2]],-mass (kp xb+kd vb)[[3]]};
    torqueBody=-inertia.(kt thetaBody+kw w);
    wrench=Join[forceBody,torqueBody];
    Partition[PseudoInverse[wrenchMatrix].wrench,3]
  ];
  actualControl[state_?numericStateQ] := Map[If[Norm[#]>capacity,capacity Normalize[#],#]&,rawControl[state]];
  disturbanceState[tt_?NumericQ,xState_?numericVectorQ,qState_?numericVectorQ,includeEvents_:True] := Module[
    {rot,localDistance,d,reflectorR,reflectorT,reflectorA,pvOptics,refOptics,opticsNow,
     timeInputs,rotatedPatches,rotatedMesh,rad,sun,radialVector,radialDirection,projectedWindArea,
     cmeForces,cmeTorque,cmeForce,acceleration,torqueBody,localPosition,heliocentricPosition,solarRotation,gravityLoad},
    rot=rotationMatrix[qState];
    localPosition=xState;
    heliocentricPosition={in["Distance_m"],0.,0.}+localPosition;
    localDistance=Norm[heliocentricPosition];
    If[!TrueQ[localDistance>0.],Return[{ConstantArray[Indeterminate,3],ConstantArray[Indeterminate,3],ConstantArray[Indeterminate,{Length[mesh["Patches"]],3}]}]];
    radialDirection=Normalize[heliocentricPosition];
    solarRotation={{Cos[in["IncidenceAngle_deg"] Degree],-Sin[in["IncidenceAngle_deg"] Degree],0.},
      {Sin[in["IncidenceAngle_deg"] Degree],Cos[in["IncidenceAngle_deg"] Degree],0.},{0.,0.,1.}};
    sun=Normalize[solarRotation.radialDirection];
    d=phase1Disturbance[in,tt,localDistance];
    If[!TrueQ[includeEvents],d=Join[d,<|"FlareMultiplier"->1.,"CMEWindMultiplier"->1.,"ReflectivityFactor"->1.|>]];
    reflectorT=in["ReflectorSolarTransmissivity"];
    reflectorR=Clip[in["ReflectorSolarReflectivity"] d["ReflectivityFactor"],{0.,1.-reflectorT}];
    reflectorA=1.-reflectorR-reflectorT;
    pvOptics=<|"R"->in["PVSolarReflectivity"],"T"->in["PVSolarTransmissivity"],
      "A"->1.-in["PVSolarReflectivity"]-in["PVSolarTransmissivity"]|>;
    refOptics=<|"R"->reflectorR,"T"->reflectorT,"A"->reflectorA|>;
    opticsNow=<|"PV"->pvOptics,"Reflector"->refOptics,
      "EnergyClosure"-><|"PV"->Total[Values[pvOptics]],"Reflector"->Total[Values[refOptics]]|>|>;
    timeInputs=Join[in,<|"SolarLuminosity_W"->in["SolarLuminosity_W"] d["FlareMultiplier"]|>];
    rotatedPatches=Map[Function[p,Join[p,<|"Position_m"->(rot.p["Position_m"]),
      "Normal"->Normalize[rot.p["Normal"]]|>]],centeredPatches];
    rotatedMesh=Join[mesh,<|"Patches"->rotatedPatches|>];
    rad=phase1Radiation[timeInputs,geo,rotatedMesh,opticsNow,in["PVFraction"],localDistance,in["IncidenceAngle_deg"],sun];
    projectedWindArea=Total[Map[Function[p,Max[0.,p["Normal"].radialDirection] p["SurfaceAreaWeight_m2"]],rotatedPatches]];
    cmeForce=d["BaselineSolarWindPressure_Pa"] d["CMEWindMultiplier"] projectedWindArea radialDirection;
    cmeForces=Map[Function[p,d["BaselineSolarWindPressure_Pa"]*d["CMEWindMultiplier"]*Max[0.,p["Normal"].radialDirection]*
       p["SurfaceAreaWeight_m2"]*radialDirection],rotatedPatches];
    cmeTorque=Total[MapThread[Cross[#1,#2]&,{Lookup[rotatedPatches,"Position_m"],cmeForces}]];
    gravityLoad=phase1GravityLoads[Join[in,<|"Distance_m"->localDistance|>],dyn,heliocentricPosition,qState];
    acceleration=(rad["NetRadiationForceVector_N"]+gravityLoad["TotalGravityForce_N"]+cmeForce)/mass;
    torqueBody=Transpose[rot].(rad["NetRadiationMoment_Nm"]+
      gravityLoad["TotalGravityTorqueInertial_Nm"]+cmeTorque);
    patchForcesBody=Map[Transpose[rot].#&,
      (Lookup[rad["PatchLoads"],"RadiationForceVector_N"]+cmeForces)];
    {acceleration,torqueBody,patchForcesBody}
  ];
  ts=If[durationS===Automatic,in["DynamicCheckDuration_s"],durationS];
  If[!NumericQ[ts]||!TrueQ[ts>0.],Return[Failure["InvalidIntegratedSimulationDuration",<|"Duration_s"->ts|>]]];
  baseAccelerationCrossCheck=Norm[disturbanceState[0.,{0.,0.,0.},dyn["InitialQuaternion"],False][[1]]-
    core["MassBalance"]["NetNaturalAccelerationVector_m_s2"]];
  initialStateAcceleration=disturbanceState[0.,dyn["InitialPositionLocal_m"],dyn["InitialQuaternion"]][[1]];
  initialStateAttitude=phase1QuaternionToRotationVector[dyn["InitialQuaternion"],Sqrt[$MachineEpsilon]];
  baseAccelerationScale=Max[Norm[core["MassBalance"]["RadiationAccelerationVector_m_s2"]],
    core["MassBalance"]["SolarGravityAcceleration_m_s2"],$MinMachineNumber];

  (* Scalar component dependent functions; vectors are reconstructed for each RHS evaluation. *)
  xFunctions={x1f,x2f,x3f};vFunctions={v1f,v2f,v3f};
  qFunctions={q0f,q1f,q2f,q3f};wFunctions={w1f,w2f,w3f};
  xVector={x1f[t],x2f[t],x3f[t]};vVector={v1f[t],v2f[t],v3f[t]};
  qVector={q0f[t],q1f[t],q2f[t],q3f[t]};wVector={w1f[t],w2f[t],w3f[t]};
  xDerivative={x1f'[t],x2f'[t],x3f'[t]};vDerivative={v1f'[t],v2f'[t],v3f'[t]};
  qDerivative={q0f'[t],q1f'[t],q2f'[t],q3f'[t]};wDerivative={w1f'[t],w2f'[t],w3f'[t]};
  dependentFunctions=Join[xFunctions,vFunctions,qFunctions,wFunctions];
  stateVector={xVector,vVector,qVector,wVector};
  (* Scalar numeric helper functions defer disturbance and controller evaluation
     until NDSolve supplies a numeric time and complete numeric state. Applying
     Part to a still-unevaluated NumericQ-gated vector function would otherwise
     leave an invalid symbolic Part expression in the differential equations. *)
  translationalAccelerationComponent[component_Integer,tt_?NumericQ,xState_?numericVectorQ,
      vState_?numericVectorQ,qState_?numericVectorQ,wState_?numericVectorQ] := Module[
    {environment,stationForces,controlForce},
    environment=disturbanceState[tt,xState,qState];
    If[!ListQ[environment] || Length[environment]<1 || !VectorQ[environment[[1]],NumericQ],Return[Indeterminate]];
    stationForces=actualControl[{xState,vState,qState,wState}];
    controlForce=rotationMatrix[qState].(wrenchMatrix[[1;;3]].Flatten[stationForces])/mass;
    environment[[1,component]]+controlForce[[component]]
  ];
  angularAccelerationComponent[component_Integer,tt_?NumericQ,xState_?numericVectorQ,
      vState_?numericVectorQ,qState_?numericVectorQ,wState_?numericVectorQ] := Module[
    {environment,stationForces,controlTorque},
    environment=disturbanceState[tt,xState,qState];
    If[!ListQ[environment] || Length[environment]<2 || !VectorQ[environment[[2]],NumericQ],Return[Indeterminate]];
    stationForces=actualControl[{xState,vState,qState,wState}];
    controlTorque=wrenchMatrix[[4;;6]].Flatten[stationForces];
    LinearSolve[inertia,environment[[2]]+controlTorque-Cross[wState,inertia.wState]][[component]]
  ];
  equations={
    x1f'[t]==v1f[t],x2f'[t]==v2f[t],x3f'[t]==v3f[t],
    v1f'[t]==translationalAccelerationComponent[1,t,xVector,vVector,qVector,wVector],
    v2f'[t]==translationalAccelerationComponent[2,t,xVector,vVector,qVector,wVector],
    v3f'[t]==translationalAccelerationComponent[3,t,xVector,vVector,qVector,wVector],
    q0f'[t]==phase1QuaternionRate[qVector,wVector][[1]],
    q1f'[t]==phase1QuaternionRate[qVector,wVector][[2]],
    q2f'[t]==phase1QuaternionRate[qVector,wVector][[3]],
    q3f'[t]==phase1QuaternionRate[qVector,wVector][[4]],
    w1f'[t]==angularAccelerationComponent[1,t,xVector,vVector,qVector,wVector],
    w2f'[t]==angularAccelerationComponent[2,t,xVector,vVector,qVector,wVector],
    w3f'[t]==angularAccelerationComponent[3,t,xVector,vVector,qVector,wVector],
    x1f[0.]==dyn["InitialPositionLocal_m"][[1]],x2f[0.]==dyn["InitialPositionLocal_m"][[2]],x3f[0.]==dyn["InitialPositionLocal_m"][[3]],
    v1f[0.]==dyn["InitialVelocityLocal_m_s"][[1]],v2f[0.]==dyn["InitialVelocityLocal_m_s"][[2]],v3f[0.]==dyn["InitialVelocityLocal_m_s"][[3]],
    q0f[0.]==dyn["InitialQuaternion"][[1]],q1f[0.]==dyn["InitialQuaternion"][[2]],
    q2f[0.]==dyn["InitialQuaternion"][[3]],q3f[0.]==dyn["InitialQuaternion"][[4]],
    w1f[0.]==dyn["InitialAngularVelocity_rad_s"][[1]],w2f[0.]==dyn["InitialAngularVelocity_rad_s"][[2]],
    w3f[0.]==dyn["InitialAngularVelocity_rad_s"][[3]]
  };
  sol=Quiet@Check[NDSolveValue[equations,dependentFunctions,{t,0.,ts},
    AccuracyGoal->in["DynamicAccuracyGoal"],PrecisionGoal->in["DynamicPrecisionGoal"],
    MaxSteps->in["DynamicMaxSteps"]],$Failed];
  If[sol===$Failed,
    results=<|"Solution"->$Failed,"BaseAccelerationConsistencyResidual_m_s2"->baseAccelerationCrossCheck,
      "RecoveryWithinLimit"->False,"ICARUSWithinCapacity"->False,
      "Status"->"NDSolveValue failed for the thirteen scalar state components. No dynamic acceptance is claimed."|>,
    solutionAccessors=<|"PositionFunctions"->Take[sol,3],"VelocityFunctions"->Take[sol,{4,6}],
      "AttitudeFunctions"->Take[sol,{7,10}],"AngularVelocityFunctions"->Take[sol,{11,13}]|>;
    sampleTimes=Subdivide[0.,ts,in["DynamicSampleCount"]];
    samples=Table[
      {(#[tt]&/@solutionAccessors["PositionFunctions"]),
       (#[tt]&/@solutionAccessors["VelocityFunctions"]),
       (#[tt]&/@solutionAccessors["AttitudeFunctions"]),
       (#[tt]&/@solutionAccessors["AngularVelocityFunctions"])},
      {tt,sampleTimes}];
    maxRad=Max[Abs[samples[[All,1,1]]]];
    maxLat=Max[Norm/@samples[[All,1,2;;3]]];
    angleOf[qv_]:=Module[{qn=Normalize[qv]},2. ArcCos[Clip[Abs[qn[[1]]],{0.,1.}]]];
    maxAtt=Max[angleOf/@samples[[All,3]]];
    peakReq=Table[Norm/@rawControl[samples[[i]]],{i,Length[samples]}];
    peakApplied=Table[Norm/@actualControl[samples[[i]]],{i,Length[samples]}];
    maxReq=Max[Flatten[peakReq]];maxUsed=Max[Flatten[peakApplied]];
    saturation=AnyTrue[Flatten[peakReq],#>capacity+0.&];
    loadIndices=DeleteDuplicates[Round[Subdivide[1,Length[samples],Min[in["DynamicLoadPropagationSampleCount"],Length[samples]-1]]]];
    loadRecords=Table[Module[
      {state=samples[[ii]],lm,environmentalForces,icarusForces,totalPatchForces,areas,traction,
       localPressure,stationResultant},
      lm=phase1LoadMap[in,geo,mesh,dyn,actualControl[state]];
      environmentalForces=disturbanceState[sampleTimes[[ii]],state[[1]],state[[3]]][[3]];
      icarusForces=Lookup[lm["Patches"],"EstimatedLocalLoadVector_N"];
      totalPatchForces=MapThread[Plus,{icarusForces,environmentalForces}];
      areas=Lookup[mesh["Patches"],"SurfaceAreaWeight_m2"];
      traction=MapThread[Norm[#1]/#2&,{totalPatchForces,areas}];
      localPressure=Max[traction];stationResultant=Max[Norm/@icarusForces];
      <|"SampleIndex"->ii,"Time_s"->sampleTimes[[ii]],
        "PeakPatchResultantLoad_N"->Max[Norm/@totalPatchForces],
        "PeakICARUSPatchForce_N"->stationResultant,
        "PeakCombinedPatchTraction_Pa"->localPressure,"MaximumPatchTraction_Pa"->Max[traction],
        "ForceConservationResidual_N"->lm["ForceConservationResidual_N"],
        "MomentConservationResidual_Nm"->lm["MomentConservationResidual_Nm"]|>
    ],{ii,loadIndices}];
    peakLoadIndex=First@Ordering[Lookup[loadRecords,"PeakCombinedPatchTraction_Pa"],-1];
    peakLocalLoad=loadRecords[[peakLoadIndex]]["PeakPatchResultantLoad_N"];
    peakPatchTraction=loadRecords[[peakLoadIndex]]["PeakCombinedPatchTraction_Pa"];
    peakICARUSTraction=loadRecords[[peakLoadIndex]]["PeakICARUSPatchForce_N"];
    maxPatchTraction=Max[Lookup[loadRecords,"PeakCombinedPatchTraction_Pa"]];
    maxLoadMapResidual=Max[Lookup[loadRecords,"ForceConservationResidual_N"]];
    maxLoadMapMomentResidual=Max[Lookup[loadRecords,"MomentConservationResidual_Nm"]];
    peakState=samples[[loadRecords[[peakLoadIndex]]["SampleIndex"]]];
    loadMapAtPeak=phase1LoadMap[in,geo,mesh,dyn,actualControl[peakState]];
    peakEnvironmentalForces=disturbanceState[loadRecords[[peakLoadIndex]]["Time_s"],peakState[[1]],peakState[[3]]][[3]];
    peakICARUSForces=Lookup[loadMapAtPeak["Patches"],"EstimatedLocalLoadVector_N"];
    peakCombinedPatchForces=MapThread[Plus,{peakICARUSForces,peakEnvironmentalForces}];
    patchTractions=MapThread[Norm[#1]/#2&,{peakCombinedPatchForces,Lookup[mesh["Patches"],"SurfaceAreaWeight_m2"]}];
    structuralPressureLimit=Min[
      in["CircularMembraneDeflectionCoefficient"] in["MembranePretension_N_m"] in["MaximumDeflectionFractionOfRadius"]/geo["PlanformEquivalentRadius_m"],
      in["CircularMembraneDeflectionCoefficient"] in["MaximumDeflectionFractionOfRadius"] core["StructuralScreen"]["AllowablePretensionFromStrength_N_m"]/geo["PlanformEquivalentRadius_m"]
    ];
    structuralLoadPass=TrueQ[maxPatchTraction<=structuralPressureLimit];
    radialTol=in["RadialDeviationToleranceFractionOfRadius"] geo["PlanformEquivalentRadius_m"];
    lateralTol=in["LateralDeviationToleranceFractionOfRadius"] geo["PlanformEquivalentRadius_m"];
    velTol=in["VelocityRecoveryTolerance_m_s"];rateTol=in["AngularRateRecoveryTolerance_rad_s"];
    disturbanceEnd=Max[phase1FlareTimeBounds[in]["EndTime_s"],in["CMEOnset_s"]+in["CMEDuration_s"]];
    postIndices=Flatten@Position[Map[#>=disturbanceEnd&,sampleTimes],True];
    withinQ[i_Integer] := Module[{sample=samples[[i]],xx,vv,qq,ww},
      {xx,vv,qq,ww}=sample;
      Abs[xx[[1]]]<=radialTol && Norm[xx[[2;;3]]]<=lateralTol &&
      Abs[vv[[1]]]<=velTol && Norm[vv[[2;;3]]]<=velTol &&
      angleOf[qq]<=in["AttitudeTolerance_rad"] && Norm[ww]<=rateTol
    ];
    recoveryIndex=SelectFirst[postIndices,
      Function[index,And@@(withinQ/@Range[index,Length[samples]])],Missing["NotRecovered"]];
    recoveryTime=If[IntegerQ[recoveryIndex],sampleTimes[[recoveryIndex]]-disturbanceEnd,Infinity];
    struct=core["StructuralScreen"];
    quatNormError=Max[Abs[(Norm/@samples[[All,3]])-1.]];
    results=<|"Solution"->solutionAccessors,"ScalarComponentInterpolatingFunctions"->sol,
      "SampleTimes_s"->sampleTimes,"SampleStates"->samples,
      "RequiredStationForceMagnitudesBySample_N"->peakReq,
      "AppliedStationForceMagnitudesBySample_N"->peakApplied,
      "DynamicLoadPropagationRecords"->loadRecords,
      "PeakLocalMembraneLoad_N"->peakLocalLoad,
      "PeakCombinedPatchTraction_Pa"->peakPatchTraction,
      "MaximumCombinedPatchTraction_Pa"->maxPatchTraction,
      "PeakICARUSPatchForce_N"->peakICARUSTraction,
      "StructuralPressureLimitForDynamicLoads_Pa"->structuralPressureLimit,
      "DynamicStructuralLoadScreenPass"->structuralLoadPass,
      "PeakLocalMembraneLoadMapPatchForces"->Map[KeyTake[#,{"Position_m","PositionCOM_m","EstimatedLocalLoadVector_N"}]&,loadMapAtPeak["Patches"]],
      "PeakCombinedDynamicPatchLoadMap"->MapThread[<|"Position_m"->#1["Position_m"],
        "CombinedPatchForce_N"->#2,"CombinedPatchTraction_Pa"->#3|>&,{mesh["Patches"],peakCombinedPatchForces,patchTractions}],
      "PeakLoadMapSampleTime_s"->loadRecords[[peakLoadIndex]]["Time_s"],
      "MaximumLoadMapForceConservationResidual_N"->maxLoadMapResidual,
      "MaximumLoadMapMomentConservationResidual_Nm"->maxLoadMapMomentResidual,
      "DynamicICARUSLoadsPropagatedToCanopy"->True,
      "BaseAccelerationConsistencyResidual_m_s2"->baseAccelerationCrossCheck,
      "BaseAccelerationConsistencyRelativeError"->baseAccelerationCrossCheck/baseAccelerationScale,
      "BaseAccelerationConsistencyScale_m_s2"->baseAccelerationScale,
      "InitialStateAccelerationVector_m_s2"->initialStateAcceleration,
      "InitialStateAttitudeRotationVector_rad"->initialStateAttitude,
      "MaximumQuaternionNormalizationError"->quatNormError,
      "MaximumRadialDeviation_m"->maxRad,"MaximumLateralDeviation_m"->maxLat,
      "MaximumAttitudeDeviation_rad"->maxAtt,
      "MaximumRequiredStationForce_N"->maxReq,"MaximumAppliedStationForce_N"->maxUsed,
      "ICARUSCapacityPerStation_N"->capacity,"ICARUSSaturationOccurred"->saturation,
      "RadialDeviationWithinLimit"->TrueQ[maxRad<=radialTol],
      "LateralDeviationWithinLimit"->TrueQ[maxLat<=lateralTol],
      "AttitudeWithinLimit"->TrueQ[maxAtt<=in["AttitudeTolerance_rad"]],
      "ICARUSWithinCapacity"->TrueQ[maxReq<=capacity+0.],
      "DynamicLoadMapForceAndMomentConserved"->TrueQ[
        maxLoadMapResidual<=in["ICARUSLoadMapRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Abs[maxUsed]] &&
        maxLoadMapMomentResidual<=in["ICARUSLoadMapRelativeTolerance"] Max[Sqrt[$MinMachineNumber],Norm[loadMapAtPeak["StationMomentTotal_Nm"]]]],
      "RecoveryDisturbanceEnd_s"->disturbanceEnd,"RecoveryTime_s"->recoveryTime,
      "RecoveryWithinLimit"->TrueQ[recoveryTime<=in["RecoveryTimeMaximum_s"]],
      "RecoveryStateIncludesPositionVelocityAttitudeAndRate"->True,
      "RecoveryTimeResolution_s"->(ts/in["DynamicSampleCount"]),
      "StructuralScreenPass"->struct["StructuralScreenPass"],
      "RadiationForceAndTorqueDependOnCurrentAttitude"->True,
      "ICARUSBodyFrameForcesRotatedToInertialTranslation"->True,
      "Status"->"Integrated 3-D translation and quaternion/Euler rigid-body dynamics solved with thirteen scalar dependent functions; radiation forces/torques use current attitude and local position; CME projected loading, flare, albedo degradation and configured-station body-frame control are connected. Flexible deformation remains a first-order surrogate.",
      "ModelLimits"->"Rigid-body dynamics with patch-distributed mass/inertia and an approximate tensioned-membrane screen; no flexible-body FEM, thermal inertia or qualified actuator dynamics."|>
  ];
  phase1StoreResult["IntegratedSimulation",results];
  phase1Audit["IntegratedSimulationCompleted",KeyDrop[results,"Solution"]];
  results
];


(* ========================================================================
   7. VALIDATION, ACCEPTANCE, REPORT AND HANDOFF
   ======================================================================== *)

phase1ValidateCurrent[] := Module[{results=phase1EnsureCalculated[]},
  If[FailureQ[results],Return[results]];
  results["Validation"]
];

phase1RunSelfTestsCurrent[] := Module[{results=phase1EnsureCalculated[],validation,testNames,checks,failed,passed,notApplicable,feasibility,report,missingTests,approvedNotApplicable,unexpectedNonBoolean},
  If[FailureQ[results],Return[results]];
  validation=results["Validation"];
  testNames={"CentralInputSchemaComplete","AllCentralInputChecksPass","AllSelectedModelFormInputsSupported","SolarGravitationalParameterPositive",
    "SolarLuminosityNominalReferenceConsistencyCheck","PVScenarioOptionsValid","PVScenarioRecognized",
    "PVScenarioOutputIndependentRecalculation",
    "MITTemperatureAdjustedEfficiencyIndependentRecalculation",
    "IntegratedPVTemperatureAdjustedEfficiencyIndependentRecalculation",
    "ProjectTargetTemperatureAdjustedEfficiencyIndependentRecalculation",
    "FreeStandingSpecificPowerImpliedEfficiencyDoesNotExceedFreeStandingReference",
    "IntegratedSpecificPowerImpliedEfficiencyDoesNotExceedIntegratedReference",
    "PVSpecificPowerIrradianceScalingIndependentlyRecalculated",
    "ConditionedPowerIndependentRecalculation","PVTechnologyScenarioMassesIndependentlyRecalculated",
    "OpticalReflectorEnergyClosure","OpticalPVEnergyClosure",
    "WholeSurfaceOpticalEnergyConservation","PVFractionEnergyLedgerConnected","ReflectorEnergyLedgerConnected",
    "CoverageRange","DistancePositive","HeliocentricReferenceMotionModeSupported","HeliocentricStaticHoverVelocityValid",
    "GeometryMeshCurvedAreaConverges","MeshMomentumResolutionConverges",
    "NumericalVsAnalyticMomentumCoefficient","RadiationPatchForceIndependentRecalculation","RadiationTorqueIndependentRecalculation","PatchForceVsMomentumCoefficientCrossCheck","RadiationForceMassAccelerationCrossCheck",
    "ArealAndTotalForceAccelerationCrossCheck","DistributedGravityIndependentRecalculation","SolarWindForceIndependentRecalculation","SolarWindForceIncludedInEquilibrium",
    "NaturalTorqueIndependentRecalculation","NaturalVectorEquilibriumAtCurrentInputs",
    "NaturalTorqueEquilibriumAtCurrentInputs","ExactNaturalEquilibriumAtCurrentInputs",
    "EquilibriumRequiresMassAndVectorResidual",
    "PVTemperatureIndependentRecalculation","ReflectorTemperatureIndependentRecalculation",
    "PVThermalBalanceResidual","PVThermalCouplingConverged","ReflectorThermalBalanceResidual","PVOutputBelowAbsorbedEnergy",
    "PVSpecificPowerCapApplied","PVMassConsistentAcrossMassAndPowerLedgers",
    "TransferAndConditioningConnected","StationMassCountedOnce","StationCoordinatesWithinPlanform","MembraneSubstrateIncludedInMassLedger","PerimeterHardwareMassIncludedInMassLedger",
    "TotalMassComponentLedgerCloses","InertiaTensorPositive","DistributedMassConservation",
    "CenterOfMassFinite","QuaternionNormalized","ICARUSWrenchMatrixFullRank",
    "StructuralScreenCalculated","ICARUSCapacityUserInputNumeric","ICARUSWrenchAllocatorReconstructsDemand",
    "ICARUSLoadMapConservesStationForce","ICARUSLoadMapConservesStationMoment",
    "ICARUSPerStationLoadWeightsNormalize"};
  missingTests=Complement[testNames,Keys[validation]];
  checks=KeyTake[validation,Complement[testNames,missingTests]];
  approvedNotApplicable=<|"NumericalVsAnalyticMomentumCoefficient"->Missing["AnalyticFaceOnCheckNotApplicableAtTiltOrAttitude"]|>;
  notApplicable=Select[Keys[checks],KeyExistsQ[approvedNotApplicable,#]&&SameQ[checks[#],approvedNotApplicable[#]]&];
  unexpectedNonBoolean=Select[Keys[checks],!BooleanQ[checks[#]]&&!MemberQ[notApplicable,#]&];
  failed=Join[Select[Keys[checks],!TrueQ[checks[#]]&&!MemberQ[notApplicable,#]&],missingTests];
  passed=Select[Keys[checks],TrueQ[checks[#]]&];
  feasibility=<|"MassFeasible"->results["MassBalance"]["MassFeasible"],
    "NaturalVectorEquilibrium"->results["MassBalance"]["ExactVectorEquilibrium"],
    "NaturalTorqueEquilibrium"->results["MassBalance"]["ExactTorqueEquilibrium"],
    "ExactNaturalEquilibrium"->results["MassBalance"]["ExactNaturalEquilibrium"],
    "EquilibriumScope"->results["MassBalance"]["EquilibriumScope"],
    "WholeTwoPoleSystemEquilibriumEvaluated"->False,
    "ThermalLimitsWithinBounds"->results["Thermal"]["AllThermalLimitsWithinBounds"],
    "StaticStructuralScreenPass"->results["StructuralScreen"]["StructuralScreenPass"]|>;
  report=<|"TestCount"->Length[testNames],"ExpectedTestKeysPresent"->(missingTests==={}),
    "MissingTestKeys"->missingTests,"PassedCount"->Length[passed],
    "FailedCount"->Length[failed],"NotApplicableCount"->Length[notApplicable],
    "UnexpectedNonBooleanTestKeys"->unexpectedNonBoolean,
    "PassedTests"->passed,"FailedTests"->failed,"NotApplicableTests"->notApplicable,
    "NotApplicablePolicy"->"Only the face-on analytic momentum comparison may be not applicable, and only when the attitude/incidence condition explicitly returns its exact Missing reason. Every missing test key, False value, unexpected Missing, Failure or other non-Boolean result fails closed.",
    "EngineeringFeasibilityStatus"->feasibility,"Validation"->validation,
    "CodeSelfTestStatus"->If[failed==={},"All applicable calculation-integrity self-tests passed for this input snapshot.",
      "One or more calculation-integrity tests failed. Do not treat outputs as accepted until corrected."],
    "EngineeringStatus"->"Engineering feasibility is reported separately; a physically infeasible input case does not by itself indicate a software self-test failure."|>;
  phase1StoreResult["SelfTestReport",report]
];

phase1RunReportCurrent[] := Module[{results=phase1EnsureCalculated[],in=Phase1GetInputs[]},
  If[FailureQ[results],Return[results]];
  phase1StoreResult["RunReport",<|"Revision"->"v11.27 packaged two-pole independent calculation architecture",
    "GoverningObjective"->"Maximize delivered electrical power subject to independently evaluated natural force and torque equilibrium plus quantified operating/structural limits for each pole system. Shared design/material inputs are evaluated in two separate operating contexts; no inter-pole operating coupling is present.",
    "EquilibriumScope"->"One independently operated pole system; evaluated separately for Pole1 and Pole2.",
    "WholeTwoPoleSystemEquilibriumEvaluated"->False,
    "CentralInputCount"->Length[Keys[in]],"CentralInputRegister"->in,
    "SelectedSharedDesignMaterialModelForms"->KeyTake[in,{"PVLayoutModel","GeometryProfileModel","MassDistributionModel","ICARUSLoadTransferModel","MembraneStructuralModel","WobbleRestoringModel","ICARUSStationCountScope"}],
    "SelectedPoleSpecificEnvironmentAndReferenceMotionForms"->KeyTake[in,{"FlareTemporalProfile","CMETemporalProfile","HeliocentricReferenceMotionMode"}],
    "HeliocentricReferenceMotionScope"-><|"SelectedMode"->in["HeliocentricReferenceMotionMode"],
      "OrbitalPropagationImplemented"->False,"RotatingFrameCouplingImplemented"->False,
      "ReferenceVelocityRequirement_m_s"->{0.,0.,0.},
      "Rule"->"The explicitly selected Phase 1 mode is StaticHover. Each pole independently requires zero heliocentric reference velocity; local perturbation velocities are modeled separately. No Keplerian orbit propagation or rotating-frame coupling is implemented."|>,
    "SelectedPoleSpecificControllerSettings"->KeyTake[in,{"ControllerTranslationKp_perS2","ControllerTranslationKd_perS","ControllerAttitudeKp_perS2","ControllerAttitudeKd_perS"}],
    "OptimizerVariables"->{"Distance_m","PVFraction"},
    "OptimizerIndependentGridResolution"->{in["OptimizerGridPointCount"]+1,in["OptimizerCoverageGridPointCount"]+1},
    "OptionalInputSourceNotes"->$Phase1State["InputNotes"],
    "MissingRequiredInputProvenance"->{},
    "DefaultInputAudit"->phase1DefaultInputAudit[],
    "InputReadiness"->Phase1InputStatus[],
    "OptionalSourceNotes"-><|"SharedDesignAndMaterial"->Lookup[Phase1GetState[],"InputNotes",<||>]|>,
    "DerivedOutputs"->$Phase1State["Derived"],
    "CalculationOutputs"->results,
    "Validation"->results["Validation"],
    "CalculationManifest"->$Phase1State["LastRun"]["CalculationManifest"],
    "AuditLog"->$Phase1State["AuditLog"],
    "ExecutionStatement"->"This report is generated by Mathematica from the shared design/material register and the active pole's independent operating-input register. Pole1 and Pole2 execute in separate state, optional source notes, cache and result contexts. Only PoleCount = 2 is a project-specific default; all other project-specific values must be explicitly entered; source notes are optional.",
    "OverriddenReferenceConstantSourceNoteRequired"->False,
    "SourceNotesOptional"->True,
    "CachedValuesAreAcceptedOnlyForExactInputSnapshots"->True,
    "OptionalSourceNotesAffectCacheFreshness"->False,
    "CentralStateInputSnapshotHash"->$Phase1State["LastRun"]["InputSnapshotHash"],
    "CentralStateSnapshotMatchesCurrentInputs"->TrueQ[$Phase1State["LastRun"]["InputSnapshot"]===in],
    "CentralStateSnapshotHashMatchesCurrentInputs"->TrueQ[$Phase1State["LastRun"]["InputSnapshotHash"]===Hash[in,"SHA256"]]|>]
];

phase1Phase2HandoffCurrent[] := phase1StoreResult["Phase2Handoff",<|
  "Phase1Outputs"->{"Central numeric input/optional source notes and model-form register","Stored geometry and local surface mesh","Local optical closure and radiation force/moment quadrature","Independent analytic-versus-numerical momentum coefficient check","Nominal solar-parameter consistency calculations (GM-to-mass reconstruction is algebraic; luminosity-to-irradiance comparison checks nominal-reference consistency, not independent measurements)","Mass ledger including base membrane substrate, reflective coating, PV, wiring, separately modelled perimeter hardware, deferred mass and configured stations; integrated PV fabric overlap handled by an explicit central policy","Natural vector equilibrium residual","Four PV performance scenarios and delivered power ledger","Radiative thermal boundary and thermal residual","Configured-station wrench allocator and user-supplied per-station force capacity","Force- and moment-conserving station-to-membrane load mapping with dynamic patch-traction screening","Rigid-body quaternion/Euler free rotation and integrated 3-D simulation","Disturbance/degradation scenarios","Patch-pressure-driven selected membrane substrate tensioned-membrane structural screening calculation","Acceptance/validation manifest and audit history"},
  "Phase2MustReplaceOrValidate"->{"Actual deployed CAD/profile and material layup","Measured reflector/PV spectral R/A/T and diffuse reflectance","Qualified PV efficiency/temperature/radiation curve","Measured selected substrate/composite areal mass, modulus, strength, creep and fatigue","Nonlinear membrane/structural finite-element or validated reduced-order model","Measured ICARUS force/torque/stroke/bandwidth/power ratings","Distributed wiring, joints, perimeter and equipment masses","Thermal conduction, transient heat capacity, view factors and hot spots","Validated flare/CME/SEP histories","Full electrical topology, resistance, current/voltage and power electronics"},
  "DeferredByProjectInstruction"->{"Magnetron mass","Capacitor mass","Resistor/circuit mass","Detailed complete component mass distribution"},
  "HandoffStatus"->"Phase 1 performs internally connected numerical screening and reports user-input-driven results; no output is a flight qualification or accepted engineering design until Phase 2 replaces the stated approximations."|>];

phase1StabilityCriteriaCurrent[] := Module[{in,g,computed,result},
  computed=phase1EnsureCalculated[];
  If[FailureQ[computed],Return[computed]];
  in=Phase1GetInputs[];g=Lookup[$Phase1State["Derived"],"Geometry",Missing["GeometryUnavailable"]];
  If[!AssociationQ[g],Return[Failure["GeometryUnavailable",<||>]]];
  result=<|"RadialDeviationTolerance_m"->in["RadialDeviationToleranceFractionOfRadius"] g["PlanformEquivalentRadius_m"],
    "LateralDeviationTolerance_m"->in["LateralDeviationToleranceFractionOfRadius"] g["PlanformEquivalentRadius_m"],
    "AttitudeTolerance_rad"->in["AttitudeTolerance_rad"],"PVTemperatureLimit_K"->in["PVTemperatureLimit_K"],
    "ReflectorTemperatureLimit_K"->in["ReflectorTemperatureLimit_K"],
    "MaximumDeflectionFractionOfRadius"->in["MaximumDeflectionFractionOfRadius"],
    "MaximumRecoveryTime_s"->in["RecoveryTimeMaximum_s"],"ICARUSSaturationAllowed"->False,
    "AcceptanceRequiresExactForceAndTorqueEquilibrium"->True|>;
  phase1StoreResult["StabilityCriteria",result]
];

phase1RunFullAssessmentCurrent[] := Module[
  {base,originalInputs,originalProvenance,originalResults,eq,floor,disturbance,
   free,wobble,baselineDynamic,optimization,handoff,assessment,report,optimizedDynamic,
   stability,selfTests,rootFound=False,rootExact=False},
  base=Phase1ComputeAll[];
  If[FailureQ[base],Return[base]];
  originalInputs=Phase1GetInputs[];originalProvenance=Lookup[$Phase1State,"InputNotes",<||>];
  originalResults=Phase1GetResults[];
  eq=Phase1SolveExactEquilibrium[];
  If[FailureQ[eq],Return[eq]];
  rootFound=AssociationQ[eq] && KeyExistsQ[eq,"PVFraction"];
  rootExact=rootFound && TrueQ[Lookup[Lookup[eq,"MassBalance",<||>],"ExactNaturalEquilibrium",False]];
  (* Equilibrium roots are diagnostic only. The full assessment never changes PVFraction or distance. *)
  floor=Phase1DistanceThermalFloor[];If[FailureQ[floor],Return[floor]];
  disturbance=Phase1DisturbanceScenarios[];If[FailureQ[disturbance],Return[disturbance]];
  stability=Phase1StabilityCriteria[];If[FailureQ[stability],Return[stability]];
  selfTests=Phase1RunSelfTests[];If[FailureQ[selfTests],Return[selfTests]];
  free=Phase1FreeRotationTrajectory[];If[FailureQ[free],Return[free]];
  wobble=Phase1WobbleSimulation[];If[FailureQ[wobble],Return[wobble]];
  baselineDynamic=Phase1IntegratedSimulation[];If[FailureQ[baselineDynamic],Return[baselineDynamic]];
  optimization=Phase1JointOptimization[];If[FailureQ[optimization],Return[optimization]];
  optimizedDynamic=If[AssociationQ[optimization],Lookup[optimization,"DynamicSimulation",Missing["NoOptimizedDynamicRun"]],Missing["NoOptimizedDynamicRun"]];
  handoff=Phase1Phase2Handoff[];
  assessment=<|"Revision"->"v11.27 centralized full assessment",
    "OriginalInputSnapshot"->originalInputs,"OriginalInputProvenanceSnapshot"->originalProvenance,
    "OriginalCalculationOutputs"->originalResults,"ExactEquilibriumDiagnosticSolve"->eq,
    "ThermalDistanceFloor"->floor,"DisturbanceScenarios"->disturbance,
    "StabilityCriteria"->stability,"SelfTests"->selfTests,"FreeRotationTrajectory"->free,"WobbleSimulation"->wobble,
    "BaselineIntegratedSimulation"->baselineDynamic,
    "JointOptimization"->optimization,"OptimizedIntegratedSimulation"->optimizedDynamic,
    "Phase2Handoff"->handoff,"FinalInputSnapshot"->Phase1GetInputs[],
    "EquilibriumRootWasFound"->rootFound,"EquilibriumRootPassedExactNaturalEquilibrium"->rootExact,
    "EquilibriumDiagnosticRootAppliedToActiveInputs"->False,
    "WholeTwoPoleSystemEquilibriumEvaluated"->False,
    "WholeTwoPoleSystemEquilibriumQualification"->"Not a coupled equilibrium problem: the two pole systems are operationally independent by governing architecture. Each pole is evaluated separately; only scalar outputs are summed.",
    "OptimizerCandidateApplicationPolicy"->"Optimizer candidates are recalculated and dynamically evaluated within temporary per-pole input snapshots; no candidate is automatically applied or retained in live inputs.",
    "OptimizerCandidateAppliedToLiveInputs"->False,
    "RadialOrTorqueUnbalancedRootWasAppliedAsEquilibrium"->False,
    "CalculationDataFlow"->"All numerical outputs are generated in Wolfram Language from shared design/material inputs and this pole's independent operating-input register. Each pole has its own state, controller, disturbances, dynamics, cache and results. No operating state or force is exchanged between poles. Aggregate mass and power are arithmetic sums of the two independently calculated outputs."|>;
  phase1StoreResult["FullAssessment",assessment];
  report=Phase1RunReport[];
  <|"Assessment"->assessment,"RunReport"->report,"FinalState"->Phase1GetState[]|>
];

(* ========================================================================
   8. INTERACTIVE PANEL — UI writes to the same central input register
   ======================================================================== *)

Phase1InteractivePanel[] := DynamicModule[
  {working=Phase1GetInputs[],sources=Lookup[$Phase1State,"InputNotes",<||>],
   result=Missing["NotRun"],missing,projectKeys,sourceUpdates},
  projectKeys=phase1ProjectInputKeys[];
  sources=AssociationThread[projectKeys,Table[Lookup[sources,key,""],{key,projectKeys}]];
  Column[{
    Style["PHASE 1 — POLAR COLLECTOR / v11.27",Bold],
    Style["Enter all missing project, model, acceptance and numerical-control values in SI units where applicable. Source notes are optional; no unprovided design/material values are prefilled."],
    Dynamic[missing=Phase1InputStatus[];
      If[TrueQ[missing["Ready"]],Style["Required input values are complete.",Darker[Green]],
        Style["Missing values: "<>ToString[Length[missing["MissingRequiredInputKeys"]]],Darker[Red]]]],
    Pane[Dynamic@Grid[Prepend[
      Table[{key,InputField[Dynamic[working[key]]],InputField[Dynamic[sources[key]]]},
        {key,projectKeys}],
      {"Project input key","Value (SI units)","Optional source note"}],
      Alignment->Left],Scrollbars->{False,True}],
    Row[{
      Button["Apply inputs and optional source notes",
        sourceUpdates=Association@Select[Normal[sources],StringQ[Last[#]]&&StringTrim[Last[#]]=!=""&];
        result=Phase1SetInputs[Association@KeyTake[working,projectKeys],sourceUpdates],Method->"Queued"],
      Button["Reload from central register",
        working=Phase1GetInputs[];sources=AssociationThread[projectKeys,Table[Lookup[Lookup[$Phase1State,"InputNotes",<||>],key,""],{key,projectKeys}]],Method->"Queued"],
      Button["Recalculate all model outputs",result=Phase1ComputeAll[],Method->"Queued"],
      Button["Run validation tests",result=Phase1RunSelfTests[],Method->"Queued"]
    }],
    Dynamic[If[FailureQ[result],Style[ToString[result,InputForm],Darker[Red]],
      If[MissingQ[result],"",Style["Last action completed. Check the returned report for its detailed status.",Darker[Green]]]]]
  }]
];

(* ========================================================================
   9. TWO-POLE INDEPENDENT-SYSTEM ARCHITECTURE — v11.27

   Governing two-pole rule (user-specified):
     Pole1 and Pole2 are separate physical operating systems. They share only
     design and material definitions. Each has its own operating inputs,
     operating environment, initial conditions, event profiles, controller gains and state, dynamics, force/torque calculations, result cache and acceptance
     results. During an individual pole calculation, the other pole's operating
     inputs, environment, state, cache and results are inaccessible. No force,
     torque, power, control command, state or disturbance is transferred between
     poles. Immutable physical constants and mathematical/numerical-method
     definitions are common code references, not exchanged operating data.

     Both systems are computed independently. Only after both calculations finish
     may scalar mass, area and electrical power be summed for reporting. That
     reporting-only aggregation does not feed either system's operation. No
     per-pole value is multiplied by PoleCount to stand in for the other pole.
     No combined mechanical equilibrium is imposed.

   PoleCount = 2 is the sole project-specific default. Pole1/Pole2 are neutral
   system identifiers; no north/south orientation is inferred.
   ======================================================================== *)

(* Public API symbols and implementation helpers were initialized by the package header. *)



$Phase1PoleIDs = {"Pole1", "Pole2"};
$Phase1PoleOperatingKeys = {
  "Distance_m", "DistanceSearchRange_m",
  "InitialPositionLocal_m", "InitialVelocityLocal_m_s",
  "InitialVelocityHeliocentric_m_s", "HeliocentricReferenceMotionMode", "InitialAttitudeSmallAngles_rad",
  "InitialAngularVelocity_rad_s", "IncidenceAngle_deg",
  "FlarePeakFraction", "FlarePeakTime_s", "FlareDuration_s", "FlareTailCutoffFraction", "FlareTemporalProfile",
  "CMEOnset_s", "CMEWindPressureMultiplier", "CMEDuration_s", "CMETemporalProfile",
  "ControllerTranslationKp_perS2", "ControllerTranslationKd_perS", "ControllerAttitudeKp_perS2", "ControllerAttitudeKd_perS",
  "SolarWindProtonDensity_1AU_cm3", "SolarWindSpeed_1AU_m_s",
  "SEPDose_protons_cm2", "ReferenceMissionYears", "DynamicCheckDuration_s"
};
$Phase1OriginalDefaults = $Phase1DefaultInputs;
$Phase1PoleInputDefaults = KeyTake[$Phase1OriginalDefaults, $Phase1PoleOperatingKeys];
$Phase1DefaultInputs = KeyDrop[$Phase1DefaultInputs, $Phase1PoleOperatingKeys];

(* Move operating fields out of the shared Inputs association into separate pole maps. *)
$Phase1State = Join[$Phase1State, <|
  "SchemaVersion" -> $Phase1ModelVersion,
  "Inputs" -> KeyDrop[$Phase1State["Inputs"], $Phase1PoleOperatingKeys],
  "InputNotes" -> KeyDrop[Lookup[$Phase1State, "InputNotes", <||>], $Phase1PoleOperatingKeys],
  "PoleOperatingInputs" -> AssociationThread[$Phase1PoleIDs, ConstantArray[$Phase1PoleInputDefaults, Length[$Phase1PoleIDs]]],
  "PoleOperatingNotes" -> AssociationThread[$Phase1PoleIDs, ConstantArray[<||>, Length[$Phase1PoleIDs]]],
  "PoleStates" -> <||>,
  "LegacyInputArchive" -> <||>,
  "TwoPoleAggregate" -> <||>,
  "PoleArchitectureRule" -> "There are two physically distinct systems, one installed at each pole. Their design and material definitions are shared; their operation is completely independent. Each pole has its own operating inputs, local environment and disturbance history, initial conditions, forces, torques, controllers, dynamics, stored state, caches, results, optimization and acceptance decisions. No operating state, force, torque, power, control command, disturbance, environment state or calculated operating output is exchanged, coupled, combined or used as an input between poles. Immutable physical constants and common mathematical/numerical algorithms are common definitions, not shared operating states. Scalar outputs may be arithmetically summed only after both calculations finish and only for reporting; aggregate results never feed either pole's operation. No combined mechanical equilibrium is imposed. Each pole uses its own local Sun-radial +x coordinate basis; no common global position/orientation is inferred.",
  "ActivePole" -> Missing["NoActivePole"]
|>];

$Phase1ExecutingPole = False;
$Phase1CurrentPole = None;
$Phase1SelectedPole = "Pole1";

(* Input readiness depends on required values only. Optional notes are metadata. *)
phase1ProjectInputKeys[] := DeleteDuplicates[Join[Keys[$Phase1DefaultInputs],
  If[TrueQ[$Phase1ExecutingPole], $Phase1PoleOperatingKeys, {}]]];
phase1ProvenanceRequiredKeys[] := {};

phase1PoleInputStatus[pole_String] := Module[{inputs, missing},
  If[!MemberQ[$Phase1PoleIDs, pole],
    Return[Failure["UnknownPoleID", <|"Pole" -> pole, "ValidPoleIDs" -> $Phase1PoleIDs|>]]
  ];
  inputs = Join[$Phase1State["Inputs"], Lookup[$Phase1State["PoleOperatingInputs"], pole, <||>]];
  missing = Select[Keys[inputs], MissingQ[Lookup[inputs, #, Missing[]]] &];
  <|"Pole" -> pole, "Ready" -> (missing === {}),
    "MissingRequiredInputKeys" -> missing,
    "OptionalSourceNotesMissing" -> {},
    "InputCount" -> Length[inputs], "MissingRequiredInputCount" -> Length[missing],
    "SourceNotesOptional" -> True|>
];

Phase1MissingRequiredInputs[] := If[TrueQ[$Phase1ExecutingPole],
  Select[Keys[$Phase1State["Inputs"]], MissingQ[Lookup[$Phase1State["Inputs"], #, Missing[]]] &],
  Join[
    Select[Keys[$Phase1State["Inputs"]], MissingQ[Lookup[$Phase1State["Inputs"], #, Missing[]]] &],
    Flatten[Table[(pole <> "::" <> #) & /@
      Select[phase1PoleInputStatus[pole]["MissingRequiredInputKeys"],
        MemberQ[$Phase1PoleOperatingKeys, #] &], {pole, $Phase1PoleIDs}]]
  ]
];
Phase1MissingRequiredProvenance[] := {};

Phase1InputStatus[pole_String] := If[TrueQ[$Phase1ExecutingPole] && pole =!= $Phase1CurrentPole,
  Failure["CrossPoleStatusReadBlocked", <|"ActivePole" -> $Phase1CurrentPole, "RequestedPole" -> pole|>],
  phase1PoleInputStatus[pole]];

Phase1InputStatus[] := If[TrueQ[$Phase1ExecutingPole],
  Module[{status = phase1PoleInputStatus[$Phase1CurrentPole]},
    Join[status, <|"ActivePole" -> $Phase1CurrentPole|>]],
  Module[{sharedMissing, poleStatus, allMissing},
    sharedMissing = Select[Keys[$Phase1State["Inputs"]],
      MissingQ[Lookup[$Phase1State["Inputs"], #, Missing[]]] &];
    poleStatus = AssociationMap[phase1PoleInputStatus, $Phase1PoleIDs];
    allMissing = Join[sharedMissing,
      Flatten[Table[(pole <> "::" <> #) & /@
        Select[poleStatus[pole]["MissingRequiredInputKeys"], MemberQ[$Phase1PoleOperatingKeys, #] &],
        {pole, $Phase1PoleIDs}]]];
    <|"Ready" -> (allMissing === {}), "MissingRequiredInputKeys" -> allMissing,
      "OptionalSourceNotesMissing" -> {},
      "SharedInputCount" -> Length[$Phase1State["Inputs"]],
      "PoleOperatingInputCountPerPole" -> Length[$Phase1PoleOperatingKeys],
      "PoleStatuses" -> poleStatus, "SourceNotesOptional" -> True|>
  ]
];

Phase1InputRequirements[] := Module[{status = Phase1InputStatus[]},
  <|"Ready" -> TrueQ[status["Ready"]],
    "SharedDesignMaterialInputCategories" -> $Phase1InputCategories,
    "PoleOperatingInputCategories" -> $Phase1PoleOperatingInputCategories,
    "MissingRequiredInputKeys" -> status["MissingRequiredInputKeys"],
    "OptionalSourceNotesMissing" -> {},
    "SourceNotesOptional" -> True,
    "SourceNotesAreOptional" -> True,
    "Rule" -> "Required project values must be entered before calculation. Source notes can be recorded but do not gate execution."|>
];

Phase1GetSharedInputs[] := KeyDrop[$Phase1State["Inputs"], $Phase1PoleOperatingKeys];
Phase1GetInputs[] := $Phase1State["Inputs"];
Phase1GetInput[name_String] := If[TrueQ[$Phase1ExecutingPole],
  Lookup[$Phase1State["Inputs"], name, Missing["UnknownInput", name]],
  If[MemberQ[$Phase1PoleOperatingKeys, name],
    AssociationMap[Lookup[Lookup[$Phase1State["PoleOperatingInputs"], #, <||>], name, Missing["UnknownInput", name]] &, $Phase1PoleIDs],
    Lookup[$Phase1State["Inputs"], name, Missing["UnknownInput", name]]]];
Phase1GetPoleInputs[pole_String] := Which[
  TrueQ[$Phase1ExecutingPole] && pole =!= $Phase1CurrentPole, Failure["CrossPoleInputReadBlocked", <|"ActivePole" -> $Phase1CurrentPole, "RequestedPole" -> pole|>],
  !MemberQ[$Phase1PoleIDs, pole], Failure["UnknownPoleID", <|"Pole" -> pole, "ValidPoleIDs" -> $Phase1PoleIDs|>],
  True, Join[KeyDrop[$Phase1State["Inputs"], $Phase1PoleOperatingKeys], Lookup[$Phase1State["PoleOperatingInputs"], pole, <||>]]];

(* Shared design/material changes invalidate both calculation caches, but do not
   modify either pole's operating inputs. PoleCount is fixed at the user-confirmed 2. *)
Phase1SetInputs[updates_Association] := Phase1SetInputs[updates, <||>];
Phase1SetInputs[updates_Association, sourceNotes_Association] := Module[
  {current, unknown, oldNotes, changed, cleanNotes, staleNotes, newNotes, cacheChanged},
  If[TrueQ[$Phase1ExecutingPole],
    Return[Failure["SharedInputsLockedDuringPoleExecution",
      <|"Reason" -> "A pole calculation cannot mutate shared design/material inputs."|>]]
  ];
  current = $Phase1State["Inputs"];
  unknown = Complement[Keys[updates], Keys[current]];
  If[unknown =!= {},
    Return[Failure["UnknownOrPoleSpecificInputKeys",
      <|"Keys" -> unknown, "Use" -> "Phase1SetPoleOperatingInputs[pole, values] for pole-specific values."|>]]
  ];
  If[KeyExistsQ[updates, "PoleCount"] && updates["PoleCount"] =!= 2,
    Return[Failure["PoleCountIsFixedAtTwo", <|"PoleCount" -> 2|>]]
  ];
  oldNotes = Lookup[$Phase1State, "InputNotes", <||>];
  changed = Select[Keys[updates], !SameQ[Lookup[current, #, Missing[]], updates[#]] &];
  cleanNotes = Association @ Select[Normal @ KeyTake[sourceNotes, Keys[current]],
    StringQ[Last[#]] && StringTrim[Last[#]] =!= "" &];
  staleNotes = Select[changed, !KeyExistsQ[cleanNotes, #] &];
  newNotes = Join[KeyDrop[oldNotes, staleNotes], cleanNotes];
  cacheChanged = changed =!= {};
  $Phase1State = Join[$Phase1State, <|
    "Inputs" -> Join[current, updates], "InputNotes" -> newNotes,
    "PoleStates" -> If[cacheChanged, <||>, Lookup[$Phase1State, "PoleStates", <||>]],
    "TwoPoleAggregate" -> If[cacheChanged, <||>, Lookup[$Phase1State, "TwoPoleAggregate", <||>]]
  |>];
  phase1Audit["SharedDesignMaterialInputsUpdated", <|"ChangedKeys" -> changed,
    "OptionalSourceNotesUpdated" -> Keys[cleanNotes],
    "CalculationCachesInvalidated" -> cacheChanged,
    "BothPoleCalculationCachesInvalidated" -> cacheChanged|>];
  $Phase1State["Inputs"]
];
Phase1SetInputProvenance[notes_Association] := Phase1SetInputs[<||>, notes];

Phase1SetPoleOperatingInputs[pole_String, updates_Association] :=
  Phase1SetPoleOperatingInputs[pole, updates, <||>];
Phase1SetPoleOperatingInputs[pole_String, updates_Association, sourceNotes_Association] := Module[
  {current, oldNotes, unknown, changed, cleanNotes, staleNotes, newNotes, poleStates, cacheChanged},
  If[!MemberQ[$Phase1PoleIDs, pole],
    Return[Failure["UnknownPoleID", <|"Pole" -> pole, "ValidPoleIDs" -> $Phase1PoleIDs|>]]
  ];
  If[TrueQ[$Phase1ExecutingPole],
    Return[Failure["PoleInputsLockedDuringPoleExecution",
      <|"Reason" -> "Operating inputs cannot be mutated while a pole calculation is running."|>]]
  ];
  unknown = Complement[Keys[updates], $Phase1PoleOperatingKeys];
  If[unknown =!= {}, Return[Failure["NotPoleOperatingInputKeys", <|"Pole" -> pole, "Keys" -> unknown|>]]];
  current = Lookup[$Phase1State["PoleOperatingInputs"], pole, $Phase1PoleInputDefaults];
  oldNotes = Lookup[Lookup[$Phase1State, "PoleOperatingNotes", <||>], pole, <||>];
  changed = Select[Keys[updates], !SameQ[Lookup[current, #, Missing[]], updates[#]] &];
  cleanNotes = Association @ Select[Normal @ KeyTake[sourceNotes, $Phase1PoleOperatingKeys],
    StringQ[Last[#]] && StringTrim[Last[#]] =!= "" &];
  staleNotes = Select[changed, !KeyExistsQ[cleanNotes, #] &];
  newNotes = Join[KeyDrop[oldNotes, staleNotes], cleanNotes];
  cacheChanged = changed =!= {};
  poleStates = Lookup[$Phase1State, "PoleStates", <||>];
  $Phase1State = Join[$Phase1State, <|
    "PoleOperatingInputs" -> Join[Lookup[$Phase1State, "PoleOperatingInputs", <||>],
      <|pole -> Join[current, updates]|>],
    "PoleOperatingNotes" -> Join[Lookup[$Phase1State, "PoleOperatingNotes", <||>],
      <|pole -> newNotes|>],
    "PoleStates" -> If[cacheChanged, KeyDrop[poleStates, {pole}], poleStates],
    "TwoPoleAggregate" -> If[cacheChanged, <||>, Lookup[$Phase1State, "TwoPoleAggregate", <||>]]
  |>];
  phase1Audit["PoleOperatingInputsUpdated", <|"Pole" -> pole, "ChangedKeys" -> changed,
    "OptionalSourceNotesUpdated" -> Keys[cleanNotes],
    "CalculationCacheInvalidated" -> cacheChanged,
    "OtherPoleInputAndCacheUnchanged" -> True|>];
  Lookup[$Phase1State["PoleOperatingInputs"], pole]
];
Phase1SetPoleOperatingInputProvenance[pole_String, notes_Association] :=
  Phase1SetPoleOperatingInputs[pole, <||>, notes];


phase1BuildPoleLocalState[pole_String] := Module[{parent = $Phase1State, prior, op, opSources, sharedSnapshotOK},
  op = Lookup[parent["PoleOperatingInputs"], pole, $Phase1PoleInputDefaults];
  opSources = Lookup[parent["PoleOperatingNotes"], pole, <||>];
  prior = Lookup[Lookup[parent, "PoleStates", <||>], pole, <||>];
  sharedSnapshotOK = AssociationQ[prior] &&
    SameQ[Lookup[prior, "SharedInputSnapshot", Missing[]], parent["Inputs"]];
  If[!TrueQ[sharedSnapshotOK], prior = <||>];
  Join[parent, <|
    (* The legacy single-system calculation core checks 11.9 internally; the legacy single-system calculation core still checks schema 11.9 internally. *)
    "SchemaVersion" -> "11.9",
    "Inputs" -> Join[parent["Inputs"], op],
    "InputNotes" -> Join[Lookup[parent, "InputNotes", <||>], opSources],
    "PoleOperatingInputs" -> <|pole -> op|>,
    "PoleOperatingNotes" -> <|pole -> opSources|>,
    "PoleStates" -> <|pole -> prior|>,
    "TwoPoleAggregate" -> <||>,
    "Derived" -> Lookup[prior, "Derived", <||>],
    "Results" -> Lookup[prior, "Results", <||>],
    "LastRun" -> Lookup[prior, "LastRun", Missing["NotRun"]],
    "AuditLog" -> Lookup[prior, "AuditLog", {}],
    "ActivePole" -> pole,
    "PoleExecutionActive" -> True
  |>]
];

SetAttributes[phase1WithPole, HoldAll];
phase1WithPole[pole_String, expr_] := Module[{local, result = $Failed, finalLocal = <||>, parent, poleRecord, op, opSources, localIsolationQ, otherStatesBefore, otherStatesAfter},
  If[!MemberQ[$Phase1PoleIDs, pole], Return[Failure["UnknownPoleID", <|"Pole" -> pole, "ValidPoleIDs" -> $Phase1PoleIDs|>]]];
  If[TrueQ[$Phase1ExecutingPole],
    If[pole === $Phase1CurrentPole, Return[expr],
      Return[Failure["NestedCrossPoleExecutionBlocked", <|"ActivePole" -> $Phase1CurrentPole, "RequestedPole" -> pole|>]]]];
  parent = $Phase1State; local = phase1BuildPoleLocalState[pole];
  Block[{$Phase1State = local, $Phase1ExecutingPole = True, $Phase1CurrentPole = pole},
    result = expr; finalLocal = $Phase1State;
  ];
  op = Lookup[parent["PoleOperatingInputs"], pole, $Phase1PoleInputDefaults];
  opSources = Lookup[parent["PoleOperatingNotes"], pole, <||>];
  localIsolationQ = TrueQ[
    Keys[Lookup[finalLocal,"PoleOperatingInputs",<||>]]==={pole} &&
    Keys[Lookup[finalLocal,"PoleOperatingNotes",<||>]]==={pole} &&
    Keys[Lookup[finalLocal,"PoleStates",<||>]]==={pole} &&
    SameQ[KeyTake[Lookup[finalLocal,"Inputs",<||>],$Phase1PoleOperatingKeys],op]
  ];
  If[!localIsolationQ, Return[Failure["PoleContextIsolationCheckFailed",<|"Pole"->pole,"LocalPoleInputAndStateKeys"-><|"OperatingInputs"->Keys[Lookup[finalLocal,"PoleOperatingInputs",<||>]],"OperatingProvenance"->Keys[Lookup[finalLocal,"PoleOperatingNotes",<||>]],"PoleStates"->Keys[Lookup[finalLocal,"PoleStates",<||>]]|>,"NoParentStateCommitted"->True|>]]];
  otherStatesBefore=KeyDrop[Lookup[parent,"PoleStates",<||>],{pole}];
  poleRecord = <|
    "Pole" -> pole, "OperatingInputs" -> op, "OperatingProvenance" -> opSources,
    "SharedInputSnapshot" -> parent["Inputs"],
    "SharedProvenanceSnapshot" -> Lookup[parent, "InputNotes", <||>],
    "Derived" -> Lookup[finalLocal, "Derived", <||>],
    "Results" -> Lookup[finalLocal, "Results", <||>],
    "LastRun" -> Lookup[finalLocal, "LastRun", Missing["NotRun"]],
    "AuditLog" -> Lookup[finalLocal, "AuditLog", {}],
    "InputSnapshot" -> Lookup[finalLocal, "Inputs", <||>],
    "OptionalSourceNotesSnapshot" -> Lookup[finalLocal, "InputNotes", <||>],
    "LocalPoleIsolationPassed" -> localIsolationQ,
    "LastExecutionResult" -> If[FailureQ[result], result, "CompletedOrReturnedValue"]
  |>;
  $Phase1State = Join[parent, <|
    "PoleStates" -> Join[Lookup[parent, "PoleStates", <||>], <|pole -> poleRecord|>],
    "ActivePole" -> pole,
    "AuditLog" -> Append[Lookup[parent, "AuditLog", {}],
      <|"Action" -> "IndependentPoleContextCompleted", "Pole" -> pole,
        "ResultWasFailure" -> FailureQ[result], "LocalPoleIsolationPassed" -> localIsolationQ,
        "OtherPoleStateModified" -> !SameQ[otherStatesBefore,KeyDrop[Lookup[$Phase1State,"PoleStates",<||>],{pole}]]|>]|>];
  otherStatesAfter=KeyDrop[Lookup[$Phase1State,"PoleStates",<||>],{pole}];
  If[!SameQ[otherStatesBefore,otherStatesAfter], Return[Failure["OtherPoleStateChangedDuringExecution",<|"ActivePole"->pole,"NoIndependentResultCommitted"->False|>]]];
  result
];

Phase1GetPoleState[pole_String] := Which[
  TrueQ[$Phase1ExecutingPole] && pole =!= $Phase1CurrentPole, Failure["CrossPoleStateReadBlocked", <|"ActivePole" -> $Phase1CurrentPole, "RequestedPole" -> pole|>],
  !MemberQ[$Phase1PoleIDs, pole], Failure["UnknownPoleID", <|"Pole" -> pole|>],
  True, Lookup[Lookup[$Phase1State, "PoleStates", <||>], pole, Missing["PoleNotYetComputed", pole]]];
Phase1GetPoleResults[pole_String] := Module[{s = Phase1GetPoleState[pole]},
  If[AssociationQ[s], Lookup[s, "Results", <||>], s]];
Phase1GetPoleResult[pole_String, name_String] := Module[{r = Phase1GetPoleResults[pole]},
  If[AssociationQ[r], Lookup[r, name, Missing["PoleResultNotAvailable", {pole, name}]], r]];
Phase1GetPoleDerived[pole_String, name_String] := Module[{s = Phase1GetPoleState[pole], d},
  If[!AssociationQ[s], Return[s]]; d = Lookup[s, "Derived", <||>];
  Lookup[d, name, Missing["PoleDerivedValueNotAvailable", {pole, name}]]];

Phase1ComputePole[pole_String] := phase1WithPole[pole, phase1EnsureCalculated[]];

(* Runtime architecture audit. This uses a temporary Block-local copy of the central
   state, writes a sentinel to Pole1 only, and confirms Pole2 operating inputs/state are
   unchanged. It also probes public cross-pole read guards without changing live state. *)
Phase1PoleIndependenceAudit[] := Module[
  {stateSnapshot=$Phase1State, op1Before, op2Before, state1Before, state2Before, source1Before, source2Before, sharedBefore,
   sentinel1, sentinel2, setterProbe, reverseSetterProbe, pole1After, pole2After, state1After, state2After,
   source1After, source2After, sharedAfter, crossInputProbe, crossStateProbe, reverseCrossInputProbe,
   reverseCrossStateProbe, local1, local2, localIsolation, sharedKeys,
   aggregateProbeState, aggregateProbe, aggregateProbeUnchanged, checks},
  op1Before=Lookup[stateSnapshot["PoleOperatingInputs"],"Pole1",<||>];
  op2Before=Lookup[stateSnapshot["PoleOperatingInputs"],"Pole2",<||>];
  state1Before=Lookup[stateSnapshot["PoleStates"],"Pole1",Missing["NoPole1State"]];
  state2Before=Lookup[stateSnapshot["PoleStates"],"Pole2",Missing["NoPole2State"]];
  source1Before=Lookup[stateSnapshot["PoleOperatingNotes"],"Pole1",<||>];
  source2Before=Lookup[stateSnapshot["PoleOperatingNotes"],"Pole2",<||>];
  sharedBefore=Lookup[stateSnapshot,"Inputs",<||>];
  sentinel1=Unique["Pole1IsolationSentinel$"];
  sentinel2=Unique["Pole2IsolationSentinel$"];
  setterProbe=Block[{$Phase1State=stateSnapshot,$Phase1ExecutingPole=False,$Phase1CurrentPole=None},
    Phase1SetPoleOperatingInputs["Pole1",<|"Distance_m"->sentinel1|>,<|"Distance_m"->"Temporary internal isolation self-test sentinel; not a project value"|>];
    $Phase1State
  ];
  pole1After=Lookup[Lookup[setterProbe,"PoleOperatingInputs",<||>],"Pole1",<||>];
  pole2After=Lookup[Lookup[setterProbe,"PoleOperatingInputs",<||>],"Pole2",<||>];
  state1After=Lookup[Lookup[setterProbe,"PoleStates",<||>],"Pole1",Missing["NoPole1State"]];
  state2After=Lookup[Lookup[setterProbe,"PoleStates",<||>],"Pole2",Missing["NoPole2State"]];
  source1After=Lookup[Lookup[setterProbe,"PoleOperatingNotes",<||>],"Pole1",<||>];
  source2After=Lookup[Lookup[setterProbe,"PoleOperatingNotes",<||>],"Pole2",<||>];
  sharedAfter=Lookup[setterProbe,"Inputs",<||>];
  reverseSetterProbe=Block[{$Phase1State=stateSnapshot,$Phase1ExecutingPole=False,$Phase1CurrentPole=None},
    Phase1SetPoleOperatingInputs["Pole2",<|"Distance_m"->sentinel2|>,<|"Distance_m"->"Temporary internal reverse-direction isolation self-test sentinel; not a project value"|>];
    $Phase1State
  ];
  crossInputProbe=Block[{$Phase1State=stateSnapshot,$Phase1ExecutingPole=False,$Phase1CurrentPole=None},
    phase1WithPole["Pole1",Phase1GetPoleInputs["Pole2"]]
  ];
  crossStateProbe=Block[{$Phase1State=stateSnapshot,$Phase1ExecutingPole=False,$Phase1CurrentPole=None},
    phase1WithPole["Pole1",Phase1GetPoleState["Pole2"]]
  ];
  reverseCrossInputProbe=Block[{$Phase1State=stateSnapshot,$Phase1ExecutingPole=False,$Phase1CurrentPole=None},
    phase1WithPole["Pole2",Phase1GetPoleInputs["Pole1"]]
  ];
  reverseCrossStateProbe=Block[{$Phase1State=stateSnapshot,$Phase1ExecutingPole=False,$Phase1CurrentPole=None},
    phase1WithPole["Pole2",Phase1GetPoleState["Pole1"]]
  ];
  local1=phase1BuildPoleLocalState["Pole1"];
  local2=phase1BuildPoleLocalState["Pole2"];
  sharedKeys=Keys[KeyDrop[stateSnapshot["Inputs"],$Phase1PoleOperatingKeys]];
  {aggregateProbe,aggregateProbeUnchanged}=Block[{$Phase1State=stateSnapshot},
    aggregateProbeState=$Phase1State;
    aggregateProbe=phase1PoleAggregate[<|
      "Pole1"-><|"MassBalance"-><|"TotalMass_kg"->1.|>,"PowerLedger"-><|"ConditionedDeliveredPower_W_PerPole"->2.|>|>,
      "Pole2"-><|"MassBalance"-><|"TotalMass_kg"->3.|>,"PowerLedger"-><|"ConditionedDeliveredPower_W_PerPole"->4.|>|>
    |>];
    {aggregateProbe,SameQ[$Phase1State,aggregateProbeState]}
  ];
  localIsolation=TrueQ[
    Keys[Lookup[local1,"PoleOperatingInputs",<||>]]==={"Pole1"} &&
    Keys[Lookup[local2,"PoleOperatingInputs",<||>]]==={"Pole2"} &&
    Keys[Lookup[local1,"PoleStates",<||>]]==={"Pole1"} &&
    Keys[Lookup[local2,"PoleStates",<||>]]==={"Pole2"} &&
    SameQ[KeyTake[local1["Inputs"],$Phase1PoleOperatingKeys],op1Before] &&
    SameQ[KeyTake[local2["Inputs"],$Phase1PoleOperatingKeys],op2Before] &&
    SameQ[KeyDrop[local1["Inputs"],$Phase1PoleOperatingKeys],KeyDrop[local2["Inputs"],$Phase1PoleOperatingKeys]]
  ];
  checks=<|
    "ExactlyTwoPoleSystems"->TrueQ[$Phase1PoleIDs==={"Pole1","Pole2"} && Lookup[stateSnapshot["Inputs"],"PoleCount",Missing[]]===2],
    "SharedRegisterContainsNoPoleOperatingKeys"->TrueQ[Intersection[Keys[stateSnapshot["Inputs"]],$Phase1PoleOperatingKeys]==={}],
    "FlareAndCMEProfilesArePoleSpecific"->TrueQ[Complement[{"FlareTemporalProfile","CMETemporalProfile","FlareTailCutoffFraction"},$Phase1PoleOperatingKeys]==={}],
    "ControllerGainsArePoleSpecific"->TrueQ[Complement[{"ControllerTranslationKp_perS2","ControllerTranslationKd_perS","ControllerAttitudeKp_perS2","ControllerAttitudeKd_perS"},$Phase1PoleOperatingKeys]==={}],
    "HeliocentricReferenceMotionModeIsPoleSpecific"->TrueQ[MemberQ[$Phase1PoleOperatingKeys,"HeliocentricReferenceMotionMode"] && !MemberQ[Keys[stateSnapshot["Inputs"]],"HeliocentricReferenceMotionMode"] && KeyExistsQ[stateSnapshot["PoleOperatingInputs"]["Pole1"],"HeliocentricReferenceMotionMode"] && KeyExistsQ[stateSnapshot["PoleOperatingInputs"]["Pole2"],"HeliocentricReferenceMotionMode"]],
    "EachPoleHasItsOwnCompleteOperatingInputMap"->TrueQ[Complement[$Phase1PoleOperatingKeys,Keys[stateSnapshot["PoleOperatingInputs"]["Pole1"]]]==={} && Complement[$Phase1PoleOperatingKeys,Keys[stateSnapshot["PoleOperatingInputs"]["Pole2"]]]==={}],
    "PoleOperatingInputMapsSeparate"->TrueQ[AssociationQ[op1Before]&&AssociationQ[op2Before]],
    "UpdatingPole1ChangesOnlyRequestedPole1Field"->SameQ[pole1After,Join[op1Before,<|"Distance_m"->sentinel1|>]],
    "UpdatingPole1DoesNotChangePole2OperatingInputs"->SameQ[op2Before,pole2After],
    "UpdatingPole1DoesNotChangePole2OperatingProvenance"->SameQ[source2Before,source2After],
    "UpdatingPole1DoesNotChangePole2CachedState"->SameQ[state2Before,state2After],
    "UpdatingPole2ChangesOnlyRequestedPole2Field"->SameQ[Lookup[Lookup[reverseSetterProbe,"PoleOperatingInputs",<||>],"Pole2",<||>],Join[op2Before,<|"Distance_m"->sentinel2|>]],
    "UpdatingPole2DoesNotChangePole1OperatingInputs"->SameQ[op1Before,Lookup[Lookup[reverseSetterProbe,"PoleOperatingInputs",<||>],"Pole1",<||>]],
    "UpdatingPole2DoesNotChangePole1OperatingProvenance"->SameQ[source1Before,Lookup[Lookup[reverseSetterProbe,"PoleOperatingNotes",<||>],"Pole1",<||>]],
    "UpdatingPole2DoesNotChangePole1CachedState"->SameQ[state1Before,Lookup[Lookup[reverseSetterProbe,"PoleStates",<||>],"Pole1",Missing["NoPole1State"]]],
    "UpdatingPole1DoesNotChangeSharedDesignMaterialInputs"->SameQ[sharedBefore,sharedAfter],
    "PoleContextsContainOnlyTheirOwnOperatingInputsAndState"->localIsolation,
    "Pole1ToPole2InputReadBlocked"->MatchQ[crossInputProbe,Failure["CrossPoleInputReadBlocked",_Association]],
    "Pole1ToPole2StateReadBlocked"->MatchQ[crossStateProbe,Failure["CrossPoleStateReadBlocked",_Association]],
    "Pole2ToPole1InputReadBlocked"->MatchQ[reverseCrossInputProbe,Failure["CrossPoleInputReadBlocked",_Association]],
    "Pole2ToPole1StateReadBlocked"->MatchQ[reverseCrossStateProbe,Failure["CrossPoleStateReadBlocked",_Association]],
    "SharedInputSnapshotIdenticalForBothContexts"->SameQ[KeyTake[local1["Inputs"],sharedKeys],KeyTake[local2["Inputs"],sharedKeys]],
    "AggregateCalculationDoesNotMutatePoleStateOrInputs"->TrueQ[aggregateProbeUnchanged && AssociationQ[aggregateProbe]],
    "AggregateMassAndPowerAreArithmeticSums"->TrueQ[SameQ[Lookup[aggregateProbe,"TotalMass_kg",Missing[]],4.] && SameQ[Lookup[aggregateProbe,"TotalDeliveredPower_W",Missing[]],6.]],
    "AggregateDoesNotMultiplyByPoleCount"->TrueQ[SameQ[Lookup[aggregateProbe,"TotalMass_kg",Missing[]],Total[{1.,3.}]] && SameQ[Lookup[aggregateProbe,"TotalDeliveredPower_W",Missing[]],Total[{2.,4.}]]],
    "PerPoleContextsDoNotReceiveAggregateState"->TrueQ[Lookup[local1,"TwoPoleAggregate",Missing[]]===<||> && Lookup[local2,"TwoPoleAggregate",Missing[]]===<||>],
    "NoSharedOperationalStateOrCrossPoleFeedback"->TrueQ[localIsolation && SameQ[op2Before,pole2After] && SameQ[source2Before,source2After] && SameQ[state2Before,state2After] &&
      SameQ[op1Before,Lookup[Lookup[reverseSetterProbe,"PoleOperatingInputs",<||>],"Pole1",<||>]] &&
      SameQ[source1Before,Lookup[Lookup[reverseSetterProbe,"PoleOperatingNotes",<||>],"Pole1",<||>]] &&
      SameQ[state1Before,Lookup[Lookup[reverseSetterProbe,"PoleStates",<||>],"Pole1",Missing["NoPole1State"]]] &&
      SameQ[sharedBefore,sharedAfter] && MatchQ[crossInputProbe,Failure["CrossPoleInputReadBlocked",_Association]] &&
      MatchQ[crossStateProbe,Failure["CrossPoleStateReadBlocked",_Association]] &&
      MatchQ[reverseCrossInputProbe,Failure["CrossPoleInputReadBlocked",_Association]] &&
      MatchQ[reverseCrossStateProbe,Failure["CrossPoleStateReadBlocked",_Association]] && aggregateProbeUnchanged]
  |>;
  <|"Rule"->"Two physically distinct systems, one at each pole; design/material definitions shared, all operation independent.",
    "Checks"->checks,"Passed"->(And@@(TrueQ/@Values[checks])),
    "PoleOperatingInputCountPerPole"->Length[$Phase1PoleOperatingKeys],
    "PoleIDs"->$Phase1PoleIDs,
    "Note"->"The sentinel test ran inside a temporary state copy. No live input, pole state, cache or result was modified."|>
];

phase1PoleAggregate[poleResults_Association] := Module[
  {massValues, powerValues, areaValues, validMass, validPower, validArea, sumOrMissing, field},
  field[value_, key_, default_] := If[AssociationQ[value], Lookup[value, key, default], default];
  sumOrMissing[values_, valid_] := If[TrueQ[valid], Total[values], Missing["BothIndependentPoleResultsRequired"]];
  massValues = Table[field[field[field[poleResults, p, <||>], "MassBalance", <||>], "TotalMass_kg", Missing[]], {p, $Phase1PoleIDs}];
  powerValues = Table[field[field[field[poleResults, p, <||>], "PowerLedger", <||>], "ConditionedDeliveredPower_W_PerPole", Missing[]], {p, $Phase1PoleIDs}];
  areaValues = Table[Module[{st, derived, geometry},
    st = field[Lookup[$Phase1State, "PoleStates", <||>], p, <||>];
    derived = field[st, "Derived", <||>];
    geometry = field[derived, "Geometry", <||>];
    field[geometry, "GrossProjectedAreaPerPole_m2", Missing[]]
  ], {p, $Phase1PoleIDs}];
  validMass = And @@ (NumericQ /@ massValues); validPower = And @@ (NumericQ /@ powerValues);
  validArea = And @@ (NumericQ /@ areaValues);
  <|"PoleIDs" -> $Phase1PoleIDs, "PoleCount" -> 2,
    "SystemsOperationallyIndependent" -> True,
    "SharedDesignAndMaterialRegister" -> True,
    "InterPoleForceTorquePowerControlOrStateCoupling" -> False,
    "AggregationFeedsBackIntoPoleOperations" -> False,
    "AggregateAvailable" -> TrueQ[validMass && validPower && validArea],
    "PerPoleMass_kg" -> AssociationThread[$Phase1PoleIDs, massValues],
    "TotalMass_kg" -> sumOrMissing[massValues, validMass],
    "PerPoleDeliveredPower_W" -> AssociationThread[$Phase1PoleIDs, powerValues],
    "TotalDeliveredPower_W" -> sumOrMissing[powerValues, validPower],
    "PerPoleProjectedArea_m2" -> AssociationThread[$Phase1PoleIDs, areaValues],
    "TotalProjectedArea_m2" -> sumOrMissing[areaValues, validArea],
    "AggregationMethod" -> "Arithmetic sum of the two actual independent Pole1 and Pole2 calculation outputs. No output is multiplied by PoleCount.",
    "CombinedMechanicalEquilibrium" -> "Not evaluated; not applicable to independent systems with no mechanical or operational coupling."|>
];

Phase1ComputeAll[] := If[TrueQ[$Phase1ExecutingPole], phase1ComputeCurrentPole[],
  Module[{poleResults, aggregate},
    poleResults = AssociationMap[Phase1ComputePole, $Phase1PoleIDs];
    aggregate = phase1PoleAggregate[poleResults];
    $Phase1State = Join[$Phase1State, <|"TwoPoleAggregate" -> aggregate|>];
    <|"Revision" -> "v11.27", "PoleResults" -> poleResults, "Aggregate" -> aggregate,
      "AllPoleCalculationsIndependent" -> True,
      "PoleIndependenceAudit" -> Phase1PoleIndependenceAudit[],
      "ReadyForBothPoles" -> And @@ (AssociationQ[phase1PoleInputStatus[#]] && TrueQ[phase1PoleInputStatus[#]["Ready"]] & /@ $Phase1PoleIDs)|>
  ]];

phase1ReconcileSharedPVCandidate[perPole_Association] := Module[
  {fractions,numericFractions,tolerance,consistent,commonFraction,perPoleReady,range,
   commonEvaluations,withinRange,accepted},
  fractions=AssociationMap[If[AssociationQ[Lookup[perPole,#,Missing[]]],
    Lookup[perPole[#],"CandidatePVFraction",Missing["NoCandidate"]],Missing["NoCandidate"]]&,$Phase1PoleIDs];
  numericFractions=Select[Values[fractions],NumericQ];
  tolerance=Lookup[$Phase1State["Inputs"],"OptimizerGridCrossCheckRelativeTolerance",Missing["NotSet"]];
  consistent=Length[numericFractions]==2&&NumericQ[tolerance]&&
    Max[numericFractions]-Min[numericFractions]<=tolerance Max[Sqrt[$MinMachineNumber],Max[Abs[numericFractions]]];
  commonFraction=If[TrueQ[consistent],Mean[numericFractions],Missing["NoConsistentSharedCandidate"]];
  perPoleReady=And@@(AssociationQ[Lookup[perPole,#,Missing[]]]&&
    TrueQ[Lookup[perPole[#],"StaticConstraintProblemFeasible",False]]&&
    TrueQ[Lookup[perPole[#],"DynamicCandidateAcceptancePassed",False]]&&
    TrueQ[Lookup[perPole[#],"FullConstraintProblemFeasible",False]]&&
    TrueQ[Lookup[perPole[#],"ModelledAcceptanceUnderAssumptions",False]]&&
    NumericQ[Lookup[perPole[#],"CandidateDistance_m",Missing[]]]&/@$Phase1PoleIDs);
  range=Lookup[$Phase1State["Inputs"],"PVSearchRange",Missing["NoSearchRange"]];
  withinRange=ListQ[range]&&Length[range]==2&&NumericQ[commonFraction]&&TrueQ[range[[1]]<=commonFraction<=range[[2]]];
  commonEvaluations=If[TrueQ[consistent]&&TrueQ[perPoleReady]&&TrueQ[withinRange],
    AssociationMap[Function[pole,
      phase1WithPole[pole,phase1EvaluateCandidateTransient[
        perPole[pole]["CandidateDistance_m"],commonFraction,
        <|"BothIndependentPoleOptimizersPassedStaticAndDynamicGates"->True,
          "CommonPVFractionWithinSharedDesignSearchRange"->True,
          "CommonCandidateUsesThisPolesOwnOptimizedDistance"->True|>]]],$Phase1PoleIDs],<||>];
  accepted=TrueQ[consistent]&&TrueQ[perPoleReady]&&TrueQ[withinRange]&&
    Length[Keys[commonEvaluations]]==Length[$Phase1PoleIDs]&&
    And@@(TrueQ[Lookup[commonEvaluations[#],"ModelledAcceptanceUnderAssumptions",False]]&&
      TrueQ[Lookup[commonEvaluations[#],"NoLivePoleStateMutation",False]]&/@$Phase1PoleIDs);
  <|"PerPolePVFractionCandidates"->fractions,
    "CommonPVFractionCandidateConsistent"->TrueQ[consistent],
    "CommonPVFractionCandidate"->commonFraction,
    "IndependentCommonCandidateEvaluations"->commonEvaluations,
    "CommonPVFractionCandidatePassedBothPoleModelGates"->accepted,
    "CommonPVFractionCandidateRecommended"->If[accepted,commonFraction,Missing["CommonCandidateNotValidatedByBothIndependentSystems"]],
    "SharedDesignPVFractionApplied"->False,
    "CandidateInputsRetained"->False,
    "Rule"->"A candidate PV fraction is shared design/material data. The exact common value is independently recalculated at each pole's own optimizer distance with that pole's own operating inputs and must pass both static and dynamic gates. No candidate is automatically applied."|>
];

Phase1JointOptimization[pole_String] := phase1WithPole[pole, phase1JointOptimizationCurrent[]];
Phase1JointOptimization[] := If[TrueQ[$Phase1ExecutingPole], phase1JointOptimizationCurrent[],
  Module[{perPole},
    perPole=AssociationMap[Phase1JointOptimization,$Phase1PoleIDs];
    Join[<|"PerPoleOptimization"->perPole|>,phase1ReconcileSharedPVCandidate[perPole]]
  ]];

Phase1Validate[pole_String] := phase1WithPole[pole, phase1ValidateCurrent[]];
Phase1Validate[] := If[TrueQ[$Phase1ExecutingPole], phase1ValidateCurrent[],
  AssociationMap[Phase1Validate, $Phase1PoleIDs]];
Phase1RunSelfTests[pole_String] := Module[{status, software},
  If[!MemberQ[$Phase1PoleIDs, pole], Return[Failure["UnknownPoleID", <|"Pole" -> pole|>]]];
  status = phase1PoleInputStatus[pole];
  software = Phase1RunSoftwareSelfTests[];
  If[!TrueQ[status["Ready"]],
    Return[<|"Pole" -> pole, "SoftwareSelfTests" -> software,
      "EngineeringCalculationIntegrityTestsExecuted" -> False,
      "EngineeringTestsNotRunReason" -> "Required project inputs are still missing.",
      "MissingRequiredInputKeys" -> status["MissingRequiredInputKeys"]|>]
  ];
  phase1WithPole[pole, phase1RunSelfTestsCurrent[]]
];
Phase1RunSelfTests[] := If[TrueQ[$Phase1ExecutingPole],
  phase1RunSelfTestsCurrent[],
  Module[{software, status, allReady, perPole, isolation},
    software = Phase1RunSoftwareSelfTests[];
    status = Phase1InputStatus[];
    isolation = Phase1PoleIndependenceAudit[];
    allReady = TrueQ[status["Ready"]];
    If[!allReady,
      Return[<|"SoftwareSelfTests" -> software,
        "EngineeringCalculationIntegrityTestsExecuted" -> False,
        "EngineeringTestsNotRunReason" -> "Required shared and/or pole-specific project inputs are still missing.",
        "InputStatus" -> status,
        "PoleIndependenceAudit" -> isolation,
        "Passed" -> TrueQ[software["Passed"] && isolation["Passed"]]|>]
    ];
    perPole = AssociationMap[Phase1RunSelfTests, $Phase1PoleIDs];
    <|"SoftwareSelfTests" -> software, "PerPoleEngineeringSelfTests" -> perPole,
      "PoleIndependenceAudit" -> isolation,
      "AllPerPoleEngineeringSelfTestsPresent" -> And @@
        (TrueQ[Lookup[perPole[#], "ExpectedTestKeysPresent", False]] & /@ $Phase1PoleIDs),
      "AllPerPoleCalculationIntegrityTestsPassed" -> And @@
        (TrueQ[Lookup[perPole[#], "FailedCount", Infinity] == 0] & /@ $Phase1PoleIDs),
      "TwoPoleIndependenceTestsPassed" -> TrueQ[Lookup[isolation, "Passed", False]]|>
  ]
];
Phase1RunReport[pole_String] := phase1WithPole[pole, phase1RunReportCurrent[]];
Phase1RunReport[] := If[TrueQ[$Phase1ExecutingPole], phase1RunReportCurrent[],
  Module[{reports, calculation},
    reports = AssociationMap[Phase1RunReport, $Phase1PoleIDs];
    calculation = Phase1ComputeAll[];
    <|"PerPoleReports" -> reports,
      "TwoPoleCalculationSummary" -> calculation,
      "TwoPoleAggregate" -> If[AssociationQ[calculation], calculation["Aggregate"], Missing["AggregateUnavailable"]],
      "AggregateIsReportingOnly" -> True,
      "PoleIndependenceAudit" -> Phase1PoleIndependenceAudit[],
      "PoleIndependenceRule" -> $Phase1State["PoleArchitectureRule"]|>]];

Phase1RunPoleAssessment[pole_String] := phase1WithPole[pole, phase1RunFullAssessmentCurrent[]];
Phase1RunBothPoleAssessments[] := If[TrueQ[$Phase1ExecutingPole],
  Failure["TwoPoleAssessmentCannotRunInsideSinglePoleContext", <|"ActivePole" -> $Phase1CurrentPole|>],
  Module[{perPole, computed, perPoleOptimizations, sharedPVReconciliation},
  perPole = AssociationMap[Phase1RunPoleAssessment, $Phase1PoleIDs];
  (* Extract the actual independent optimizer result associations from each completed assessment. *)
  perPoleOptimizations = AssociationMap[Function[pole,
    Module[{poleAssessment = Lookup[perPole, pole, Missing["PoleAssessmentUnavailable"]],
        assessmentData},
      If[!AssociationQ[poleAssessment], Return[Missing["PoleAssessmentFailed", pole]]];
      assessmentData = Lookup[poleAssessment, "Assessment", Missing["AssessmentUnavailable"]];
      If[AssociationQ[assessmentData],
        Lookup[assessmentData, "JointOptimization", Missing["OptimizationUnavailable"]],
        Missing["AssessmentFailed", pole]]
    ]], $Phase1PoleIDs];
  sharedPVReconciliation=phase1ReconcileSharedPVCandidate[perPoleOptimizations];
  computed = Phase1ComputeAll[];
  <|"PerPoleAssessments" -> perPole, "SharedDesignPVReconciliation"->sharedPVReconciliation,
    "TwoPoleCalculationSummary" -> computed,
    "TwoPoleAggregate" -> Lookup[$Phase1State, "TwoPoleAggregate", <||>],
    "SystemsOperationallyIndependent" -> True,
    "NoCrossPoleOperationalDataExchange" -> True,
    "PoleIndependenceAudit" -> Phase1PoleIndependenceAudit[]|>]];
Phase1RunFullAssessment[] := If[TrueQ[$Phase1ExecutingPole], phase1RunFullAssessmentCurrent[], Phase1RunBothPoleAssessments[]];
Phase1RunFullAssessment[pole_String] := Phase1RunPoleAssessment[pole];

Phase1RunPoleTask[pole_String, task_String] := phase1WithPole[pole, Switch[task,
  "ComputeAll", phase1EnsureCalculated[],
  "FullAssessment", phase1RunFullAssessmentCurrent[],
  "JointOptimization", phase1JointOptimizationCurrent[],
  "SolveExactEquilibrium", phase1SolveExactEquilibriumCurrent[],
  "IntegratedSimulation", phase1IntegratedSimulationCurrent[],
  "FreeRotation", phase1FreeRotationTrajectoryCurrent[],
  "Wobble", phase1WobbleSimulationCurrent[],
  "Validate", phase1ValidateCurrent[],
  "SelfTests", phase1RunSelfTestsCurrent[],
  "DisturbanceScenarios", phase1DisturbanceScenariosCurrent[],
  "ThermalDistanceFloor", phase1DistanceThermalFloorCurrent[],
  _, Failure["UnknownPoleTask", <|"Task" -> task, "ValidTasks" -> {"ComputeAll", "FullAssessment", "JointOptimization", "SolveExactEquilibrium", "IntegratedSimulation", "FreeRotation", "Wobble", "Validate", "SelfTests", "DisturbanceScenarios", "ThermalDistanceFloor"}|>] ]];

(* Pole-specific overloads for the principal stateful solvers. *)
(* All scalar operational APIs resolve to exactly one pole context. The no-argument
   form uses the selected pole; a pole_String first argument is explicit. The global
   bulk APIs Phase1ComputeAll, Phase1JointOptimization, and Phase1RunFullAssessment
   are the only ordinary entry points that intentionally visit both poles. *)
Phase1SolveExactEquilibrium[] := If[TrueQ[$Phase1ExecutingPole],phase1SolveExactEquilibriumCurrent[],Phase1SolveExactEquilibrium[$Phase1SelectedPole]];
Phase1SolveExactEquilibrium[pole_String] := phase1WithPole[pole,phase1SolveExactEquilibriumCurrent[]];

Phase1DistanceThermalFloor[coverage_:Automatic] := If[TrueQ[$Phase1ExecutingPole],phase1DistanceThermalFloorCurrent[coverage],Phase1DistanceThermalFloor[$Phase1SelectedPole,coverage]];
Phase1DistanceThermalFloor[pole_String,coverage_:Automatic] := phase1WithPole[pole,phase1DistanceThermalFloorCurrent[coverage]];

Phase1IntegratedSimulation[durationS_:Automatic] := If[TrueQ[$Phase1ExecutingPole],phase1IntegratedSimulationCurrent[durationS],Phase1IntegratedSimulation[$Phase1SelectedPole,durationS]];
Phase1IntegratedSimulation[pole_String,durationS_:Automatic] := phase1WithPole[pole,phase1IntegratedSimulationCurrent[durationS]];

Phase1FreeRotationTrajectory[durationS_:Automatic] := If[TrueQ[$Phase1ExecutingPole],phase1FreeRotationTrajectoryCurrent[durationS],Phase1FreeRotationTrajectory[$Phase1SelectedPole,durationS]];
Phase1FreeRotationTrajectory[pole_String,durationS_:Automatic] := phase1WithPole[pole,phase1FreeRotationTrajectoryCurrent[durationS]];

Phase1WobbleSimulation[durationS_:Automatic] := If[TrueQ[$Phase1ExecutingPole],phase1WobbleSimulationCurrent[durationS],Phase1WobbleSimulation[$Phase1SelectedPole,durationS]];
Phase1WobbleSimulation[pole_String,durationS_:Automatic] := phase1WithPole[pole,phase1WobbleSimulationCurrent[durationS]];

Phase1DisturbanceScenarios[] := If[TrueQ[$Phase1ExecutingPole],phase1DisturbanceScenariosCurrent[],Phase1DisturbanceScenarios[$Phase1SelectedPole]];
Phase1DisturbanceScenarios[pole_String] := phase1WithPole[pole,phase1DisturbanceScenariosCurrent[]];


Phase1TimeDependentPower[timeS_?NumericQ] := If[TrueQ[$Phase1ExecutingPole],phase1TimeDependentPowerCurrent[timeS],Phase1TimeDependentPower[$Phase1SelectedPole,timeS]];
Phase1TimeDependentPower[pole_String,timeS_?NumericQ] := phase1WithPole[pole,phase1TimeDependentPowerCurrent[timeS]];

Phase1ICARUSControlLaw[desiredWrench_List,capacityN_:Automatic] := If[TrueQ[$Phase1ExecutingPole],phase1ICARUSControlLawCurrent[desiredWrench,capacityN],Phase1ICARUSControlLaw[$Phase1SelectedPole,desiredWrench,capacityN]];
Phase1ICARUSControlLaw[pole_String,desiredWrench_List,capacityN_:Automatic] := phase1WithPole[pole,phase1ICARUSControlLawCurrent[desiredWrench,capacityN]];

Phase1ICARUSLoadPropagation[localPosition_List,localVelocity_List,attitudeQuaternion_List,angularVelocity_List] :=
  If[TrueQ[$Phase1ExecutingPole],phase1ICARUSLoadPropagationCurrent[localPosition,localVelocity,attitudeQuaternion,angularVelocity],
    Phase1ICARUSLoadPropagation[$Phase1SelectedPole,localPosition,localVelocity,attitudeQuaternion,angularVelocity]];
Phase1ICARUSLoadPropagation[pole_String,localPosition_List,localVelocity_List,attitudeQuaternion_List,angularVelocity_List] :=
  phase1WithPole[pole,phase1ICARUSLoadPropagationCurrent[localPosition,localVelocity,attitudeQuaternion,angularVelocity]];

Phase1Phase2Handoff[] := If[TrueQ[$Phase1ExecutingPole],phase1Phase2HandoffCurrent[],Phase1Phase2Handoff[$Phase1SelectedPole]];
Phase1Phase2Handoff[pole_String] := phase1WithPole[pole,phase1Phase2HandoffCurrent[]];

Phase1StabilityCriteria[] := If[TrueQ[$Phase1ExecutingPole],phase1StabilityCriteriaCurrent[],Phase1StabilityCriteria[$Phase1SelectedPole]];
Phase1StabilityCriteria[pole_String] := phase1WithPole[pole,phase1StabilityCriteriaCurrent[]];

Phase1LocalSurfaceMesh[] := If[TrueQ[$Phase1ExecutingPole],
  Module[{computed=phase1EnsureCalculated[]},If[FailureQ[computed],computed,Lookup[$Phase1State["Derived"],"SurfaceMesh",Missing["SurfaceMeshUnavailable"]]]],
  Phase1LocalSurfaceMesh[$Phase1SelectedPole]];
Phase1LocalSurfaceMesh[pole_String] := Module[{computed=Phase1ComputePole[pole]},
  If[FailureQ[computed],computed,Phase1GetPoleDerived[pole,"SurfaceMesh"]]];

Phase1LocalRadiationLoads[] := If[TrueQ[$Phase1ExecutingPole],Phase1GetResult["LocalRadiation"],Phase1LocalRadiationLoads[$Phase1SelectedPole]];
Phase1LocalRadiationLoads[pole_String] := Module[{computed=Phase1ComputePole[pole]},If[FailureQ[computed],computed,Phase1GetPoleResult[pole,"LocalRadiation"]]];
Phase1MassBalance[] := If[TrueQ[$Phase1ExecutingPole],Phase1GetResult["MassBalance"],Phase1MassBalance[$Phase1SelectedPole]];
Phase1MassBalance[pole_String] := Module[{computed=Phase1ComputePole[pole]},If[FailureQ[computed],computed,Phase1GetPoleResult[pole,"MassBalance"]]];
Phase1ThermalScreen[] := If[TrueQ[$Phase1ExecutingPole],Phase1GetResult["Thermal"],Phase1ThermalScreen[$Phase1SelectedPole]];
Phase1ThermalScreen[pole_String] := Module[{computed=Phase1ComputePole[pole]},If[FailureQ[computed],computed,Phase1GetPoleResult[pole,"Thermal"]]];
Phase1PowerLedger[] := If[TrueQ[$Phase1ExecutingPole],Phase1GetResult["PowerLedger"],Phase1PowerLedger[$Phase1SelectedPole]];
Phase1PowerLedger[pole_String] := Module[{computed=Phase1ComputePole[pole]},If[FailureQ[computed],computed,Phase1GetPoleResult[pole,"PowerLedger"]]];
Phase1DynamicInitialConditions[] := If[TrueQ[$Phase1ExecutingPole],Phase1GetResult["DynamicInitialConditions"],Phase1DynamicInitialConditions[$Phase1SelectedPole]];
Phase1DynamicInitialConditions[pole_String] := Module[{computed=Phase1ComputePole[pole]},If[FailureQ[computed],computed,Phase1GetPoleResult[pole,"DynamicInitialConditions"]]];

(* The selected pole is only a read/view convenience. It never changes either
   operating register or causes the two systems to share a runtime state. *)
Phase1SelectPole[pole_String] := Which[
  TrueQ[$Phase1ExecutingPole] && pole =!= $Phase1CurrentPole, Failure["CrossPoleSelectionBlocked", <|"ActivePole" -> $Phase1CurrentPole, "RequestedPole" -> pole|>],
  !MemberQ[$Phase1PoleIDs, pole], Failure["UnknownPoleID", <|"Pole" -> pole, "ValidPoleIDs" -> $Phase1PoleIDs|>],
  True, $Phase1SelectedPole = pole; pole];
Phase1GetResults[] := If[TrueQ[$Phase1ExecutingPole], phase1EnsureCalculated[], Phase1GetPoleResults[$Phase1SelectedPole]];
Phase1GetResult[name_String] := If[TrueQ[$Phase1ExecutingPole],
  Module[{r = phase1EnsureCalculated[]}, If[FailureQ[r], r, Lookup[$Phase1State["Results"], name, Missing["ResultNotAvailable", name]]]],
  Phase1GetPoleResult[$Phase1SelectedPole, name]];
Phase1GetDerived[name_String] := If[TrueQ[$Phase1ExecutingPole],
  Module[{r = phase1EnsureCalculated[]}, If[FailureQ[r], r, Lookup[$Phase1State["Derived"], name, Missing["DerivedValueNotAvailable", name]]]],
  Phase1GetPoleDerived[$Phase1SelectedPole, name]];

(* A single-pole candidate may not alter the shared design. Reconciliation across
   both pole operating envelopes is a separate design decision. *)
Phase1ApplyOptimizationCandidate[] := Failure["SinglePoleCandidateCannotChangeSharedDesign", <|
  "Reason" -> "A candidate calculated for one pole cannot modify common design/material inputs. Reconcile both independent pole optimization results against the shared design register first.",
  "NoInputsChanged" -> True|>];

(* Input UI: shared design/material editor excludes all per-pole operating keys. *)
Phase1InteractivePanel[] := DynamicModule[
  {working = Phase1GetSharedInputs[], sources = Lookup[$Phase1State, "InputNotes", <||>], result = Missing["NotRun"], keys},
  keys = Keys[$Phase1State["Inputs"]];
  Column[{
    Style["PHASE 1 — SHARED DESIGN & MATERIAL INPUTS / v11.27", Bold],
    Style["These inputs are common to both pole systems. Pole-specific operating values are entered separately in Phase1PoleOperatingInputPanel[\"Pole1\"] or [\"Pole2\"]."],
    Pane[Dynamic@Grid[Prepend[Table[{k, InputField[Dynamic[working[k]]],
      InputField[Dynamic[Lookup[sources, k, ""]]]}, {k, keys}],
      {"Shared input key", "Value", "Optional source note"}],
      Alignment -> Left], Scrollbars -> {False, True}],
    Row[{
      Button["Apply shared inputs",
        result = Phase1SetInputs[Association@KeyTake[working, keys],
          Association@Select[Normal[sources], MemberQ[keys, First[#]] && StringQ[Last[#]] && StringTrim[Last[#]] =!= "" &]], Method -> "Queued"],
      Button["Reload", working = Phase1GetSharedInputs[]; sources = Lookup[$Phase1State, "InputNotes", <||>], Method -> "Queued"]
    }],
    Dynamic[If[FailureQ[result], Style[ToString[result, InputForm], Red], ToString[Phase1InputStatus[], InputForm]]]
  }]
];

Phase1PoleOperatingInputPanel[pole_String] := Which[
  TrueQ[$Phase1ExecutingPole] && pole =!= $Phase1CurrentPole, Failure["CrossPoleUIReadBlocked", <|"ActivePole" -> $Phase1CurrentPole, "RequestedPole" -> pole|>],
  !MemberQ[$Phase1PoleIDs, pole], Failure["UnknownPoleID", <|"Pole" -> pole|>],
  True,
  DynamicModule[{working = Lookup[$Phase1State["PoleOperatingInputs"], pole],
    sources = Lookup[Lookup[$Phase1State, "PoleOperatingNotes", <||>], pole, <||>], result = Missing["NotRun"]},
    Column[{
      Style["PHASE 1 — " <> pole <> " OPERATING INPUTS", Bold],
      Style["These operating values belong only to " <> pole <> ". Changes here do not alter the other pole's operating register or result cache."],
      Grid[Prepend[Table[{k, InputField[Dynamic[working[k]]],
        InputField[Dynamic[Lookup[sources, k, ""]]]}, {k, $Phase1PoleOperatingKeys}],
        {"Operating input key", "Value", "Pole-specific source / measurement / assumption"}],
        Alignment -> Left],
      Row[{
        Button["Apply " <> pole <> " operating inputs",
          result = Phase1SetPoleOperatingInputs[pole, Association@KeyTake[working, $Phase1PoleOperatingKeys],
            Association@Select[Normal[sources], StringQ[Last[#]] && StringTrim[Last[#]] =!= "" &]], Method -> "Queued"],
        Button["Reload", working = Lookup[$Phase1State["PoleOperatingInputs"], pole];
          sources = Lookup[Lookup[$Phase1State, "PoleOperatingNotes", <||>], pole, <||>], Method -> "Queued"],
        Button["Calculate this pole", result = Phase1ComputePole[pole], Method -> "Queued"]
      }],
      Dynamic[If[FailureQ[result], Style[ToString[result, InputForm], Red], ToString[Phase1InputStatus[pole], InputForm]]] 
    }]
  ]
];

Phase1Reset[] := If[TrueQ[$Phase1ExecutingPole],
  Failure["ResetBlockedInsidePoleExecution", <|"ActivePole" -> $Phase1CurrentPole|>],
  Module[{shared = $Phase1DefaultInputs, op = $Phase1PoleInputDefaults},
  $Phase1State = <|"SchemaVersion" -> $Phase1ModelVersion, "Inputs" -> shared,
    "OptionalSourceNotes" -> $Phase1ReferenceNotes, "InputNotes" -> $Phase1UserConfirmedInputNotes,
    "PoleOperatingInputs" -> AssociationThread[$Phase1PoleIDs, ConstantArray[op, Length[$Phase1PoleIDs]]],
    "PoleOperatingNotes" -> AssociationThread[$Phase1PoleIDs, ConstantArray[<||>, Length[$Phase1PoleIDs]]],
    "PoleStates" -> <||>, "LegacyInputArchive" -> <||>, "TwoPoleAggregate" -> <||>, "Derived" -> <||>, "Results" -> <||>,
    "AuditLog" -> {}, "LastRun" -> Missing["NotRun"], "ActivePole" -> Missing["NoActivePole"],
    "PoleArchitectureRule" -> "Two physically distinct systems, one installed at each pole. Their design and material definitions are shared; their operation is completely independent. Each pole has its own operating inputs, local environment and disturbance history, initial conditions, forces, torques, controllers, dynamics, stored state, caches, results, optimization and acceptance decisions. No operating state, force, torque, power, control command, disturbance, environment state or calculated operating output is exchanged, coupled, combined or used as an input between poles. Immutable physical constants and common mathematical/numerical algorithms are common definitions, not shared operating states. Scalar outputs may be arithmetically summed only after both calculations finish and only for reporting; aggregate results never feed either pole's operation. No combined mechanical equilibrium is imposed. Each pole uses its own local Sun-radial +x coordinate basis; no common global position/orientation is inferred."|>;
  phase1Audit["ResetTwoIndependentPoleSystems", <|"PoleCount" -> 2, "OtherProjectDefaults" -> 0|>];
  $Phase1State
]];

Phase1SaveState[path_String] := If[TrueQ[$Phase1ExecutingPole],
  Failure["SaveStateBlockedInsidePoleExecution", <|"ActivePole" -> $Phase1CurrentPole|>],
  Put[$Phase1State, path]];
Phase1LoadState[path_String] := If[TrueQ[$Phase1ExecutingPole],
  Failure["LoadStateBlockedInsidePoleExecution", <|"ActivePole" -> $Phase1CurrentPole|>],
  Module[{loaded, schema, shared, sharedSources, opInputs, opSources, legacyArchive,
    legacySharedValues, legacySharedSources, legacyPoleArchive, preservedReferenceKeys, legacyReferenceValues, legacyReferenceSources,
    unknownShared, unknownOps, migrated = False,
    activeSharedSources, activePoleSources, invalidPoleMaps},
    loaded = Quiet@Check[Get[path], $Failed];
    If[!AssociationQ[loaded],
      Return[Failure["InvalidIndependentPoleStateFile", <|"Path" -> path|>]]];
    schema = Lookup[loaded, "SchemaVersion", ""];
    If[!MemberQ[{"11.11", "11.12", "11.13", "11.14", "11.15", "11.16", "11.17", "11.18", "11.19", "11.20", "11.21", "11.22", "11.23", "11.24", "11.25", "11.26", $Phase1ModelVersion}, schema],
      Return[Failure["InvalidOrUnsupportedIndependentPoleStateFile",
        <|"Path" -> path, "SupportedSchemas" -> {"11.11", "11.12", "11.13", "11.14", "11.15", "11.16", "11.17", "11.18", "11.19", "11.20", "11.21", "11.22", "11.23", "11.24", "11.25", "11.26", "11.27"}|>]]];
    shared = Lookup[loaded, "Inputs", <||>];
    If[!AssociationQ[shared],
      Return[Failure["InvalidSharedInputRegisterInSavedState", <|"Path" -> path|>]]];
    sharedSources = Lookup[loaded, "InputNotes", <||>];
    If[!AssociationQ[sharedSources], sharedSources = <||>];
    opInputs = Lookup[loaded, "PoleOperatingInputs", <||>];
    opSources = Lookup[loaded, "PoleOperatingNotes", <||>];
    If[!AssociationQ[opInputs],
      Return[Failure["InvalidPoleOperatingInputRegistersInSavedState", <|"Path" -> path|>]]];
    If[!AssociationQ[opSources], opSources = <||>];
    invalidPoleMaps = Select[$Phase1PoleIDs,
      !AssociationQ[Lookup[opInputs, #, <||>]] || !AssociationQ[Lookup[opSources, #, <||>]] &];
    If[invalidPoleMaps =!= {},
      Return[Failure["InvalidPoleOperatingInputOrProvenanceMap",
        <|"Path" -> path, "Poles" -> invalidPoleMaps|>]]];
    legacyArchive = Lookup[loaded, "LegacyInputArchive", <||>];
    If[!AssociationQ[legacyArchive], legacyArchive = <||>];

    If[MemberQ[{"11.11", "11.12", "11.13", "11.14", "11.15", "11.16", "11.17", "11.18", "11.19", "11.20", "11.21", "11.22", "11.23", "11.24", "11.25", "11.26"}, schema],
      migrated = True;
      (* Saved states created before v11.27 predate the current blank-by-default input policy.
         They may contain old project values that were generated under previous assumptions or entered before the current input policy. Archive their complete active input and optional source-note maps,
         then reset all project-specific values and all per-pole operating values to Missing.
         No prior project number is allowed back into an active calculation merely because
         it was present in a saved state. *)
      legacySharedValues = KeyDrop[shared, $Phase1ReferenceAndSoftwareDefaultKeys];
      legacySharedSources = KeyTake[sharedSources, Keys[legacySharedValues]];
      legacyPoleArchive = AssociationMap[Function[id,
        <|"Values" -> Lookup[opInputs, id, <||>],
          "OptionalSourceNotes" -> Lookup[opSources, id, <||>]|>], $Phase1PoleIDs];
      preservedReferenceKeys = Intersection[Keys[shared], $Phase1ReferenceAndSoftwareDefaultKeys,
        Keys[$Phase1DefaultInputs]];
      legacyReferenceValues = KeyTake[shared, preservedReferenceKeys];
      legacyReferenceSources = KeyTake[sharedSources, preservedReferenceKeys];
      (* Even canonical-reference overrides from an older save are archived, not trusted.
         The current source restores only its published physical constants, standardized
         PV test conditions, mathematical domain and Mathematica execution conventions. *)
      shared = $Phase1DefaultInputs;
      activeSharedSources = $Phase1UserConfirmedInputNotes;
      opInputs = AssociationThread[$Phase1PoleIDs, ConstantArray[$Phase1PoleInputDefaults, Length[$Phase1PoleIDs]]];
      opSources = AssociationThread[$Phase1PoleIDs, ConstantArray[<||>, Length[$Phase1PoleIDs]]];
      legacyArchive = Join[legacyArchive, <|
        "MostRecentArchivedSchema" -> schema,
        "MigrationPolicy" -> "All pre-v11.27 project-specific shared inputs and both poles' operating inputs were archived, then reset to Missing[UserInputRequired]. None are active in v11.27 until the owner enters the required values.",
        "SharedProjectInputs" -> <|"Values" -> legacySharedValues,
          "OptionalSourceNotes" -> legacySharedSources|>,
        "PerPoleOperatingInputs" -> legacyPoleArchive,
        "LegacyReferenceAndSoftwareValues" -> <|"Values" -> legacyReferenceValues,
          "OptionalSourceNotes" -> legacyReferenceSources,
          "Reactivated" -> False,
          "Policy" -> "All saved legacy reference/software overrides are archived and inactive; the current source's canonical published constants, PV reference conditions, and software definitions are used instead."|>,
        "ArchivedAtLoadPath" -> path|>];
      sharedSources = activeSharedSources;
      loaded = Join[loaded, <|
        "SchemaMigration" -> <|"From" -> schema, "To" -> $Phase1ModelVersion,
          "LegacyProjectInputsArchivedNotActivated" -> True,
          "AllLegacySharedProjectInputsResetToMissing" -> True,
          "AllLegacyPerPoleOperatingInputsResetToMissing" -> True,
          "OnlyCanonicalReferenceAndSoftwareDefaultsPreserved" -> True,
          "LegacyReferenceOverridesArchivedNotActivated" -> True,
          "PoleCountRetained" -> 2,
          "AllCalculationCachesInvalidated" -> True|>|>];
    ];

    unknownShared = Complement[Keys[shared], Keys[$Phase1DefaultInputs]];
    If[unknownShared =!= {},
      Return[Failure["UnknownSharedInputKeys", <|"Keys" -> unknownShared|>]]];
    unknownOps = Complement[Flatten[Keys /@ Values[opInputs]], $Phase1PoleOperatingKeys];
    If[unknownOps =!= {},
      Return[Failure["UnknownPoleOperatingInputKeys", <|"Keys" -> unknownOps|>]]];
    If[Lookup[shared, "PoleCount", Missing[]] =!= 2,
      Return[Failure["InvalidPoleCountInSavedState", <|"RequiredPoleCount" -> 2|>]]];

    activeSharedSources = Join[
      KeyTake[sharedSources, Intersection[Keys[sharedSources], Keys[shared]]],
      $Phase1UserConfirmedInputNotes];
    activePoleSources = AssociationMap[Function[id,
      KeyTake[Lookup[opSources, id, <||>], $Phase1PoleOperatingKeys]], $Phase1PoleIDs];
    $Phase1State = Join[loaded, <|
      "SchemaVersion" -> $Phase1ModelVersion,
      "Inputs" -> Join[$Phase1DefaultInputs, shared],
      "InputNotes" -> activeSharedSources,
      "PoleOperatingInputs" -> AssociationMap[Function[id,
        Join[$Phase1PoleInputDefaults, Lookup[opInputs, id, <||>]]], $Phase1PoleIDs],
      "PoleOperatingNotes" -> activePoleSources,
      "LegacyInputArchive" -> legacyArchive,
      "PoleStates" -> <||>, "TwoPoleAggregate" -> <||>,
      "Derived" -> <||>, "Results" -> <||>,
      "LastRun" -> Missing["LoadedStateRequiresPerPoleRecalculation"]|>];
    phase1Audit["IndependentPoleStateLoaded", <|"Path" -> path,
      "AllPoleCachesInvalidated" -> True,
      "MigratedFromLegacySchema" -> migrated,
      "LegacyProjectInputsArchivedNotActivated" -> migrated,
      "NewUserInputsRequiredAfterMigration" -> If[migrated,
        Join[Keys[Select[$Phase1DefaultInputs, MissingQ]],
          Flatten[Table[(id <> "::" <> #) & /@ $Phase1PoleOperatingKeys, {id, $Phase1PoleIDs}]]], {}]|>];
    $Phase1State
  ]
];

(* Legacy inputs are retained only for review. They are never read by calculations. *)
Phase1GetLegacyInputArchive[] := Lookup[$Phase1State, "LegacyInputArchive", <||>];

(* The only numerical operation common to the poles is evaluation of shared design/material
   properties. Each pole's complete calculation uses a merged read-only snapshot that combines
   those common values with exactly one pole's operating inputs. *)

End[];
EndPackage[];
