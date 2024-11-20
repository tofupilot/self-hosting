CREATE MIGRATION m1h7s2b6sc4u2tomjc5dso3f5hklbp6pcuwi6gn2uiix537jyvd4ga
    ONTO m1u3vmgykhcuioxkp55vydy5p5wvm3zs2wgzsrnolkbo7ihcpsoc6a
{
  ALTER SCALAR TYPE analytics::ObjectiveType EXTENDING enum<ApprovedRequirements, CoverageProcedureRequirement, CoverageDesignRequirement, ApprovedProcedures, ApprovedDesigns, ValidatedDesigns, CoveragePlanRequirement, ApprovedPlans>;
  ALTER SCALAR TYPE default::PrimitiveNamespace EXTENDING enum<Requirement, Design, Procedure, Action, Asset, Defect, Plan>;
};
